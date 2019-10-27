package com.irisdemo.htap.worker;

public abstract class Worker
{
    protected String hostname;
    
    private boolean isAvailable = true;

    public abstract String getWorkerType();

    public abstract void updateMetrics(MetricsType metrics);

    public String getHostname()
    {
        return this.hostname;
    }
    
    public void setAvailable(boolean isAvailable)
    {
    	this.isAvailable=isAvailable;
    }
    
    public boolean isAvailable()
    {
    	return this.isAvailable;
    }

}