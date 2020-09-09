package com.irisdemo.htap.worker.oracle;

import java.io.IOException;
import java.math.BigInteger;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
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

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class WorkerDBUtils {
	protected static Logger logger = LoggerFactory.getLogger(WorkerDBUtils.class);

	@Autowired
	protected Config config;

	protected static Object[][] paramRandomValues;

	protected static int[] paramDataTypes;

	protected static long[][] paramSizeInBytes;

	protected static boolean randomMappingInitialized = false;

	protected static DriverManagerDataSource dataSourceCache = null;

	/**
	 * I could not make this a Bean. It would get created before we had fetched the
	 * connection information from the master.
	 * 
	 * This method can't be static because it relies on the auto-wiring of config to
	 * work.
	 * 
	 * @return
	 * @throws SQLException
	 * @throws IOException
	 */
	synchronized public DriverManagerDataSource getDataSource() throws SQLException, ClassNotFoundException {
		if (dataSourceCache == null) {
			logger.info("Creating data source for '" + config.getIngestionJDBCURL() + "'...");

			Class.forName("oracle.jdbc.driver.OracleDriver");
			dataSourceCache = new DriverManagerDataSource(config.getIngestionJDBCURL(), new Properties());
		}

		return dataSourceCache;
	}

	/*
	 * This method will prepare the statement on TABLE_SELECT and use that to: - See
	 * how many columns the table has - Create the paramRandomValues and
	 * paramDataTypes based on the number of columns - Loop on each column and
	 * create 1000 random values for it.
	 */
	public synchronized void initializeRandomMapping(Connection connection) throws SQLException, IOException {
		int type;
		int precision;
		int shorterPrecision;
		// String typeName;

		if (randomMappingInitialized)
			return;

		PreparedStatement preparedStatement = connection
				.prepareStatement(config.getQueryStatement().replace("SpeedTest.", ""));
		ResultSet resultSet = preparedStatement.executeQuery();

		ResultSetMetaData metaData = resultSet.getMetaData();

		int columnCount = metaData.getColumnCount();

		// There is up to 40 types in java.sql.Types. We won't use all of these slots.
		paramRandomValues = new Object[columnCount + 1][1000];
		paramSizeInBytes = new long[columnCount + 1][1000];
		paramDataTypes = new int[columnCount + 1];

		for (int column = 1; column <= columnCount; column++) {
			type = metaData.getColumnType(column);
			paramDataTypes[column] = type;

			precision = metaData.getPrecision(column);
			// typeName = metaData.getColumnTypeName(column);
			logger.info("The type is: " + type);
			switch (type) {
				case java.sql.Types.VARCHAR:
					for (int i = 0; i < 1000; i++) {
						shorterPrecision = (int) (precision * Math.random());
						if (shorterPrecision == 0)
							shorterPrecision = 1;
						paramRandomValues[column][i] = Util.randomAlphaNumeric(shorterPrecision);
						paramSizeInBytes[column][i] = ((String) paramRandomValues[column][i]).getBytes().length;
					}
					break;

				case java.sql.Types.TIMESTAMP:
					for (int i = 0; i < 1000; i++) {
						paramRandomValues[column][i] = Util.randomTimeStamp();
						// Not sure if that is the correct size that goes on the wire. But it must be a
						// good approximation?
						paramSizeInBytes[column][i] = ((java.sql.Timestamp) paramRandomValues[column][i]).toString()
								.getBytes().length;
					}
					break;

				case java.sql.Types.NUMERIC:
					for (int i = 0; i < 1000; i++) {
						paramRandomValues[column][i] = Math.round(Math.random() * Long.MAX_VALUE);
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
		PreparedStatement statement = null;
		
		// This primary key is unique, but not sequential. SQL Server performs very badly with
		// clustered primary keys that are non sequential
		String createTableStatement = config.getTableCreateStatement().replace("SpeedTest.", "").replace("BIGINT", "NUMBER(19,0)").replace("DATETIME", "TIMESTAMP").replace("VARCHAR", "VARCHAR2");

		try
		{
			logger.info("Creating table ...");
			statement = connection.prepareStatement(createTableStatement);
			statement.execute();
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

	public void dropTable(Connection connection) throws SQLException
	{
		PreparedStatement statement = null;

		try
		{
			statement = connection.prepareStatement(config.getTableDropStatement().replace("SpeedTest.", ""));
			statement.execute();
		}
		catch (SQLException exception)
		{
			if (exception.getMessage().contains("does not exist"))
			{
				
			}
			else
			{
				throw exception;
			}
		}
		finally
		{
			if (statement!=null)
				statement.close();
		}
	}
	
	public void truncateTable(Connection connection) throws SQLException, IOException
	{
		PreparedStatement statement = null;

		try
		{
			statement = connection.prepareStatement(config.getTableTruncateStatement().replace("SpeedTest.", ""));
			statement.execute();
		}
		catch (SQLException exception)
		{
			throw exception;
		}
		finally
		{
			if (statement!=null)
				statement.close();
		}
	}

	public void createDatabase(Connection connection, String databaseName,int initialDatabaseSize) throws Exception, SQLException
	{
		Statement statement = null;

		String sqlCommand = "CREATE DATABASE " + databaseName;
		
		logger.info("Creating database: " + sqlCommand);

		try
		{
			statement = connection.createStatement();
			statement.execute(sqlCommand);
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

	public boolean databaseExists(Connection connection, String databaseName) throws SQLException
	{
		boolean exists = false;
		
		Statement statement = connection.createStatement();

		try
		{
			
			ResultSet rs = statement.executeQuery("SELECT INSTANCE_NAME, STATUS, DATABASE_STATUS FROM V$INSTANCE WHERE INSTANCE_NAME='" + databaseName + "'");

			if (rs.next())
			{
				logger.info("Database, " + rs.getString(1) + ": exists.");
				exists=true;
			}
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
		
		return exists;
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

}
