package com.irisdemo.htap.worker;

import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AccumulatedIngestMetrics extends IngestMetrics 
{
	synchronized public void update(AccumulatedIngestMetrics accumulatedMetrics)
	{
		this.MBIngested=accumulatedMetrics.getMBIngested();
		this.MBIngestedPerSec=accumulatedMetrics.getMBIngestedPerSec();
		this.avgMBIngestedPerSec=accumulatedMetrics.getAvgMBIngestedPerSec();
		this.numberOfRowsIngested=accumulatedMetrics.getNumberOfRowsIngested();
		this.recordsIngestedPerSec=accumulatedMetrics.getRecordsIngestedPerSec();
		this.avgRecordsIngestedPerSec=accumulatedMetrics.getAvgRecordsIngestedPerSec();
	}
	
	public void addToStats(IngestMetrics newMetrics)
	{
		this.MBIngested+=newMetrics.getMBIngested();
		this.MBIngestedPerSec+=newMetrics.getMBIngestedPerSec();
		this.avgMBIngestedPerSec+=newMetrics.getAvgMBIngestedPerSec();
		this.numberOfRowsIngested+=newMetrics.getNumberOfRowsIngested();
		this.recordsIngestedPerSec+=newMetrics.getRecordsIngestedPerSec();
		this.avgRecordsIngestedPerSec+=newMetrics.getAvgRecordsIngestedPerSec();
	}
}
