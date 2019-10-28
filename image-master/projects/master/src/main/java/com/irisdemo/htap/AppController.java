package com.irisdemo.htap;

import com.irisdemo.htap.worker.WorkerRegistryService;
import com.irisdemo.htap.worker.WorkerSemaphore;
import com.irisdemo.htap.worker.AccumulatedIngestMetrics;
import com.irisdemo.htap.worker.AccumulatedQueryMetrics;
import com.irisdemo.htap.worker.IngestMetrics;
import com.irisdemo.htap.worker.IngestWorker;
import com.irisdemo.htap.worker.QueryMetrics;
import com.irisdemo.htap.worker.QueryWorker;
import com.irisdemo.htap.config.Config;
import com.irisdemo.htap.config.WorkerConfig;
import com.irisdemo.htap.db.DatabaseService;

import java.sql.Connection;
import java.util.HashMap;

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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@CrossOrigin()
@RestController
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AppController 
{

    @Autowired
    WorkerRegistryService <IngestWorker>ingestWorkerRegistryService;

    @Autowired
    WorkerRegistryService <QueryWorker>queryWorkerRegistryService;

    @Autowired
    AccumulatedIngestMetrics accumulatedIngestMetrics;

    @Autowired
    AccumulatedQueryMetrics accumulatedQueryMetrics;

    @Autowired
    Config config;
        
    @Autowired
    DatabaseService dataSource;

    @Autowired
    RestTemplate restTemplate;
    
    @Autowired
    WorkerSemaphore workerSemaphore;

    Logger logger = LoggerFactory.getLogger(AppController.class);
    
    /**
     * This is called by the container HEALTHCHECK
     **/
    @GetMapping(value = "/master/test")
    public int test() 
    {
        return 1;
    }

    @PostMapping(value = "/master/startSpeedTest")
    public void startSpeedTest() throws Exception 
    {
    	workerSemaphore.allowThreads();
    	
    	logger.info("START speed test. Truncating table for new speed test...");
    	dataSource.truncateTable();
    	
    	logger.info("START speed test. Notifying all workers...");
    	
    	ingestWorkerRegistryService.startSpeedTest();
    	
    	if (config.getStartConsumers())
    	{
    		queryWorkerRegistryService.startSpeedTest();
    	}

    }

    @PostMapping(value = "/master/stopSpeedTest")
    public void stopSpeedTest() throws Exception 
    {
    	workerSemaphore.disableThreads();
    	
        logger.info("STOP speed test. Notifying all workers...");
    	
    	ingestWorkerRegistryService.stopSpeedTest();
    	
    	if (config.getStartConsumers())
    	{
    		queryWorkerRegistryService.stopSpeedTest();
    	}
    }

    @GetMapping(value = "/master/getActiveFeeds")
    public int getActiveFeeds() 
    {
        int activeFeeds = 0;
        return activeFeeds;
    }
    
    @GetMapping(value = "/master/ingestworker/register/{hostname}")
    public WorkerConfig registerIngestWorker(@PathVariable String hostname) 
    {
        IngestWorker worker = new IngestWorker(hostname);
        return ingestWorkerRegistryService.register(worker);
    }

    @GetMapping(value = "/master/queryworker/register/{hostname}")
    public WorkerConfig registerQueryWorker(@PathVariable String hostname) 
    {
        QueryWorker worker = new QueryWorker(hostname);
        return queryWorkerRegistryService.register(worker);
    }

    @GetMapping(value = "/master/ingestworker/count")
    public int getNumOfIngestWorkers() 
    {
        return ingestWorkerRegistryService.getNumOfWorkers();
    }

    @GetMapping(value = "/master/queryworker/count")
    public int getNumOfQueryWorkers(String hostname) 
    {
        return queryWorkerRegistryService.getNumOfWorkers();
    }

    @GetMapping(value = "/master/countworkers")
    public int getNumOfWorkers(String hostname) 
    {
        return ingestWorkerRegistryService.getNumOfWorkers() + queryWorkerRegistryService.getNumOfWorkers();
    }
    
    @RequestMapping("/master/getMetrics")
    public Metrics getMetrics() 
    {
        return new Metrics(accumulatedIngestMetrics, accumulatedQueryMetrics);
    }

    @Scheduled(fixedRate = 1000)
    synchronized protected void getIngestionMetricsFromWorkers()
    {
    	if (workerSemaphore.green())
    	{
	    	AccumulatedIngestMetrics tempIngestionMetrics = new AccumulatedIngestMetrics();
	    	HashMap<String,IngestWorker> ingestWorkers = ingestWorkerRegistryService.getWorkers();
	    	
	    	ingestWorkers.forEach((hostname, worker) -> {
	    		
	    		String url = "http://" + hostname +"/worker/getMetrics";
	    		
	    		try
	    		{
	    			IngestMetrics workerMetrics = restTemplate.getForObject(url, IngestMetrics.class);
	    			tempIngestionMetrics.addToStats(workerMetrics);
	    		}
	    		catch (RestClientException restException)
	    		{
	    			logger.info("Ingestion worker on " + hostname + " is not responding. Marking worker as unavailable because of: " + restException.getMessage());
	    			worker.setAvailable(false);
	    		}
	
	    	});
	    	
	    	accumulatedIngestMetrics.update(tempIngestionMetrics);
    	}
    }
    
    @Scheduled(fixedRate = 1000)
    synchronized protected void getQueryMetricsFromWorkers()
    {
    	if (workerSemaphore.green())
    	{
	    	AccumulatedQueryMetrics tempQueryMetrics = new AccumulatedQueryMetrics();
	    	HashMap<String,QueryWorker> QueryWorkers = queryWorkerRegistryService.getWorkers();
	    	
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
}
