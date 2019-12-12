package com.irisdemo.htap.workersrv;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class WorkerMetricsAccumulator 
{
	@Autowired
	WorkerSemaphore workerSemaphore;
	
	private double startTimeInMillis;
	
    private double numberOfRowsIngested;
    
    private double recordsIngestedPerSec;
    private double avgRecordsIngestedPerSec;

    private double bytesIngested;
    private double MBIngested;

    private double MBIngestedPerSec;    
    private double avgMBIngestedPerSec;
    
    /*
     * Variables used to compute the aggregated values
     */
    private double previousNumberOfRowsIngested;
    private double previousMBIngested;
    
    /*
     * Getters and setters for the outside world
     */
    
    /**
     * This method is called by the WorkerService just before the workers are started so
     * that aggregated metrics can be computed properly
     * @param startTimeInMillis
     */
    public void reset()
    {
    	this.startTimeInMillis=System.currentTimeMillis();
    	this.numberOfRowsIngested=0;
    	this.recordsIngestedPerSec=0;
    	this.avgRecordsIngestedPerSec=0;
    	this.MBIngested=0;
    	this.MBIngestedPerSec=0;
    	this.avgMBIngestedPerSec=0;
    	this.previousNumberOfRowsIngested=0;
    	this.previousMBIngested=0;
    	this.bytesIngested=0;
    			
    }
    
    public double getNumberOfRowsIngested() {
        return numberOfRowsIngested;
    }

    /**
     * Called by Worker threads to add to stats 
     * @param numberOfRowsIngested
     * @param MBIngested
     */
    synchronized public void addToStats(double numberOfRowsIngested, double bytesIngested) {
        this.numberOfRowsIngested+= numberOfRowsIngested;
        this.bytesIngested+=bytesIngested;
        this.MBIngested=this.bytesIngested/1024/1024;
    }

    synchronized public double getRecordsIngestedPerSec() {
        return recordsIngestedPerSec;
    }

    synchronized  public double getAvgRecordsIngestedPerSec() {
        return avgRecordsIngestedPerSec;
    }

    synchronized public double getMBIngested() {
        return MBIngested;
    }

    synchronized public double getMBIngestedPerSec() {
        return MBIngestedPerSec;
    }

    synchronized public double getAvgMBIngestedPerSec() {
        return avgMBIngestedPerSec;
    }
    
    @Scheduled(fixedRate = 1000)
    synchronized protected void computeAggregatedMetrics()
    {
    	if (workerSemaphore.green())
    	{
			double deltaNumberOfRowsIngested = numberOfRowsIngested - previousNumberOfRowsIngested;
			
			//Just a second precaution to stop recomputing the metrics 
			//if we are stopping the workers and no new records have been ingested.
			if (deltaNumberOfRowsIngested>0) 
			{
				previousNumberOfRowsIngested = numberOfRowsIngested;
				this.recordsIngestedPerSec = deltaNumberOfRowsIngested;
	
	    		double ellapsedTimeInMillis = (System.currentTimeMillis() - startTimeInMillis);
				double ellapsedTimeInSeconds = ellapsedTimeInMillis/1000d;
						
				this.MBIngestedPerSec = MBIngested - previousMBIngested;
				previousMBIngested = MBIngested;
				
				avgRecordsIngestedPerSec = numberOfRowsIngested / ellapsedTimeInSeconds;
				
				avgMBIngestedPerSec = MBIngested/ ellapsedTimeInSeconds;
			}
    	}
    }
}
