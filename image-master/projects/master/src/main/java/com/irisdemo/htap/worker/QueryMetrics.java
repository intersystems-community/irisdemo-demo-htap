package com.irisdemo.htap.worker;

public class QueryMetrics extends MetricsType
{

    protected double numberOfRowsConsumed;

    protected double recordsConsumedPerSec;
    protected double avgRecordsConsumedPerSec;

    protected double MBConsumed;
    protected double MBConsumedPerSec;
    protected double avgMBConsumedPerSec;

    protected double avgQueryAndConsumptionTimeInMillis;

    synchronized public double getNumberOfRowsConsumed() {
        return numberOfRowsConsumed;
    }

    synchronized public void setNumberOfRowsConsumed(double numberOfRowsConsumed) {
        this.numberOfRowsConsumed = numberOfRowsConsumed;
    }

    synchronized public double getRecordsConsumedPerSec() {
        return recordsConsumedPerSec;
    }

    synchronized  public void setRecordsConsumedPerSec(double recordsConsumedPerSec) {
        this.recordsConsumedPerSec = recordsConsumedPerSec;
    }

    synchronized public double getAvgRecordsConsumedPerSec() {
        return avgRecordsConsumedPerSec;
    }

    synchronized public void setAvgRecordsConsumedPerSec(double avgRecordsConsumedPerSec) {
        this.avgRecordsConsumedPerSec = avgRecordsConsumedPerSec;
    }

    synchronized public double getMBConsumed() {
        return MBConsumed;
    }

    synchronized public void setMBConsumed(double mBConsumed) {
        MBConsumed = mBConsumed;
    }

    synchronized public double getMBConsumedPerSec() {
        return MBConsumedPerSec;
    }

    synchronized public void setMBConsumedPerSec(double mBConsumedPerSec) {
        MBConsumedPerSec = mBConsumedPerSec;
    }

    synchronized public double getAvgMBConsumedPerSec() {
        return avgMBConsumedPerSec;
    }

    synchronized public void setAvgMBConsumedPerSec(double avgMBConsumedPerSec) {
        this.avgMBConsumedPerSec = avgMBConsumedPerSec;
    }

    synchronized public double getAvgQueryAndConsumptionTimeInMillis() {
        return avgQueryAndConsumptionTimeInMillis;
    }

    synchronized public void setAvgQueryAndConsumptionTimeInMillis(double avgQueryAndConsumptionTimeInMillis) {
        this.avgQueryAndConsumptionTimeInMillis = avgQueryAndConsumptionTimeInMillis;
    }

}