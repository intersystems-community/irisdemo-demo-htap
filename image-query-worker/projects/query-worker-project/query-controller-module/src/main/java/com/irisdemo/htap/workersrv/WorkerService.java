package com.irisdemo.htap.workersrv;

import java.io.IOException;
import java.sql.SQLException;
import java.util.concurrent.CancellationException;
import java.util.concurrent.CompletableFuture;

//import com.irisdemo.HTAP.SpeedTest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import com.irisdemo.htap.config.Config;
import com.irisdemo.htap.config.ConfigService;

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
    ConfigService configService;
    
    @Autowired
    IWorker worker;
    
	// Running threads
	private CompletableFuture<?>[] futures;
	
	private int currentNumberOfConsumers;
		
    public synchronized int getNumberOfConsumersRunning()
    {
		//return consumerThreadPool.getActiveCount();
		return currentNumberOfConsumers;
    }

	@Async
    public synchronized void startConsumers() throws ConsumersAlreadyRunningException, IOException, SQLException, Exception
    {
		resyncConfig();

    	if (getNumberOfConsumersRunning()>1) // The current thread is the control thread and it doesn't count.
    	{
    		throw new ConsumersAlreadyRunningException();
    	}
    	
        logger.info("Master requested to START the query threads...");
                
        accumulatedMetrics.reset();
        workerSemaphore.allowThreads();
    	
        int consumptionNumThreadsPerWorker = config.getConsumptionNumThreadsPerWorker();

    	// Creating the array to hold all the CompletableFutures that will be pointing to our threads
    	futures = new CompletableFuture<?>[consumptionNumThreadsPerWorker];
    	
    	for (int consumer=0; consumer<consumptionNumThreadsPerWorker; consumer++)
    	{
			futures[consumer] = worker.startOneConsumer(consumer);
    		currentNumberOfConsumers++;
    	}
    }
    
    public void stopAllConsumers()
    {
    	workerSemaphore.disableThreads();
		
		try
		{
			int currentConsumers = 	getNumberOfConsumersRunning();
			for (int consumer=0; consumer<currentConsumers; consumer++)
			{
				logger.info("Joining Consumption thread "+consumer+"...");
				currentNumberOfConsumers--;
			}
		}
		catch (CancellationException ce)
		{
			//Ignore CancellationException
		}
	}
	
	/**
	 * Called from com.irisdemo.htap.AppController
	 * @throws Exception
	 */
    public void resyncConfig() throws Exception 
    {
        configService.registerWithMasterAndGetConfig();
    }
    
	public class ConsumersAlreadyRunningException extends Exception
	{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
}