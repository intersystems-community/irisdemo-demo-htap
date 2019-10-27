package com.irisdemo.htap.worker;

import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AccumulatedQueryMetrics extends QueryMetrics 
{
	
	synchronized public void update(AccumulatedQueryMetrics accumulatedMetrics)
	{
		this.MBConsumed=accumulatedMetrics.getMBConsumed();
		this.MBConsumedPerSec=accumulatedMetrics.getMBConsumedPerSec();
		this.avgMBConsumedPerSec=accumulatedMetrics.getAvgMBConsumedPerSec();
		this.numberOfRowsConsumed=accumulatedMetrics.getNumberOfRowsConsumed();
		this.recordsConsumedPerSec=accumulatedMetrics.getRecordsConsumedPerSec();
		this.avgRecordsConsumedPerSec=accumulatedMetrics.getAvgRecordsConsumedPerSec();
	}
	
	public void addToStats(QueryMetrics newMetrics)
	{
		this.MBConsumed+=newMetrics.getMBConsumed();
		this.MBConsumedPerSec+=newMetrics.getMBConsumedPerSec();
		this.avgMBConsumedPerSec+=newMetrics.getAvgMBConsumedPerSec();
		this.numberOfRowsConsumed+=getNumberOfRowsConsumed();
		this.recordsConsumedPerSec+=newMetrics.getRecordsConsumedPerSec();
		this.avgRecordsConsumedPerSec+=newMetrics.getAvgRecordsConsumedPerSec();
	}
}
