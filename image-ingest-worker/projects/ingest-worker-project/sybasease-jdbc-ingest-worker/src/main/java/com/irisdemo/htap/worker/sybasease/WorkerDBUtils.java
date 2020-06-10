package com.irisdemo.htap.worker.sybasease;

import java.io.IOException;
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
	synchronized public DriverManagerDataSource getDataSource() throws SQLException, ClassNotFoundException
	{
		if (dataSourceCache==null)
		{
			logger.info("Creating data source for '" + config.getIngestionJDBCURL() + "'...");
			
			//jdbc:jtds:sybase://localhost:5000/myDB
			Class.forName("net.sourceforge.jtds.jdbc.Driver");

	        Properties connectionProperties = new Properties();
	        connectionProperties.setProperty("user", config.getIngestionJDBCUserName());
			connectionProperties.setProperty("password", config.getIngestionJDBCPassword());

			// All connections will be created on the master database. That will be used to setup the SPEEDTEST
			// database, SpeedTest Schema and SpeedTest.Account table. The database will be pre-expanded.
			// The MSSQLWorker.java class will USE SPEEDTEST to do the inserts on the right database.
			connectionProperties.setProperty("databaseName", "master");

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
		PreparedStatement statement = null;
		
		// This primary key is unique, but not sequential. SQL Server performs very badly with
		// clustered primary keys that are non sequential
		String createTableStatement = config.getTableCreateStatement().replace("PRIMARY KEY", "PRIMARY KEY NONCLUSTERED");

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

	public void createSchema(Connection connection) throws Exception, SQLException
	{
		PreparedStatement statement = null;

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
			statement = connection.prepareStatement("create schema " + schemaName);
		    statement.execute();
		}
		catch (SQLException e)
		{
			if (e.getMessage().contains("There is already an object named"))
			{
				// Good. It is there already.
			}
			else 
			{
				throw e;
			}
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
			statement = connection.prepareStatement(config.getTableDropStatement());
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
			statement = connection.prepareStatement(config.getTableTruncateStatement());
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

	public String getFolderSeparatorForDBPlatform(Connection connection) throws SQLException
	{
		if (isRunningOnLinux(connection))
		{
			return "/";
		}

		return "\\";
	}

	public String getDataFolderName(Connection connection) throws SQLException, Exception
	{		
		String dataFolderName = "";

		String folderSeparator = getFolderSeparatorForDBPlatform(connection);
		logger.info("Folder separator for this platform is '" + folderSeparator + "'.");

		Statement statement = connection.createStatement();

		try
		{
			
			ResultSet rs = statement.executeQuery("SELECT physical_name FROM sys.database_files");
			if (rs.next())
			{ 
				String masterDatabaseFile = rs.getString(1);

				int lastPositionOfFolderSeparator = masterDatabaseFile.lastIndexOf(folderSeparator)+1;

				dataFolderName = masterDatabaseFile.substring(0, lastPositionOfFolderSeparator);
				logger.info("Databases files must be created at: " + dataFolderName);
			}
			else
			{
				throw new Exception("Could not find where master database file is on this.");
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
		
		return dataFolderName;
	}

	public void createDatabase(Connection connection, String databaseName,int initialDatabaseSize) throws Exception, SQLException
	{
		String folderName;
		String folderSeparator;
		String databaseFileName;
		String logFileName;
		Statement statement = null;

		int initialLogSize = initialDatabaseSize*3;

		folderName = getDataFolderName(connection);

		databaseFileName=folderName + "SPEEDTEST.mdf";
		logFileName=folderName + "SPEEDTEST.ldf";

		logger.info("Creating database " + databaseFileName + "...");

		// We are in the MASTER database, so we are safe to do this
		String sqlCommand = "CREATE DATABASE " + databaseName + " ON " +   
		"( NAME = SPEEDTEST_DAT,  " +
		"	FILENAME = '"+ databaseFileName +"', "+
		"	SIZE = "+initialDatabaseSize+"GB, "+
		"	MAXSIZE = UNLIMITED, "+  
		"	FILEGROWTH = 50 MB)  "+ 
		"LOG ON   "+
		"( NAME = SPEEDTEST_LOG,   "+
		"	FILENAME = '"+logFileName+"', "+
		"	SIZE = "+initialLogSize+"GB, "+
		"	MAXSIZE = UNLIMITED, "+ 
		"	FILEGROWTH = 5MB );";
		
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

	public void changeDatabase(Connection connection, String databaseName) throws SQLException
	{
		logger.info("Changing to database " + databaseName + "...");
		Statement statement = connection.createStatement();
		try
		{
			statement.execute("USE " + databaseName);
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


	// If it is running on Linux, it is propably on a container in a user's PC
	// so there is no gain in picking a proper file system for the database and 
	// transaction logs. 
	// But if we are running on a proper server on AWS, we should pick the best 
	// place possible for the database and transaction logs.
	public boolean isRunningOnLinux(Connection connection) throws SQLException
	{
		boolean isRunningOnLinux = false;
		
		Statement statement = connection.createStatement();

		try
		{
			
			ResultSet rs = statement.executeQuery("SELECT @@VERSION");
			rs.next();

			if (rs.getString(1).contains("Linux"))
			{
				isRunningOnLinux=true;
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
		
		return isRunningOnLinux;
	}

	public boolean databaseExists(Connection connection, String databaseName) throws SQLException
	{
		boolean exists = false;
		
		Statement statement = connection.createStatement();

		try
		{
			
			ResultSet rs = statement.executeQuery("SELECT name FROM master.dbo.sysdatabases where name='" + databaseName +"'");

			if (rs.next())
			{
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

	public void setReadUncommitted(Connection connection) throws SQLException
	{
		PreparedStatement statement = null;
		
		try
		{
			logger.info("SET TRANSACTION ISOLATION LEVEL");
			connection.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
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
