package com.irisdemo.htap.config;

import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Scope;
import org.springframework.core.annotation.Order;
import org.springframework.web.client.RestTemplate;

@Service
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
@Order(value=0) //Before the DatabaseService is created (it needs these configurations from the master)
public class ConfigService implements CommandLineRunner
{
    @Autowired
    Config config;
    
    @Autowired
    RestTemplate restTemplate;
    
    Logger logger = LoggerFactory.getLogger(ConfigService.class);
    
    private void registerWithMasterAndGetConfig() throws Exception
    {
    	String registrationUrl = "http://" + config.getMasterHostName()+":"+config.getMasterPort()+"/master/queryworker/register/" + config.getThisHostName() + ":" + config.getMasterPort();
    	
    	logger.info("Registering with " + registrationUrl);
    	
    	RESTWorkerConfig workerConfig = restTemplate.getForObject(
				registrationUrl
				, RESTWorkerConfig.class);
    	
		config.setWorkerNodePrefix(workerConfig.workerNodePrefix);
    	config.setConsumptionJDBCPassword(workerConfig.config.consumptionJDBCPassword);
		config.setConsumptionJDBCURL(workerConfig.config.consumptionJDBCURL);
		config.setConsumptionJDBCUserName(workerConfig.config.consumptionJDBCUserName);
		config.setConsumptionNumThreadsPerWorker(workerConfig.config.consumptionNumThreadsPerWorker);
		config.setConsumptionTimeBetweenQueriesInMillis(workerConfig.config.runningTimeInSeconds);
		config.setIngestionBatchSize(workerConfig.config.ingestionBatchSize);
		config.setIngestionJDBCPassword(workerConfig.config.ingestionJDBCPassword);
		config.setIngestionJDBCURL(workerConfig.config.ingestionJDBCURL);
		config.setIngestionJDBCUserName(workerConfig.config.ingestionJDBCUserName);
		config.setIngestionNumThreadsPerWorker(workerConfig.config.ingestionNumThreadsPerWorker);
		config.setInsertStatement(workerConfig.config.insertStatement);
		config.setQueryStatement(workerConfig.config.queryStatement);
		config.setQueryByIdStatement(workerConfig.config.queryByIdStatement);
		
		logger.info("Registration successful. Configuration data received and stored.");
    }
    
    @Override
    public void run(String...args) throws Exception 
    {
        registerWithMasterAndGetConfig();
    }
}