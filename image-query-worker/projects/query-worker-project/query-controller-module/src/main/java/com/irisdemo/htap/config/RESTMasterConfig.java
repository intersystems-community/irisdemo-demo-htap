package com.irisdemo.htap.config;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class RESTMasterConfig 
{
	/* 
	GENERAL CONFIGURATION 
	*/
	
	/* 
	CONSUMPTION CONFIGURATION 
	*/
	public String consumptionJDBCURL;
	public String consumptionJDBCUserName;
	public String consumptionJDBCPassword;
	public int consumptionNumThreadsPerWorker;
	public int consumptionTimeBetweenQueriesInMillis;
	public String queryStatement;
	public String queryByIdStatement;
	public int consumptionNumOfKeysToFetch;
}
