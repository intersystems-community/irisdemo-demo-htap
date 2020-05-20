package com.irisdemo.htap;

import java.io.IOException;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.client.RestTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@EnableScheduling
@SpringBootApplication
@Configuration
@EnableAsync
//@ComponentScan({"com.irisdemo.UI", "com.irisdemo.HTAP"})
public class App implements ApplicationRunner
{	
	Logger logger = LoggerFactory.getLogger(App.class);
	
	/*
	 * This bean is used by the ConfigService to register with the master and get the configuration.
	 * Every service that needs to call a REST service, just needs to have a RestTemplate injected in
	 * order to do so.
	 */
    @Bean
	public RestTemplate restTemplate(RestTemplateBuilder builder) 
    {
    	return builder.build();
	}
    
	public static void main(String[] args) throws IOException
	{
		SpringApplication app = new SpringApplication(App.class);
		        
		ConfigurableApplicationContext ctx = app.run(args);
		
        /// This will terminate the app after run() is done.
		//ctx.close();
    }
    
	public void run(ApplicationArguments args) 
	{	
		try
		{
			//ui.run();
			// This will stop Spring
			//context.close();
			
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
