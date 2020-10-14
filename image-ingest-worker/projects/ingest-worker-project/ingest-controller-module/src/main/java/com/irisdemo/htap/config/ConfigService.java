package com.irisdemo.htap.config;

import org.springframework.stereotype.Service;

import java.net.InetAddress;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.web.servlet.context.ServletWebServerInitializedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Scope;
import org.springframework.core.annotation.Order;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class ConfigService implements ApplicationListener<ServletWebServerInitializedEvent>
{
    @Autowired
    Config config;
    
    @Autowired
    RestTemplate restTemplate;
    
    Logger logger = LoggerFactory.getLogger(ConfigService.class);
    
	@Override
	public void onApplicationEvent(final ServletWebServerInitializedEvent event)
	{
		config.setThisServerPort(event.getWebServer().getPort());
		
		try 
		{
			registerWithMasterAndGetConfig();
		} 
		catch (Exception e) {
			logger.error(e.getMessage());
			System.exit(1);
		}
	}

    public void registerWithMasterAndGetConfig() throws Exception
    {		
		try
		{
			InetAddress inet = InetAddress.getByName(config.getThisHostName());
			String hostIP = inet.getHostAddress();
	
			String registrationUrl = "http://" + config.getMasterHostName()+":"+config.getMasterPort()+"/master/ingestworker/register/" + hostIP + ":" + config.getThisServerPort();
			logger.info("Registering with " + registrationUrl);
			
			RESTWorkerConfig workerConfig = restTemplate.getForObject(registrationUrl, RESTWorkerConfig.class);

			config.setWorkerNodePrefix(workerConfig.workerNodePrefix);
			config.setIngestionBatchSize(workerConfig.config.ingestionBatchSize);
			config.setIngestionJDBCPassword(workerConfig.config.ingestionJDBCPassword);
			config.setIngestionJDBCURL(workerConfig.config.ingestionJDBCURL);
			config.setIngestionJDBCUserName(workerConfig.config.ingestionJDBCUserName);
			config.setIngestionNumThreadsPerWorker(workerConfig.config.ingestionNumThreadsPerWorker);
			config.setIngestionWaitTimeBetweenBatchesInMillis(workerConfig.config.ingestionWaitTimeBetweenBatchesInMillis);
			
			config.setInsertStatement(workerConfig.config.insertStatement);
			config.setQueryStatement(workerConfig.config.queryStatement);
			config.setQueryByIdStatement(workerConfig.config.queryByIdStatement);
			config.setTableCreateStatement(workerConfig.config.tableCreateStatement);
			config.setTableDropStatement(workerConfig.config.tableDropStatement);
			config.setTableTruncateStatement(workerConfig.config.tableTruncateStatement);
			config.setIrisProcDisableJournal(workerConfig.config.irisProcDisableJournal);
			config.setIrisProcDisableJournalDrop(workerConfig.config.irisProcDisableJournalDrop);
			config.setIrisProcEnableCallInService(workerConfig.config.irisProcEnableCallInService);
			
			config.setDatabaseSizeInGB(workerConfig.config.databaseSizeInGB);
			
			logger.info("Registration successful. Configuration data received and stored.");
		}
		catch (RestClientException restException)
		{
			logger.info("Could not register: " + restException.getMessage());
			System.exit(-1);
		}
    	
	} 
}