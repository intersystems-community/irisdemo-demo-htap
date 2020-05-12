package com.irisdemo.htap.config;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class RESTMasterConfig 
{	
	/* 
	INGESTION CONFIGURATION 
	*/
	public String ingestionJDBCURL;
	public String ingestionJDBCUserName;
	public String ingestionJDBCPassword;
	public int ingestionBatchSize;
	public int ingestionNumThreadsPerWorker;
	public boolean disableJournalForDropTable;
	public boolean disableJournalForTruncateTable;
	public int databaseSizeInGB;
	public int ingestionWaitTimeBetweenBatchesInMillis;
	
	/*
	 * Statements
	 */
	public String insertStatement;
	public String queryStatement;
	public String queryByIdStatement;
	public String irisProcDisableJournalDrop;
	public String irisProcDisableJournal;
	public String irisProcEnableCallInService;
	public String tableDropStatement;
	public String tableCreateStatement;
	public String tableTruncateStatement;

}
