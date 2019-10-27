package com.irisdemo.htap.config;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class RESTMasterConfig 
{
	/* 
	GENERAL CONFIGURATION 
	*/
	public int runningTimeInSeconds;
	public boolean startConsumers;
	
	/* 
	INGESTION CONFIGURATION 
	*/
	public String ingestionJDBCURL;
	public String ingestionJDBCUserName;
	public String ingestionJDBCPassword;
	public int ingestionBatchSize;
	public int ingestionNumThreadsPerWorker;
	public String insertStatement;

	/* 
	CONSUMPTION CONFIGURATION 
	*/
	public String consumptionJDBCURL;
	public String consumptionJDBCUserName;
	public String consumptionJDBCPassword;
	public String consumptionProgression;
	public int consumptionTimeBetweenQueriesInMillis;
	public String queryStatement;
	public String queryByIdStatement;
}
