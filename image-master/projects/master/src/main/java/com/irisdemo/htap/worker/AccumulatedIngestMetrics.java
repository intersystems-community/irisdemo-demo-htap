package com.irisdemo.htap.worker;

import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AccumulatedIngestMetrics extends IngestMetrics 
{
	// Called to update the main bean that is a singleton
	synchronized public void update(AccumulatedIngestMetrics accumulatedMetrics)
	{
		this.numberOfActiveIngestionThreads=accumulatedMetrics.getNumberOfActiveIngestionThreads();
		this.MBIngested=accumulatedMetrics.getMBIngested();
		this.MBIngestedPerSec=accumulatedMetrics.getMBIngestedPerSec();
		this.avgMBIngestedPerSec=accumulatedMetrics.getAvgMBIngestedPerSec();
		this.numberOfRowsIngested=accumulatedMetrics.getNumberOfRowsIngested();
		this.recordsIngestedPerSec=accumulatedMetrics.getRecordsIngestedPerSec();
		this.avgRecordsIngestedPerSec=accumulatedMetrics.getAvgRecordsIngestedPerSec();
	}
	
	// Used when accumulaing all measures from all workers before updating the main singloton bean
	public void addToStats(IngestMetrics newMetrics)
	{
		this.numberOfActiveIngestionThreads+=newMetrics.getNumberOfActiveIngestionThreads();
		this.MBIngested+=newMetrics.getMBIngested();
		this.MBIngestedPerSec+=newMetrics.getMBIngestedPerSec();
		this.avgMBIngestedPerSec+=newMetrics.getAvgMBIngestedPerSec();
		this.numberOfRowsIngested+=newMetrics.getNumberOfRowsIngested();
		this.recordsIngestedPerSec+=newMetrics.getRecordsIngestedPerSec();
		this.avgRecordsIngestedPerSec+=newMetrics.getAvgRecordsIngestedPerSec();
	}

	// Used to reset main singleton bean
	synchronized public void reset()
	{
		this.MBIngested=0;
		this.MBIngestedPerSec=0;
		this.avgMBIngestedPerSec=0;
		this.numberOfRowsIngested=0;
		this.recordsIngestedPerSec=0;
		this.avgRecordsIngestedPerSec=0;
	}
}
