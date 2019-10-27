package com.irisdemo.htap.worker;

public class QueryWorker extends Worker
{

    QueryMetrics metrics;

    public QueryWorker(String hostname)
    {
        this.hostname = hostname;
        this.metrics = new QueryMetrics();
    }

    public String getWorkerType()
    {
        return "query";
    }

    public void updateMetrics(MetricsType metrics)
    {
        this.metrics = (QueryMetrics)metrics;
    }
}