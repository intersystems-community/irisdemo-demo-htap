package com.irisdemo.htap.worker;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;

import com.irisdemo.htap.config.*;

import java.util.HashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.irisdemo.htap.worker.Worker;

@Service
@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class WorkerRegistryService<W extends Worker>
{
    @Autowired
    private Config config;

    @Autowired
    RestTemplate restTemplate;

    Logger logger = LoggerFactory.getLogger(WorkerRegistryService.class);

    private HashMap<String, W> workers;

    WorkerRegistryService()
    {
        this.workers = new HashMap<String, W>();
    }
    
    synchronized public HashMap<String, W>getWorkers()
    {
    	return workers;
    }
    
    /*
     * This method is called by a REST service implementation on class WorkerController. That
     * service is called by Workers to register with this master.
     */
    synchronized public WorkerConfig register(W worker)
    {
        int numWorkers = getNumOfWorkers()+1;

        logger.trace("Registering " + worker.getWorkerType() + " Worker #" + (numWorkers) + " on host name '" + worker.getHostname() + "'.");

        workers.put(worker.getHostname(), worker);

        return new WorkerConfig(this.config, "W"+numWorkers);
    }

    synchronized public int getNumOfWorkers()
    {
        return workers.size();
    }
    
    @Async
    synchronized public void startSpeedTest()
    {
    	
    	workers.forEach((hostname, worker) -> {
    		
    		String url = "http://" + hostname +"/worker/startSpeedTest";
    		
    		try
    		{
    			logger.info("Starting speed test on " + hostname);
    			restTemplate.postForEntity(url, null, null);
    		}
    		catch (RestClientException restException)
    		{
    			logger.info("Worker on " + hostname + " is not responding. Marking worker as unavailablebecause of: " + restException.getMessage());
    			worker.setAvailable(false);
    		}

    	});	
    }
    
    @Async
    synchronized public void stopSpeedTest()
    {
    	workers.forEach((hostname, worker) -> {
    		
    		String url = "http://" + hostname +"/worker/stopSpeedTest";
    		
    		try
    		{
    			logger.info("Stopping speed test on " + hostname);
    			restTemplate.postForEntity(url, null, null);
    		}
    		catch (RestClientException restException)
    		{
    			logger.info("Worker on " + hostname + " is not responding. Marking worker as unavailable because of: " + restException.getMessage());
    			worker.setAvailable(false);
    		}

    	});
    }
    
    /*
     * If a worker is marked as unavailable, the service registry will remove it automatically so 
     * we don't keep trying to reach it every time.
     */
    @Scheduled(fixedRate = 1000)
    synchronized protected void purgeWorkers()
    {
    	HashMap<String, W> remainingWorkers = new HashMap<String, W>();
    	
    	workers.forEach((hostname, worker) -> {
    		if (worker.isAvailable())
    		{
    			remainingWorkers.put(hostname, worker);
    		}
    		else
    		{
    			logger.info("Worker on " + hostname + " seems to have died. Removing it from registry.");
    		}
    	});
    	
    	workers = remainingWorkers;
    }
    
}