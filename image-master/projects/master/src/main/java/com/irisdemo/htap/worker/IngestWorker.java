package com.irisdemo.htap.worker;

public class IngestWorker extends Worker
{
    IngestMetrics metrics;

    public IngestWorker(String hostname)
    {
        this.hostname = hostname;
        this.metrics = new IngestMetrics();
    }

    public String getWorkerType()
    {
        return "ingest";
    }

    public void updateMetrics(MetricsType metrics)
    {
        this.metrics = (IngestMetrics)metrics;
    }

}