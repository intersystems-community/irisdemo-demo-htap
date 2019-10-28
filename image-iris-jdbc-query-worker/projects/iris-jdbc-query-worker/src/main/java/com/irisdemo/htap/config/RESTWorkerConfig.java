package com.irisdemo.htap.config;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class RESTWorkerConfig 
{
	public String workerNodePrefix;
	public RESTMasterConfig config;
}
