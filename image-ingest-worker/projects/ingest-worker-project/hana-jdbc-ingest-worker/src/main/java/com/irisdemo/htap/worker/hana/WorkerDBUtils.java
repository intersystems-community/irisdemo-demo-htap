package com.irisdemo.htap.worker.hana;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Component;

import com.irisdemo.htap.config.Config;
import com.sap.db.jdbc.exceptions.JDBCDriverException;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class WorkerDBUtils 
{
	protected static Logger logger = LoggerFactory.getLogger(WorkerDBUtils.class);
    
    @Autowired
    protected Config config;    
	
    protected static Object[][] paramRandomValues;
	
    protected static int[] paramDataTypes;
	
    protected static long[][] paramSizeInBytes;
	
    protected static boolean randomMappingInitialized = false;
    
    protected static DriverManagerDataSource dataSourceCache = null;
	
	/**
	 * I could not make this a Bean. It would get created before we had fetched the connection information from
	 * the master.
	 * 
	 * This method can't be static because it relies on the auto-wiring of config to work.
	 * 
	 * @return
	 * @throws SQLException
	 * @throws IOException
	 */
	synchronized public DriverManagerDataSource getDataSource() throws SQLException
	{
		if (dataSourceCache==null)
		{
	        logger.info("Creating data source for '" + config.getIngestionJDBCURL() + "'...");
	        Properties connectionProperties = new Properties();
	        connectionProperties.setProperty("user", config.getIngestionJDBCUserName());
	        connectionProperties.setProperty("password", config.getIngestionJDBCPassword());

	        dataSourceCache = new DriverManagerDataSource(config.getIngestionJDBCURL(), connectionProperties);
		}
        
        return dataSourceCache;
    }
	
	/*
	 * This method will prepare the statement on TABLE_SELECT and use that to:
	 * - See how many columns the table has
	 * - Create the paramRandomValues and paramDataTypes based on the number of columns
	 * - Loop on each column and create 1000 random values for it.
	 */
	public synchronized void initializeRandomMapping(Connection connection) throws SQLException, IOException
	{
		int type;
		int precision;
		int shorterPrecision;
		//String typeName;
		
		if (randomMappingInitialized)
			return;
		
		PreparedStatement preparedStatement = connection.prepareStatement(config.getQueryStatement());
		ResultSet resultSet = preparedStatement.executeQuery();
		
		ResultSetMetaData metaData = resultSet.getMetaData();
		
		int columnCount = metaData.getColumnCount();
		
		// There is up to 40 types in java.sql.Types. We won't use all of these slots.
		paramRandomValues = new Object[columnCount+1][1000];
		paramSizeInBytes = new long[columnCount+1][1000];
		paramDataTypes = new int[columnCount+1];
		
		for(int column=1; column <= columnCount; column++)
		{
			type = metaData.getColumnType(column);
			paramDataTypes[column]=type;
			
			precision = metaData.getPrecision(column);
			//typeName = metaData.getColumnTypeName(column);
			
			switch (type)
			{
			case java.sql.Types.VARCHAR:
				for (int i=0; i<1000; i++)
				{
					shorterPrecision = (int) (precision*Math.random());
					if (shorterPrecision==0) shorterPrecision=1;
					paramRandomValues[column][i] = Util.randomAlphaNumeric(shorterPrecision);
					paramSizeInBytes[column][i] = ((String)paramRandomValues[column][i]).getBytes().length;
				}
				break;
				
			case java.sql.Types.TIMESTAMP:
				
				for (int i=0; i<1000; i++)
				{
					paramRandomValues[column][i] = Util.randomTimeStamp();
					// Not sure if that is the correct size that goes on the wire. But it must be a good approximation?
					paramSizeInBytes[column][i] = ((java.sql.Timestamp)paramRandomValues[column][i]).toString().getBytes().length;
				}
				break;
				
			case java.sql.Types.BIGINT:
				for (int i=0; i<1000; i++)
				{
					paramRandomValues[column][i] = Math.round(Math.random()*Long.MAX_VALUE);
					paramSizeInBytes[column][i] = Long.BYTES;
				}
				break;
				
			}
		}
				
		randomMappingInitialized = true;
	}
	
	/*
	 * Populates a prepared statement with appropriate random data for each field. Random data is get from
	 * the paramRandomValues array that was initialized by initializeRandomMapping().
	 * This prevents us from generating too many random objects which would cause the Garbage Collector to panic.
	 */
	public static long pupulatePreparedStatement(int parameterCount, long recordNum, String threadPrefix, PreparedStatement preparedStatement) throws SQLException
	{
		Object randomValue = null;
		String param1;
		int numberOfRandomValues = 999;
		int randomIndex = (int) (numberOfRandomValues*Math.random());
		
		// param 1:
		param1 = threadPrefix + "" + recordNum;
		preparedStatement.setObject(1, param1);
		long recordSize=Character.BYTES+Long.BYTES;
		
		// rest of parameters:
		for(int param=2; param <= parameterCount; param++)
		{
			randomValue = paramRandomValues[param][randomIndex];
			
			preparedStatement.setObject(param, randomValue);
			
			recordSize+=paramSizeInBytes[param][randomIndex];
		}
		
		return recordSize;
	}
    
	public void createTable(Connection connection) throws SQLException, Exception
	{
		createSchema(connection);
		
		logger.info("Creating table ...");
		PreparedStatement statement = connection.prepareStatement(config.getTableCreateStatement());
	    statement.execute();
	    statement.close();
	}

	public void createSchema(Connection connection) throws Exception, SQLException
	{
		logger.info("Creating schema...");
		String schemaName;
		
		String createTableStatement = config.getTableCreateStatement();
		
		Pattern p = Pattern.compile("CREATE +TABLE +((\\S)*)\\.");
		Matcher m = p.matcher(createTableStatement);
		if (m.find())
		{
			schemaName = m.group( 1 ); //group 0 is always the entire match   
		}
		else
		{
			throw new Exception("Could not find schema name on create table statement: " + createTableStatement);
		}
		
		logger.info("Creating schema " + schemaName);
		
		try
		{
			PreparedStatement statement = connection.prepareStatement("create schema " + schemaName + " owned by " + config.getIngestionJDBCUserName());
		    statement.execute();
		    statement.close();
			
		}
		catch (JDBCDriverException e)
		{
			if (e.getErrorCode()==386)
			{
				// Good. It is there already.
			}
			else 
			{
				throw e;
			}
		}
	}

	public void dropTable(Connection connection) throws SQLException
	{
		PreparedStatement statement = connection.prepareStatement(config.getTableDropStatement());
	    statement.execute();
	    statement.close();
	}
	
	public void truncateTable(Connection connection) throws SQLException, IOException
	{
		PreparedStatement statement = connection.prepareStatement(config.getTableTruncateStatement());
	    statement.execute();
	    statement.close();
	}
}
