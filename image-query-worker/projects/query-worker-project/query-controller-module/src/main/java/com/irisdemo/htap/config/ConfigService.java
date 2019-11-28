package com.irisdemo.htap.config;

import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.boot.web.servlet.context.ServletWebServerInitializedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Scope;
import org.springframework.core.annotation.Order;
import org.springframework.web.client.RestTemplate;

@Service
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
@Order(value=0) //Before the DatabaseService is created (it needs these configurations from the master)
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
    	String registrationUrl = "http://" + config.getMasterHostName()+":"+config.getMasterPort()+"/master/queryworker/register/" + config.getThisHostName() + ":" + config.getThisServerPort();
    	
    	logger.info("Registering with " + registrationUrl);
    	
    	RESTWorkerConfig workerConfig = restTemplate.getForObject(
				registrationUrl
				, RESTWorkerConfig.class);
    	
		config.setWorkerNodePrefix(workerConfig.workerNodePrefix);
    	config.setConsumptionJDBCPassword(workerConfig.config.consumptionJDBCPassword);
		config.setConsumptionJDBCURL(workerConfig.config.consumptionJDBCURL);
		config.setConsumptionJDBCUserName(workerConfig.config.consumptionJDBCUserName);
		config.setConsumptionNumThreadsPerWorker(workerConfig.config.consumptionNumThreadsPerWorker);
		config.setConsumptionTimeBetweenQueriesInMillis(workerConfig.config.consumptionTimeBetweenQueriesInMillis);
		config.setQueryStatement(workerConfig.config.queryStatement);
		config.setQueryByIdStatement(workerConfig.config.queryByIdStatement);
		
		logger.info("Registration successful. Configuration data received and stored.");
    }
}