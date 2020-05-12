package com.irisdemo.htap;

import com.irisdemo.htap.worker.AccumulatedIngestMetrics;
import com.irisdemo.htap.worker.AccumulatedQueryMetrics;

public class Metrics 
{
    private int speedTestRunningStatus;
    private int runTimeInSeconds;
    private int numberOfActiveIngestionThreads;

    private double numberOfRowsIngested;
    private double recordsIngestedPerSec;
    private double avgRecordsIngestedPerSec;

    private double MBIngested;
    private double MBIngestedPerSec;    
    private double avgMBIngestedPerSec;

    private double numberOfRowsConsumed;
    private int numberOfActiveQueryThreads;
    private double recordsConsumedPerSec;
    private double avgRecordsConsumedPerSec;

    private double MBConsumed;
    private double MBConsumedPerSec;
    private double avgMBConsumedPerSec;

    private double queryAndConsumptionTimeInMs;
    private double avgQueryAndConsumptionTimeInMs;
    
    public Metrics(int speedTestRunningStatus, int runTime, AccumulatedIngestMetrics accumulatedIngestMetrics, AccumulatedQueryMetrics accumulatedQueryMetrics)
    {
        this.speedTestRunningStatus = speedTestRunningStatus;
        this.runTimeInSeconds = runTime;
        populateMetrics(accumulatedIngestMetrics, accumulatedQueryMetrics);
    }

    public Metrics(int speedTestRunningStatus)
    {
        this.speedTestRunningStatus = speedTestRunningStatus;
        this.runTimeInSeconds = 0;
    }

    private void populateMetrics(AccumulatedIngestMetrics accumulatedIngestMetrics, AccumulatedQueryMetrics accumulatedQueryMetrics)
    {
        this.numberOfActiveIngestionThreads = accumulatedIngestMetrics.getNumberOfActiveIngestionThreads();
    	this.numberOfRowsIngested=accumulatedIngestMetrics.getNumberOfRowsIngested();
    	this.recordsIngestedPerSec=accumulatedIngestMetrics.getRecordsIngestedPerSec();
    	this.avgRecordsIngestedPerSec=accumulatedIngestMetrics.getAvgRecordsIngestedPerSec();

    	this.MBIngested=accumulatedIngestMetrics.getMBIngested();
    	this.MBIngestedPerSec=accumulatedIngestMetrics.getMBIngestedPerSec();
    	this.avgMBIngestedPerSec=accumulatedIngestMetrics.getAvgMBIngestedPerSec();
        
        this.numberOfActiveQueryThreads = accumulatedQueryMetrics.getNumberOfActiveQueryThreads();
    	this.numberOfRowsConsumed=accumulatedQueryMetrics.getNumberOfRowsConsumed();
    	this.recordsConsumedPerSec=accumulatedQueryMetrics.getRecordsConsumedPerSec();
    	this.avgRecordsConsumedPerSec=accumulatedQueryMetrics.getAvgRecordsConsumedPerSec();
    	
    	this.MBConsumed=accumulatedQueryMetrics.getMBConsumed();
    	this.MBConsumedPerSec=accumulatedQueryMetrics.getMBConsumedPerSec();
    	this.avgMBConsumedPerSec=accumulatedQueryMetrics.getAvgMBConsumedPerSec();
        
        this.queryAndConsumptionTimeInMs=accumulatedQueryMetrics.getQueryAndConsumptionTimeInMillis();
    	this.avgQueryAndConsumptionTimeInMs=accumulatedQueryMetrics.getAvgQueryAndConsumptionTimeInMillis();
    }

    public String toString()
    {
        StringBuffer str = new StringBuffer();
        str.append(this.runTimeInSeconds);
        str.append(",");
        str.append(this.numberOfActiveIngestionThreads);
        str.append(",");
        str.append(this.numberOfRowsIngested);
        str.append(",");
        str.append(this.recordsIngestedPerSec);
        str.append(",");
    	str.append(this.avgRecordsIngestedPerSec);
        str.append(",");
        str.append(this.MBIngested);
        str.append(",");
        str.append(this.MBIngestedPerSec);
        str.append(",");
    	str.append(this.avgMBIngestedPerSec);
    	str.append(",");
        str.append(this.numberOfRowsConsumed);
        str.append(",");
        str.append(this.numberOfActiveQueryThreads);
        str.append(",");
        str.append(this.recordsConsumedPerSec);
        str.append(",");
    	str.append(this.avgRecordsConsumedPerSec);
    	str.append(",");
        str.append(this.MBConsumed);
        str.append(",");
        str.append(this.MBConsumedPerSec);
        str.append(",");
    	str.append(this.avgMBConsumedPerSec);
    	str.append(",");
        str.append(this.queryAndConsumptionTimeInMs);
    	str.append(",");
        str.append(this.avgQueryAndConsumptionTimeInMs);

        return str.toString();
    }

