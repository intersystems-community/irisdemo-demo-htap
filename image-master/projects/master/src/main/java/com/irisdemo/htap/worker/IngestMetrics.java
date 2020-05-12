package com.irisdemo.htap.worker;

public class IngestMetrics extends MetricsType
{
    protected int numberOfActiveIngestionThreads;

    protected double numberOfRowsIngested;

    protected double recordsIngestedPerSec;
    protected double avgRecordsIngestedPerSec;

    protected double MBIngested;

    protected double MBIngestedPerSec;    
    protected double avgMBIngestedPerSec;

    public int getNumberOfActiveIngestionThreads()
    {
        return this.numberOfActiveIngestionThreads;
    }

    public void setNumberOfActiveIngestionThreads(int numberOfActiveIngestionThreads)
    {
        this.numberOfActiveIngestionThreads = numberOfActiveIngestionThreads;
    }

    public double getNumberOfRowsIngested() {
        return numberOfRowsIngested;
    }

    synchronized public void setNumberOfRowsIngested(double numberOfRowsIngested) {
        this.numberOfRowsIngested = numberOfRowsIngested;
    }

    synchronized public double getRecordsIngestedPerSec() {
        return recordsIngestedPerSec;
    }

    synchronized public void setRecordsIngestedPerSec(double recordsIngestedPerSec) {
        this.recordsIngestedPerSec = recordsIngestedPerSec;
    }

    synchronized  public double getAvgRecordsIngestedPerSec() {
        return avgRecordsIngestedPerSec;
    }

    synchronized public void setAvgRecordsIngestedPerSec(double avgRecordsIngestedPerSec) {
        this.avgRecordsIngestedPerSec = avgRecordsIngestedPerSec;
    }

    synchronized public double getMBIngested() {
        return MBIngested;
    }

    synchronized public void setMBIngested(double mBIngested) {
        MBIngested = mBIngested;
    }

    synchronized public double getMBIngestedPerSec() {
        return MBIngestedPerSec;
    }

    synchronized public void setMBIngestedPerSec(double mBIngestedPerSec) {
        MBIngestedPerSec = mBIngestedPerSec;
    }

    synchronized public double getAvgMBIngestedPerSec() {
        return avgMBIngestedPerSec;
    }

    synchronized public void setAvgMBIngestedPerSec(double avgMBIngestedPerSec) {
        this.avgMBIngestedPerSec = avgMBIngestedPerSec;
    }
}