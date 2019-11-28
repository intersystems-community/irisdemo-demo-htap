package com.irisdemo.htap.config;

public class WorkerConfig
{
	private String workerNodePrefix;
	private Config config;
	
	public WorkerConfig(Config config, String workerNodePrefix)
	{
		this.config=config;
		this.workerNodePrefix=workerNodePrefix;
	}
	
	public Config getConfig()
	{
		return config;
	}
	
	public void setWorkerNodePrefix(String workerNodePrefix)
	{
		this.workerNodePrefix=workerNodePrefix;
	}
	
	public String getWorkerNodePrefix()
	{
		return this.workerNodePrefix;
	}
}
