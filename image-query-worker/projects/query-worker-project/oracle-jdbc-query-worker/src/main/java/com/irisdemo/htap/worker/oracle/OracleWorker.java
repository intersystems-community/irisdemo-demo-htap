package com.irisdemo.htap.worker.oracle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ThreadLocalRandom;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import com.irisdemo.htap.config.Config;

import com.irisdemo.htap.workersrv.WorkerSemaphore;
import com.irisdemo.htap.workersrv.AccumulatedMetrics;
import com.irisdemo.htap.workersrv.IWorker;

import oracle.jdbc.pool.OracleDataSource;

@Component("worker")
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class OracleWorker implements IWorker 
{
    Logger logger = LoggerFactory.getLogger(OracleWorker.class);

    @Autowired
    WorkerSemaphore workerSemaphore;
    
    @Autowired 
    AccumulatedMetrics accumulatedMetrics;
    
    @Autowired
    Config config;    

    DriverManagerDataSource dataSourceCache;

	/**
	 * I could not make this a Bean. It would get created before we had fetched the connection information from
	 * the master.
	 * 
	 * @return
	 * @throws SQLException
	 * @throws IOException
	 */
	synchronized public DriverManagerDataSource getDataSource() throws SQLException, IOException, ClassNotFoundException
	{
		if (dataSourceCache==null)
		{
	        logger.info("Creating data source for '" + config.getConsumptionJDBCURL() + "'...");
			
			Class.forName("oracle.jdbc.driver.OracleDriver");
	        dataSourceCache = new DriverManagerDataSource(config.getConsumptionJDBCURL());
		}
        
        return dataSourceCache;
    }

	public void setReadCommitted(Connection connection) throws SQLException
	{
		PreparedStatement statement = null;
		
		try
		{
			logger.info("SET TRANSACTION ISOLATION LEVEL");
			connection.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
		}
		catch (SQLException e)
		{
			throw e;
		}
		finally
		{
			if (statement!=null)
				statement.close();
		}
	}

	@Async("workerExecutor")
    public CompletableFuture<Long> startOneConsumer(int threadNum) throws IOException, SQLException, ClassNotFoundException
    {			
		PreparedStatement preparedStatement;
		ResultSet rs;
		ResultSetMetaData rsmd;
		Connection connection = (Connection)getDataSource().getConnection();
		long returnVal = 0;

		accumulatedMetrics.incrementNumberOfActiveQueryThreads();
		logger.info("Starting Consumer thread "+threadNum+"...");

		setReadCommitted(connection);

		double t0, t1, t2, t3, rowCount;
		int idIndex, rowSizeInBytes, colnumCount;
		
		String[] IDs = new String[config.getConsumptionNumOfKeysToFetch()];

		for (idIndex = 0; idIndex<config.getConsumptionNumOfKeysToFetch(); idIndex++)
		{
			IDs[idIndex]="W1A"+idIndex;
		}		  
		
		/*
		 *  Each thread will run queries on the first 4 elements of the array.
		 *  Harry randomly shuffled the array so that each thread would be fetching different records.
		 */

		Random rnd = ThreadLocalRandom.current();
		
		for (idIndex = IDs.length - 1; idIndex > 0; idIndex--)
		{
			int index = rnd.nextInt(idIndex + 1);
		    // Simple swap
		    String id = IDs[index];
		    IDs[index] = IDs[idIndex];
		    IDs[idIndex] = id;
		}
		
		try 
		{
			preparedStatement = connection.prepareStatement(config.getQueryByIdStatement().replace("SpeedTest.", ""));
			
			while(workerSemaphore.green())
			{
				for (idIndex = 0; idIndex<4; idIndex++)
				{					
					t0 = System.currentTimeMillis();
					preparedStatement.setString(1, IDs[idIndex]);
					rs = preparedStatement.executeQuery();
					
					t1= System.currentTimeMillis();
					
					/* 
					 * The customer said that it is not fair if we just read the data and
					 * don't do anything with it. So we will just compute the approximate size of
					 * the data we have read to show "proof of work".
					 */
					
					rsmd = rs.getMetaData();
	                rowSizeInBytes=0;
	                rowCount=0;
					
	                t2= System.currentTimeMillis();                
	                
					colnumCount = rsmd.getColumnCount();
	                
	                while (rs.next()) 
	                {
						rowCount++;

	                    for (int column=1; column<=colnumCount; column++) 
	                    {
	                    	rowSizeInBytes += rs.getString(column).getBytes().length;
	                    }
	                 }
					 t3= System.currentTimeMillis();
					 
					 accumulatedMetrics.addToStats(t3-t0, rowCount, rowSizeInBytes);
				}
				
				if (config.getConsumptionTimeBetweenQueriesInMillis()>0)
				{
					Thread.sleep(config.getConsumptionTimeBetweenQueriesInMillis());
				}
			}
		} 
		catch (SQLException sqlException) 
		{
			logger.error("Exception while running consumer query: " + sqlException.getMessage());
			System.exit(-1);
		}
		catch (InterruptedException e) 
		{
			logger.warn("Thread has been interrupted. Maybe the master asked it to stop: " + e.getMessage());
		}
		catch (Exception e) 
		{
			throw e;
		} 
		finally
		{
			connection.close();
		}
		
		accumulatedMetrics.decrementNumberOfActiveQueryThreads();

		logger.info("Consumption worker #"+threadNum+" finished.");

    	return CompletableFuture.completedFuture(returnVal);
	}
}