    public int getNumberOfActiveIngestionThreads()
    {
        return this.numberOfActiveIngestionThreads;
    }

    public int getRunTimeInSeconds()
    {
        return this.runTimeInSeconds;
    }

    public int getSpeedTestRunningStatus()
    {
        return this.speedTestRunningStatus;
    }

    public double getNumberOfRowsIngested() {
        return numberOfRowsIngested;
    }

    public void setNumberOfRowsIngested(double numberOfRowsIngested) {
        this.numberOfRowsIngested = numberOfRowsIngested;
    }

    public double getRecordsIngestedPerSec() {
        return recordsIngestedPerSec;
    }

    public void setRecordsIngestedPerSec(double recordsIngestedPerSec) {
        this.recordsIngestedPerSec = recordsIngestedPerSec;
    }

    public double getAvgRecordsIngestedPerSec() {
        return avgRecordsIngestedPerSec;
    }

    public void setAvgRecordsIngestedPerSec(double avgRecordsIngestedPerSec) {
        this.avgRecordsIngestedPerSec = avgRecordsIngestedPerSec;
    }

    public double getMBIngested() {
        return MBIngested;
    }

    public void setMBIngested(double mBIngested) {
        MBIngested = mBIngested;
    }

    public double getMBIngestedPerSec() {
        return MBIngestedPerSec;
    }

    public void setMBIngestedPerSec(double mBIngestedPerSec) {
        MBIngestedPerSec = mBIngestedPerSec;
    }

    public double getAvgMBIngestedPerSec() {
        return avgMBIngestedPerSec;
    }

    public void setAvgMBIngestedPerSec(double avgMBIngestedPerSec) {
        this.avgMBIngestedPerSec = avgMBIngestedPerSec;
    }

    public double getNumberOfRowsConsumed() {
        return numberOfRowsConsumed;
    }

    public void setNumberOfRowsConsumed(double numberOfRowsConsumed) {
        this.numberOfRowsConsumed = numberOfRowsConsumed;
    }

    public double getRecordsConsumedPerSec() {
        return recordsConsumedPerSec;
    }

    public void setRecordsConsumedPerSec(double recordsConsumedPerSec) {
        this.recordsConsumedPerSec = recordsConsumedPerSec;
    }

    public double getAvgRecordsConsumedPerSec() {
        return avgRecordsConsumedPerSec;
    }

    public void setAvgRecordsConsumedPerSec(double avgRecordsConsumedPerSec) {
        this.avgRecordsConsumedPerSec = avgRecordsConsumedPerSec;
    }

    public double getMBConsumed() {
        return MBConsumed;
    }

    public void setMBConsumed(double mBConsumed) {
        MBConsumed = mBConsumed;
    }

    public double getMBConsumedPerSec() {
        return MBConsumedPerSec;
    }

    public void setMBConsumedPerSec(double mBConsumedPerSec) {
        MBConsumedPerSec = mBConsumedPerSec;
    }

    public double getAvgMBConsumedPerSec() {
        return avgMBConsumedPerSec;
    }

    public void setAvgMBConsumedPerSec(double avgMBConsumedPerSec) {
        this.avgMBConsumedPerSec = avgMBConsumedPerSec;
    }

    public double getQueryAndConsumptionTimeInMs() {
        return queryAndConsumptionTimeInMs;
    }

    public void setQueryAndConsumptionTimeInMs(double queryAndConsumptionTimeInMs) {
        this.queryAndConsumptionTimeInMs = queryAndConsumptionTimeInMs;
    }

    public double getAvgQueryAndConsumptionTimeInMs() {
        return avgQueryAndConsumptionTimeInMs;
    }

    public void setAvgQueryAndConsumptionTimeInMs(double avgQueryAndConsumptionTimeInMs) {
        this.avgQueryAndConsumptionTimeInMs = avgQueryAndConsumptionTimeInMs;
    }
}