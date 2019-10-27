package com.irisdemo.htap.db;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import com.irisdemo.htap.config.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class DatabaseService implements CommandLineRunner
{
    @Autowired
    Config config;

    Logger logger = LoggerFactory.getLogger(DatabaseService.class);

    @Autowired 
    DriverManagerDataSource dataSource;
	
	@Bean("dataSource")
	public DriverManagerDataSource dataSource() throws SQLException, IOException
	{
        logger.info("Creating data source for '" + config.getIngestionJDBCURL() + "'...");
        Properties connectionProperties = new Properties();
        connectionProperties.setProperty("user", config.getIngestionJDBCUserName());
        connectionProperties.setProperty("password", config.getIngestionJDBCPassword());

        DriverManagerDataSource dataSource = new DriverManagerDataSource(config.getIngestionJDBCURL(), connectionProperties);
        
        return dataSource;
    }
	
    @Override
    public void run(String...args) throws Exception 
    {
		Connection connection = dataSource.getConnection();
		
		try
		{
            createDisableJournalProc(connection);

			createTable(connection);
			
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
    
	private void createDisableJournalProc(Connection connection) throws SQLException, IOException
	{
		try
		{
			Util.runStatementOnFile(connection, "IRIS_PROC_DISABLEJOURNAL_DROP.sql");	
		}
		catch (SQLException exception)
		{
			if (exception.getErrorCode()!=362) //Method '???' does not exist in any class
			{
				throw exception;
			}
		}
		
		Util.runStatementOnFile(connection, "IRIS_PROC_DISABLEJOURNAL.sql");
    }
    
	private void createTable(Connection connection) throws SQLException, IOException
	{
		try
		{
			if (config.getDisableJournalForDropTable())
			{
				//Temporarily Disable journal for a possible DROP TABLE of millions of records.
				Util.disableJournalForConnection(connection, true);
			}

			Util.runStatementOnFile(connection, "TABLE_DROP.sql");	

			if (config.getDisableJournalForDropTable())
			{
				// Turning journal back on
				Util.disableJournalForConnection(connection, false);
			}

		}
		catch (SQLException exception)
		{
			if (exception.getErrorCode()==30) //Table or view not found
			{
				
			}
			else if (exception.getMessage().startsWith("Unknown table"))
			{
				
			}
			else
			{
				throw exception;
			}
			
		}
		
		Util.runStatementOnFile(connection, "TABLE_CREATE.sql");
	}
    
	public void truncateTable() throws SQLException, IOException
	{
		Connection connection = dataSource.getConnection();
		if (config.getDisableJournalForTruncateTable())
		{
			Util.disableJournalForConnection(connection, true);
		}
		
		Util.runStatementOnFile(connection, "TABLE_TRUNCATE.sql");	
		
		if (config.getDisableJournalForTruncateTable())
		{
			Util.disableJournalForConnection(connection, false);
		}

		connection.close();
	}
}