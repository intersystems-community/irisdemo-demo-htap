package com.irisdemo.htap.worker;

public abstract class Worker
{
    protected String hostname;

    protected int workerNumber;
    
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

    public int getWorkerNumber()
    {
        return this.workerNumber;
    }

    public void setWorkerNumber(int workerNumber)
    {
        this.workerNumber = workerNumber;
    }
}