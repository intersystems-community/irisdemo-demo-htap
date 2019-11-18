package com.irisdemo.htap.worker;

import java.io.IOException;
import java.sql.SQLException;
import java.util.concurrent.CompletableFuture;

//import com.irisdemo.HTAP.SpeedTest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import com.irisdemo.htap.config.Config;

@Service
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class WorkerService 
{
    Logger logger = LoggerFactory.getLogger(WorkerService.class);

    @Autowired
    WorkerSemaphore workerSemaphore;
    
    @Autowired 
    AccumulatedMetrics accumulatedMetrics;
    
    @Autowired
    Config config;
    
    @Autowired
    @Qualifier("worker")
    IWorker worker;
    
	// Running threads
	private CompletableFuture<Long>[] futures;
	
	private int numberOfRunningFeeds = 0;
	
	/**
	 * Called from com.irisdemo.htap.AppController
	 * @throws Exception
	 */
    public void prepareDatabaseForSpeedTest() throws Exception 
    {
    	logger.info("Master requested this worker to prepare the database for the speed test.");
    	worker.prepareDatabaseForSpeedTest();
    	logger.info("Database has been prepared.");
    }

    public void truncateTable() throws Exception 
    {
    	logger.info("Master requested this worker to truncate the table.");
    	worker.truncateTable();
    	logger.info("Table has been truncated.");
    }

	/**
	 * Called from com.irisdemo.htap.AppController
	 * @throws Exception
	 */
    public void startSpeedTest() throws IOException, SQLException 
    {
    	int confNumIngestionThreads = config.getIngestionNumThreadsPerWorker();
        logger.info("Master requested to START the speed test.");
        
    	futures = new CompletableFuture[confNumIngestionThreads];
    	
        accumulatedMetrics.reset();
        workerSemaphore.allowThreads();
    	
    	for (int thread=0; thread<confNumIngestionThreads; thread++)
    	{
    		/* 
    		 * startOneFeed is @Async. Every call to this method starts a new thread and returns a CompletableFuture
    		 */
			futures[thread] = worker.startOneFeed(config.getWorkerNodePrefix(), thread);
			numberOfRunningFeeds++;
			logger.info("Thread #"+numberOfRunningFeeds+" started.");
    	}
    	
		//speedTest.startSpeedTest();
    }

	/**
	 * Called from com.irisdemo.htap.AppController
	 * @throws Exception
	 */
    public void stopSpeedTest() 
    {
    	int threadsRunning = numberOfRunningFeeds;
    	
        logger.info("Master requested to STOP the speed test. Stopping "+ threadsRunning + " threads...");
        
        workerSemaphore.disableThreads();
		for (int thread=0; thread<threadsRunning; thread++)
		{
			logger.info("Joining thread #"+thread+"...");
			futures[thread].join();
			numberOfRunningFeeds--;
		}
		
		logger.info("All threads stopped.");

    }
    
	/**
	 * Called from com.irisdemo.htap.AppController
	 * @throws Exception
	 */
    public int getNumberOfActiveFeeds() 
    {
        return numberOfRunningFeeds;
    }
}