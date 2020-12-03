package com.irisdemo.htap.worker.hana;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.concurrent.CompletableFuture;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import com.irisdemo.htap.config.Config;
import com.irisdemo.htap.workersrv.IWorker;
import com.irisdemo.htap.workersrv.WorkerMetricsAccumulator;
import com.irisdemo.htap.workersrv.WorkerSemaphore;

@Component("worker")
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class HANAWorker implements IWorker 
{
	protected static Logger logger = LoggerFactory.getLogger(HANAWorker.class);
	
    @Autowired
    protected WorkerSemaphore workerSemaphore;
    
    @Autowired 
    protected WorkerMetricsAccumulator accumulatedMetrics;
    
    @Autowired
    protected Config config;    
    
    @Autowired
    protected WorkerDBUtils workerDBUtils;
    
	protected static char[] prefixes = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};

	@Async("workerExecutor")
    public CompletableFuture<Long> startOneFeed(String nodePrefix, int threadNum) throws IOException, SQLException
    {	
		long recordNum = 0;
		long batchSizeInBytes;
		
		accumulatedMetrics.incrementNumberOfActiveIngestionThreads();

		Connection connection = workerDBUtils.getDataSource().getConnection();
    	
		logger.info("Ingestion worker #"+threadNum+" started.");
		
		connection.setAutoCommit(false);
		
		PreparedStatement preparedStatement = connection.prepareStatement(config.getInsertStatement());

		int parameterCount = preparedStatement.getParameterMetaData().getParameterCount();
		
		workerDBUtils.initializeRandomMapping(connection);
		
    	try
    	{    		
    		String threadPrefix = nodePrefix+prefixes[threadNum];
    		
    		int currentBatchSize;
        	
	    	while(workerSemaphore.green())
	    	{
	    		currentBatchSize = 0;
	    		batchSizeInBytes = 0;
	    		
	    		while(workerSemaphore.green())
	    		{
	    			if (currentBatchSize==config.getIngestionBatchSize()) 
	    				break;
	    			
	    			batchSizeInBytes+= WorkerDBUtils.pupulatePreparedStatement(parameterCount, ++recordNum, threadPrefix, preparedStatement);
	    		
	    			preparedStatement.addBatch();
	    			preparedStatement.clearParameters();
	    			currentBatchSize++;	    			
	    		}

				if(workerSemaphore.green())
				{
					preparedStatement.executeBatch();
					preparedStatement.clearBatch();
					connection.commit();
					accumulatedMetrics.addToStats(currentBatchSize, batchSizeInBytes);

					if (config.getIngestionWaitTimeBetweenBatchesInMillis()>0)
					{
						Thread.sleep(config.getIngestionWaitTimeBetweenBatchesInMillis());
					}	
				}
	    	}	
			
		} 
    	catch (SQLException sqlException) 
    	{
			logger.error("Ingestion worker #"+threadNum+" crashed with the following error:" + sqlException.getMessage());
			System.exit(-1);
		} 
		catch (InterruptedException e) 
		{
			logger.warn("Thread has been interrupted. Maybe the master asked it to stop: " + e.getMessage());
		} 
    	finally
    	{
    		connection.close();
    	}
		
		accumulatedMetrics.decrementNumberOfActiveIngestionThreads();

    	logger.info("Ingestion worker #"+threadNum+" finished.");
    	return CompletableFuture.completedFuture(recordNum);
	}
	
	@Override
	public void prepareDatabaseForSpeedTest() throws Exception
    {
		Connection connection = workerDBUtils.getDataSource().getConnection();
		
		try
		{
			try
			{
				workerDBUtils.dropTable(connection);
			}
			catch (SQLException exception)
			{
				if (exception.getErrorCode()==259) //Invalid table name
				{
					
				}
				else
				{
					throw exception;
				}
				
			}
			
			workerDBUtils.createTable(connection);
		}
		catch (Exception e)
		{
			throw e;
		}
		finally
		{
			connection.close();
		}
    	
    }
	
	@Override
	public void truncateTable() throws Exception
    {
		Connection connection = workerDBUtils.getDataSource().getConnection();
		
		try
		{
			workerDBUtils.truncateTable(connection);
		}
		catch (Exception e)
		{
			throw e;
		}
		finally
		{
			connection.close();
		}
    	
    }
}
