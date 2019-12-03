package com.irisdemo.htap.config;

import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.web.servlet.context.ServletWebServerInitializedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Scope;
import org.springframework.core.annotation.Order;
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

    private void registerWithMasterAndGetConfig() throws Exception
    {
    	String registrationUrl = "http://" + config.getMasterHostName()+":"+config.getMasterPort()+"/master/ingestworker/register/" + config.getThisHostName() + ":" + config.getThisServerPort();
    	
    	logger.info("Registering with " + registrationUrl);
    	
    	RESTWorkerConfig workerConfig = restTemplate.getForObject(
				registrationUrl
				, RESTWorkerConfig.class);
    	
		config.setWorkerNodePrefix(workerConfig.workerNodePrefix);
		config.setIngestionBatchSize(workerConfig.config.ingestionBatchSize);
		config.setIngestionJDBCPassword(workerConfig.config.ingestionJDBCPassword);
		config.setIngestionJDBCURL(workerConfig.config.ingestionJDBCURL);
		config.setIngestionJDBCUserName(workerConfig.config.ingestionJDBCUserName);
		config.setIngestionNumThreadsPerWorker(workerConfig.config.ingestionNumThreadsPerWorker);
		
		config.setInsertStatement(workerConfig.config.insertStatement);
		config.setQueryStatement(workerConfig.config.queryStatement);
		config.setQueryByIdStatement(workerConfig.config.queryByIdStatement);
		config.setTableCreateStatement(workerConfig.config.tableCreateStatement);
		config.setTableDropStatement(workerConfig.config.tableDropStatement);
		config.setTableTruncateStatement(workerConfig.config.tableTruncateStatement);
		config.setIrisProcDisableJournal(workerConfig.config.irisProcDisableJournal);
		config.setIrisProcDisableJournalDrop(workerConfig.config.irisProcDisableJournalDrop);
		
		logger.info("Registration successful. Configuration data received and stored.");
    }
    
}