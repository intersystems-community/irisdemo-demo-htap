package com.irisdemo.htap;

import com.irisdemo.htap.worker.WorkerRegistryService;
import com.irisdemo.htap.worker.AccumulatedIngestMetrics;
import com.irisdemo.htap.worker.AccumulatedQueryMetrics;
import com.irisdemo.htap.worker.IngestMetrics;
import com.irisdemo.htap.worker.IngestWorker;
import com.irisdemo.htap.worker.QueryMetrics;
import com.irisdemo.htap.worker.QueryWorker;
import com.irisdemo.htap.config.Config;
import com.irisdemo.htap.config.WorkerConfig;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import org.springframework.http.converter.ByteArrayHttpMessageConverter;
import org.springframework.http.converter.HttpMessageConverter;

@CrossOrigin()
@RestController
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AppController {
    private static boolean databaseHasBeenInitialized = false;

    /// 0 - Stopped, 1 - Starting, 2 - Running
    private int speedTestRunningStatus = 0;

    @Autowired
    WorkerRegistryService<IngestWorker> ingestWorkerRegistryService;

    @Autowired
    WorkerRegistryService<QueryWorker> queryWorkerRegistryService;

    @Autowired
    AccumulatedIngestMetrics accumulatedIngestMetrics;

    @Autowired
    AccumulatedQueryMetrics accumulatedQueryMetrics;

    @Autowired
    RestTemplate restTemplate;

    @Autowired
    Config config;

    Logger logger = LoggerFactory.getLogger(AppController.class);
    
    @Autowired
    MetricsFileManager metricsFileManager;
    
    private long speedTestStartTimeInMillis;
    private int speedTestRuntimeInSeconds;

    private Metrics currentAggregatedMetrics = new Metrics(0);

    @Bean
    public ByteArrayHttpMessageConverter byteArrayHttpMessageConverter() {
        ByteArrayHttpMessageConverter arrayHttpMessageConverter = new ByteArrayHttpMessageConverter();
        arrayHttpMessageConverter.setSupportedMediaTypes(getSupportedMediaTypes());
        return arrayHttpMessageConverter;
    }

    private List<MediaType> getSupportedMediaTypes() {
        List<MediaType> list = new ArrayList<MediaType>();
        list.add(MediaType.TEXT_PLAIN);
        return list;
    }

    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        converters.add(byteArrayHttpMessageConverter());
    }

    @RequestMapping(value = "/master/metrics", method = RequestMethod.GET)
    public ResponseEntity<byte[]> getMetricsFileAsByteArray() throws IOException 
    {
        String fileName;

        if (config.getTitle()!=null && !config.getTitle().equals(""))
        {
            fileName = config.getTitle()+" results.txt";
        }
        else
        {
            fileName = "metrics.txt";
        }
        
        fileName = fileName.replace("/", "_");
        fileName = fileName.replace("\\", "_");
        fileName = fileName.replace("  ", " ");

        return this.metricsFileManager.getMetricsFileAsResponseEntity(fileName);     
    }

    /**
     * This is called by the container HEALTHCHECK
     **/
    @GetMapping(value = "/master/test")
    public int test() {
        return 1;
    }

    private void startMetricAggregation() throws Exception
    {
        metricsFileManager.openMetricsFile();
        speedTestStartTimeInMillis = new Date().getTime();
        speedTestRuntimeInSeconds = 0;        
        accumulatedIngestMetrics.reset();
        accumulatedQueryMetrics.reset();
        speedTestRunningStatus = 2; //Running
        currentAggregatedMetrics = new Metrics(speedTestRunningStatus);
    }
    
    @PostMapping(value = "/master/startSpeedTest")
    public void startSpeedTest() throws Exception {
        
        // Are we stopped?
        if (speedTestRunningStatus==0) 
        {
            speedTestRunningStatus = 1; //Starting...
            currentAggregatedMetrics = new Metrics(speedTestRunningStatus);
            
            final IngestWorker ingestWorker = ingestWorkerRegistryService.getOneWorker();
            if (!databaseHasBeenInitialized) {
                logger.info("START speed test. Asking one worker to prepare the database...");
                final String prepareURL = "http://" + ingestWorker.getHostname() + "/worker/prepare";
                restTemplate.postForEntity(prepareURL, null, null);
                databaseHasBeenInitialized = true;
            } else {
                logger.info("START speed test. Asking one worker to truncate the table...");
                final String truncateTableURL = "http://" + ingestWorker.getHostname() + "/worker/truncateTable";
                restTemplate.postForEntity(truncateTableURL, null, null);
            }

            logger.info("START speed test. Notifying all workers...");

            // Start ingestion...
            ingestWorkerRegistryService.startSpeedTest();
            
            // Should we start the consumers as well?
            if (config.getStartConsumers()) {
                queryWorkerRegistryService.startSpeedTest();
            }

            startMetricAggregation();
        } 
        else 
        {
            logger.warn(
                    "Request to start the speed test received. Speed Test was already starting or running. Nothing has been done.");
        }
    }

    @PostMapping(value = "/master/stopSpeedTest")
    public void stopSpeedTest() throws Exception {
        
        // Are we running?
        if (speedTestRunningStatus==2) 
        {
            logger.info("STOP speed test. Notifying all workers...");

            speedTestRunningStatus = 0; //Stopped

            // Aggregating metrics one last time, to include the update to speedTestRunning
            aggregateMetrics();

            // Stop ingestion...
            ingestWorkerRegistryService.stopSpeedTest();

            // If we have started the consumers, we should now stop them too...
            if (config.getStartConsumers()) {
                queryWorkerRegistryService.stopSpeedTest();
            }
        } 
        else 
        {
            logger.warn("Request to stop speed test received. Speed test was not running. Nothing has been done.");
        }
    }

    @GetMapping(value = "/master/getTitle")
    public RESTStringContainer getTitle() {
        return new RESTStringContainer(config.getTitle());
    }

    @GetMapping(value = "/master/ingestworker/register/{hostname}")
    public WorkerConfig registerIngestWorker(@PathVariable final String hostname) {
        final IngestWorker worker = new IngestWorker(hostname);
        return ingestWorkerRegistryService.register(worker);
    }

    @GetMapping(value = "/master/queryworker/register/{hostname}")
    public WorkerConfig registerQueryWorker(@PathVariable final String hostname) {
        final QueryWorker worker = new QueryWorker(hostname);
        return queryWorkerRegistryService.register(worker);
    }

    @GetMapping(value = "/master/ingestworker/count")
    public int getNumOfIngestWorkers() {
        return ingestWorkerRegistryService.getNumOfWorkers();
    }

    @GetMapping(value = "/master/queryworker/count")
    public int getNumOfQueryWorkers(final String hostname) {
        return queryWorkerRegistryService.getNumOfWorkers();
    }

    @GetMapping(value = "/master/countworkers")
    public int getNumOfWorkers(final String hostname) {
        return ingestWorkerRegistryService.getNumOfWorkers() + queryWorkerRegistryService.getNumOfWorkers();
    }

    @RequestMapping("/master/getMetrics")
    public Metrics getMetrics() {
        return this.currentAggregatedMetrics;
    }

    @Scheduled(fixedRate = 1000)
    synchronized protected void monitorAndAggregateMetrics() throws Exception
    {        
        // Just take the current accumulated Metrics for ingestion and query and add it to the end of the file
        if (speedTestRunningStatus==2)
        {
            long currentTimeInSeconds = new Date().getTime();
            this.speedTestRuntimeInSeconds = (int) (currentTimeInSeconds-this.speedTestStartTimeInMillis)/1000;

            // Is it time to stop already?
            if (this.speedTestRuntimeInSeconds >= config.getMaxTimeToRunInSeconds())
            {
                this.stopSpeedTest();
            }

            // Aggregating metrics from ingestion and query workers
            aggregateMetrics();
        }
    }

    synchronized private void aggregateMetrics() throws Exception
    {
        if (speedTestRuntimeInSeconds>0)
        {
            this.currentAggregatedMetrics = new Metrics(speedTestRunningStatus, speedTestRuntimeInSeconds, accumulatedIngestMetrics, accumulatedQueryMetrics);

            // Appending to file just in case they want to download it
            metricsFileManager.appendMetrics(this.currentAggregatedMetrics);
        }
    }

    @Scheduled(fixedRate = 1000)
    synchronized protected void getIngestionMetricsFromWorkers() {
        // If we are running
        if (speedTestRunningStatus==2) 
        {
            final AccumulatedIngestMetrics tempIngestionMetrics = new AccumulatedIngestMetrics();
            final ConcurrentHashMap<String, IngestWorker> ingestWorkers = ingestWorkerRegistryService.getWorkers();

            ingestWorkers.forEach((hostname, worker) -> {

                final String url = "http://" + hostname + "/worker/getMetrics";

                try 
                {
                    final IngestMetrics workerMetrics = restTemplate.getForObject(url, IngestMetrics.class);
                    tempIngestionMetrics.addToStats(workerMetrics);
                } 
                catch (final RestClientException restException) 
                {
                    logger.info("Ingestion worker on " + hostname
                            + " is not responding. Marking worker as unavailable because of: "
                            + restException.getMessage());
                    worker.setAvailable(false);
                }

            });

            accumulatedIngestMetrics.update(tempIngestionMetrics);
        }
    }

    @Scheduled(fixedRate = 1000)
    synchronized protected void getQueryMetricsFromWorkers() {
        //If we are running
        if (speedTestRunningStatus==2) {
            final AccumulatedQueryMetrics tempQueryMetrics = new AccumulatedQueryMetrics();
            final ConcurrentHashMap<String, QueryWorker> QueryWorkers = queryWorkerRegistryService.getWorkers();
	    	
	    	QueryWorkers.forEach((hostname, worker) -> {
	    		
	    		final String url = "http://" + hostname +"/worker/getMetrics";
	    		
	    		try
	    		{
	    			final QueryMetrics workerMetrics = restTemplate.getForObject(url, QueryMetrics.class);
	    			tempQueryMetrics.addToStats(workerMetrics);
	    		}
	    		catch (final RestClientException restException)
	    		{
	    			logger.info("Query worker on " + hostname + " is not responding. Marking worker as unavailable because of: " + restException.getMessage());
	    			worker.setAvailable(false);
	    		}
	
	    	});
	    	
	    	accumulatedQueryMetrics.update(tempQueryMetrics);
    	}
    }

    @GetMapping(value = "/master/getApplicationConfig")
    public Config getApplicationConfig() 
    {
        return config;
    }

    @PostMapping(path = "/master/updateApplicationConfig", consumes = "application/json", produces = "application/json")
    public Config getApplicationConfig(@RequestBody final Config newConfig) {

        /* Ingestion Settings */
        config.setIngestionWaitTimeBetweenBatchesInMillis(newConfig.getIngestionWaitTimeBetweenBatchesInMillis());
        config.setIngestionBatchSize(newConfig.getIngestionBatchSize());
        config.setIngestionNumThreadsPerWorker(newConfig.getIngestionNumThreadsPerWorker());

        config.setIngestionJDBCUserName(newConfig.getIngestionJDBCUserName());
        config.setIngestionJDBCPassword(newConfig.getIngestionJDBCPassword());
        config.setIngestionJDBCURL(newConfig.getIngestionJDBCURL());

        config.setInsertStatement(newConfig.getInsertStatement());

        /*Consumption Setings*/

        config.setConsumptionNumThreadsPerWorker(newConfig.getConsumptionNumThreadsPerWorker());
        config.setConsumptionTimeBetweenQueriesInMillis(newConfig.getConsumptionTimeBetweenQueriesInMillis());

        config.setConsumptionJDBCUserName(newConfig.getConsumptionJDBCUserName());
        config.setConsumptionJDBCPassword(newConfig.getConsumptionJDBCPassword());
        config.setConsumptionJDBCURL(newConfig.getConsumptionJDBCURL());

        config.setQueryStatement(newConfig.getQueryStatement());

        config.setMaxTimeToRunInSeconds(newConfig.getMaxTimeToRunInSeconds());
        config.setConsumptionNumOfKeysToFetch(newConfig.getConsumptionNumOfKeysToFetch());
        
        return config;
    }

    class RESTStringContainer
    {
        public String value;

        public RESTStringContainer(final String value)
        {
            this.value=value;
        }
    }

}
