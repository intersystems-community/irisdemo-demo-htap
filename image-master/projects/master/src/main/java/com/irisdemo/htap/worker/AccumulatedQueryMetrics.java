package com.irisdemo.htap.worker;

import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AccumulatedQueryMetrics extends QueryMetrics 
{
	// Called to update the main bean that is a singleton
	synchronized public void update(AccumulatedQueryMetrics accumulatedMetrics)
	{
		this.numberOfActiveQueryThreads=accumulatedMetrics.getNumberOfActiveQueryThreads();
		this.MBConsumed=accumulatedMetrics.getMBConsumed();
		this.MBConsumedPerSec=accumulatedMetrics.getMBConsumedPerSec();
		this.avgMBConsumedPerSec=accumulatedMetrics.getAvgMBConsumedPerSec();
		this.numberOfRowsConsumed=accumulatedMetrics.getNumberOfRowsConsumed();
		this.recordsConsumedPerSec=accumulatedMetrics.getRecordsConsumedPerSec();
		this.avgRecordsConsumedPerSec=accumulatedMetrics.getAvgRecordsConsumedPerSec();
		this.avgQueryAndConsumptionTimeInMillis=accumulatedMetrics.getAvgQueryAndConsumptionTimeInMillis();
		this.queryAndConsumptionTimeInMillis=accumulatedMetrics.getQueryAndConsumptionTimeInMillis();
	}
	
	// Used when accumulaing all measures from all workers before updating the main singloton bean
	public void addToStats(QueryMetrics newMetrics)
	{
		this.numberOfActiveQueryThreads+=newMetrics.getNumberOfActiveQueryThreads();
		this.MBConsumed+=newMetrics.getMBConsumed();
		this.MBConsumedPerSec+=newMetrics.getMBConsumedPerSec();
		this.avgMBConsumedPerSec+=newMetrics.getAvgMBConsumedPerSec();
		this.numberOfRowsConsumed+=newMetrics.getNumberOfRowsConsumed();
		this.recordsConsumedPerSec+=newMetrics.getRecordsConsumedPerSec();
		this.avgRecordsConsumedPerSec+=newMetrics.getAvgRecordsConsumedPerSec();
		this.avgQueryAndConsumptionTimeInMillis+=newMetrics.getAvgQueryAndConsumptionTimeInMillis();
		this.queryAndConsumptionTimeInMillis+=newMetrics.getQueryAndConsumptionTimeInMillis();
	}

	// Used to reset main singleton bean
	synchronized public void reset()
	{
		this.MBConsumed=0;
		this.MBConsumedPerSec=0;
		this.avgMBConsumedPerSec=0;
		this.numberOfRowsConsumed=0;
		this.recordsConsumedPerSec=0;
		this.avgRecordsConsumedPerSec=0;
		this.avgQueryAndConsumptionTimeInMillis=0;
	}
}
