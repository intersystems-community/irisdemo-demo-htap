package com.irisdemo.htap.worker;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class AccumulatedMetrics 
{
	Logger logger = LoggerFactory.getLogger(AccumulatedMetrics.class);
	
	@Autowired
	WorkerSemaphore workerSemaphore;
	
	private double timeSpentOnWorkInMillis;
	
	private double numberOfRowsConsumed;
	private double recordsConsumedPerSec; 
	private double avgRecordsConsumedPerSec;
	
	private double bytesConsumed;
	private double MBConsumed;
	private double MBConsumedPerSec; 
	private double avgMBConsumedPerSec;

	private double avgQueryAndConsumptionTimeInMillis;
	private double queryAndConsumptionTimeInMillis;

    /*
     * Variables used to compute the aggregated values
     */
    private double previousNumberOfRowsConsumed;
    private double previousMBConsumed;
    
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
    	timeSpentOnWorkInMillis=0;
    	
    	setNumberOfRowsConsumed(0);
    	setRecordsConsumedPerSec(0); 
    	setAvgRecordsConsumedPerSec(0);
    	
    	bytesConsumed=0;
    	MBConsumed=0;
    	setMBConsumedPerSec(0); 
    	setAvgMBConsumedPerSec(0);

    	setAvgQueryAndConsumptionTimeInMillis(0);
    	setQueryAndConsumptionTimeInMillis(0);

        previousNumberOfRowsConsumed=0;
        previousMBConsumed=0;    			
    }
    
    /**
     * Called by Worker threads to add to stats 
     * @param numberOfRowsIngested
     * @param MBIngested
     */
    synchronized public void addToStats(double timeSpentOnWorkInMillis, double numberOfRowsConsumed, double bytesConsumed) {
        this.setNumberOfRowsConsumed(this.getNumberOfRowsConsumed() + numberOfRowsConsumed);
        this.bytesConsumed+=bytesConsumed;
        this.MBConsumed+=this.bytesConsumed/1024/1024;
        this.timeSpentOnWorkInMillis+=timeSpentOnWorkInMillis;
    }

   
    @Scheduled(fixedRate = 1000)
    synchronized protected void computeAggregatedMetrics()
    {
    	if (workerSemaphore.green())
    	{    		
			double deltaNumberOfRowsConsumed = numberOfRowsConsumed - previousNumberOfRowsConsumed;
			
			//Just a second precaution to stop recomputing the metrics 
			//if we are stopping the workers and no new records have been ingested.
			if (deltaNumberOfRowsConsumed>0) 
			{
				previousNumberOfRowsConsumed = numberOfRowsConsumed;
				this.setRecordsConsumedPerSec(deltaNumberOfRowsConsumed);						
				
				this.setMBConsumedPerSec(MBConsumed - previousMBConsumed);
				previousMBConsumed = MBConsumed;
				
				setAvgRecordsConsumedPerSec(numberOfRowsConsumed / timeSpentOnWorkInMillis);
				
				setAvgMBConsumedPerSec(MBConsumed / timeSpentOnWorkInMillis);
				
				avgQueryAndConsumptionTimeInMillis = timeSpentOnWorkInMillis/numberOfRowsConsumed;
			}
    	}
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

	public double getAvgQueryAndConsumptionTimeInMillis() {
		return avgQueryAndConsumptionTimeInMillis;
	}

	public void setAvgQueryAndConsumptionTimeInMillis(double avgQueryAndConsumptionTimeInMillis) {
		this.avgQueryAndConsumptionTimeInMillis = avgQueryAndConsumptionTimeInMillis;
	}

	public double getQueryAndConsumptionTimeInMillis() {
		return queryAndConsumptionTimeInMillis;
	}

	public void setQueryAndConsumptionTimeInMillis(double queryAndConsumptionTimeInMillis) {
		this.queryAndConsumptionTimeInMillis = queryAndConsumptionTimeInMillis;
	}

	public double getNumberOfRowsConsumed() {
		return numberOfRowsConsumed;
	}

	public void setNumberOfRowsConsumed(double numberOfRowsConsumed) {
		this.numberOfRowsConsumed = numberOfRowsConsumed;
	}
	
	public double getMBConsumed()
	{
		return this.MBConsumed;
	}
}
