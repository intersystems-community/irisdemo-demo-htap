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

import java.sql.Connection;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.*;

@CrossOrigin()
@RestController
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AppController {
    private static boolean databaseHasBeenInitialized = false;

    private boolean speedTestRunning = false;

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

    /**
     * This is called by the container HEALTHCHECK
     **/
    @GetMapping(value = "/master/test")
    public int test() {
        return 1;
    }

    @PostMapping(value = "/master/startSpeedTest")
    public synchronized void startSpeedTest() throws Exception {
        if (!speedTestRunning) {
            IngestWorker ingestWorker = ingestWorkerRegistryService.getOneWorker();
            if (!databaseHasBeenInitialized) {
                logger.info("START speed test. Asking one worker to prepare the database...");
                String prepareURL = "http://" + ingestWorker.getHostname() + "/worker/prepare";
                restTemplate.postForEntity(prepareURL, null, null);
                databaseHasBeenInitialized = true;
            } else {
                logger.info("START speed test. Asking one worker to truncate the table...");
                String truncateTableURL = "http://" + ingestWorker.getHostname() + "/worker/truncateTable";
                restTemplate.postForEntity(truncateTableURL, null, null);
            }

            speedTestRunning = true;

            logger.info("START speed test. Notifying all workers...");

            // Start ingestion...
            ingestWorkerRegistryService.startSpeedTest();

            // Should we start the consumers as well?
            if (config.getStartConsumers()) {
                queryWorkerRegistryService.startSpeedTest();
            }
        } else {
            logger.warn(
                    "Request to start the speed test received. Speed Test was already running. Nothing has been done.");
        }
    }

    @PostMapping(value = "/master/stopSpeedTest")
    public synchronized void stopSpeedTest() throws Exception {
        if (speedTestRunning) {
            logger.info("STOP speed test. Notifying all workers...");

            // Stop ingestion...
            ingestWorkerRegistryService.stopSpeedTest();

            // If we have started the consumers, we should now stop them too...
            if (config.getStartConsumers()) {
                queryWorkerRegistryService.stopSpeedTest();
            }

            speedTestRunning = false;
        } else {
            logger.warn("Request to stop speed test received. Speed test was not running. Nothing has been done.");
        }
    }

    @GetMapping(value = "/master/getActiveFeeds")
    public int getActiveFeeds() {
        int activeFeeds = 0;
        return activeFeeds;
    }

    @GetMapping(value = "/master/getTitle")
    public RESTStringContainer getTitle() {
        return new RESTStringContainer(config.getTitle());
    }

    @GetMapping(value = "/master/ingestworker/register/{hostname}")
    public WorkerConfig registerIngestWorker(@PathVariable String hostname) {
        IngestWorker worker = new IngestWorker(hostname);
        return ingestWorkerRegistryService.register(worker);
    }

    @GetMapping(value = "/master/queryworker/register/{hostname}")
    public WorkerConfig registerQueryWorker(@PathVariable String hostname) {
        QueryWorker worker = new QueryWorker(hostname);
        return queryWorkerRegistryService.register(worker);
    }

    @GetMapping(value = "/master/ingestworker/count")
    public int getNumOfIngestWorkers() {
        return ingestWorkerRegistryService.getNumOfWorkers();
    }

    @GetMapping(value = "/master/queryworker/count")
    public int getNumOfQueryWorkers(String hostname) {
        return queryWorkerRegistryService.getNumOfWorkers();
    }

    @GetMapping(value = "/master/countworkers")
    public int getNumOfWorkers(String hostname) {
        return ingestWorkerRegistryService.getNumOfWorkers() + queryWorkerRegistryService.getNumOfWorkers();
    }

    @RequestMapping("/master/getMetrics")
    public Metrics getMetrics() {
        return new Metrics(accumulatedIngestMetrics, accumulatedQueryMetrics);
    }

    @Scheduled(fixedRate = 1000)
    synchronized protected void getIngestionMetricsFromWorkers() {
        if (speedTestRunning) {
            AccumulatedIngestMetrics tempIngestionMetrics = new AccumulatedIngestMetrics();
            ConcurrentHashMap<String, IngestWorker> ingestWorkers = ingestWorkerRegistryService.getWorkers();

            ingestWorkers.forEach((hostname, worker) -> {

                String url = "http://" + hostname + "/worker/getMetrics";

                try {
                    IngestMetrics workerMetrics = restTemplate.getForObject(url, IngestMetrics.class);
                    tempIngestionMetrics.addToStats(workerMetrics);
                } catch (RestClientException restException) {
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
        if (speedTestRunning) {
            AccumulatedQueryMetrics tempQueryMetrics = new AccumulatedQueryMetrics();
            ConcurrentHashMap<String, QueryWorker> QueryWorkers = queryWorkerRegistryService.getWorkers();
	    	
	    	QueryWorkers.forEach((hostname, worker) -> {
	    		
	    		String url = "http://" + hostname +"/worker/getMetrics";
	    		
	    		try
	    		{
	    			QueryMetrics workerMetrics = restTemplate.getForObject(url, QueryMetrics.class);
	    			tempQueryMetrics.addToStats(workerMetrics);
	    		}
	    		catch (RestClientException restException)
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
    public Config getApplicationConfig(@RequestBody Config newConfig) {

        /* Ingestion Settings */
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

        return config;
    }

    class RESTStringContainer
    {
        public String value;

        public RESTStringContainer(String value)
        {
            this.value=value;
        }
    }

}
