package com.irisdemo.htap.config;

public class WorkerConfig
{
	private String workerNodePrefix;
	private boolean electedToPrepareDatabase;
	private Config config;
	
	public WorkerConfig(Config config, String workerNodePrefix, boolean electedToPrepareDatabase)
	{
		this.config=config;
		this.workerNodePrefix=workerNodePrefix;
		this.electedToPrepareDatabase=electedToPrepareDatabase;
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
	
	public void setElectedToPrepareDatabase(boolean electedToPrepareDatabase)
	{
		this.electedToPrepareDatabase=electedToPrepareDatabase;
	}
	
	public boolean getElectedToPrepareDatabase()
	{
		return this.electedToPrepareDatabase;
	}
}
