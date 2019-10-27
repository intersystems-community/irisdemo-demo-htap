package com.irisdemo.htap;

import com.irisdemo.htap.worker.AccumulatedIngestMetrics;
import com.irisdemo.htap.worker.AccumulatedQueryMetrics;

public class Metrics 
{
    private double numberOfRowsIngested;
    private double recordsIngestedPerSec;
    private double avgRecordsIngestedPerSec;

    private double MBIngested;
    private double MBIngestedPerSec;    
    private double avgMBIngestedPerSec;

    private double numberOfRowsConsumed;
    private double recordsConsumedPerSec;
    private double avgRecordsConsumedPerSec;

    private double MBConsumed;
    private double MBConsumedPerSec;
    private double avgMBConsumedPerSec;

    private double queryAndConsumptionTimeInMs;
    private double avgQueryAndConsumptionTimeInMs;
    
    public Metrics(AccumulatedIngestMetrics accumulatedIngestMetrics, AccumulatedQueryMetrics accumulatedQueryMetrics)
    {
    	this.numberOfRowsIngested=accumulatedIngestMetrics.getNumberOfRowsIngested();
    	this.recordsIngestedPerSec=accumulatedIngestMetrics.getRecordsIngestedPerSec();
    	this.avgRecordsIngestedPerSec=accumulatedIngestMetrics.getAvgRecordsIngestedPerSec();

    	this.MBIngested=accumulatedIngestMetrics.getMBIngested();
    	this.MBIngestedPerSec=accumulatedIngestMetrics.getMBIngestedPerSec();
    	this.avgMBIngestedPerSec=accumulatedIngestMetrics.getAvgMBIngestedPerSec();
    	
    	this.numberOfRowsConsumed=accumulatedQueryMetrics.getNumberOfRowsConsumed();
    	this.recordsConsumedPerSec=accumulatedQueryMetrics.getRecordsConsumedPerSec();
    	this.avgRecordsConsumedPerSec=accumulatedQueryMetrics.getAvgRecordsConsumedPerSec();
    	
    	this.MBConsumed=accumulatedQueryMetrics.getMBConsumed();
    	this.MBConsumedPerSec=accumulatedQueryMetrics.getMBConsumedPerSec();
    	this.avgMBConsumedPerSec=accumulatedQueryMetrics.getAvgMBConsumedPerSec();
    	
    	this.queryAndConsumptionTimeInMs=accumulatedQueryMetrics.getQueryAndConsumptionTimeInMs();
    	this.avgQueryAndConsumptionTimeInMs=accumulatedQueryMetrics.getQueryAndConsumptionTimeInMs();
    	
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