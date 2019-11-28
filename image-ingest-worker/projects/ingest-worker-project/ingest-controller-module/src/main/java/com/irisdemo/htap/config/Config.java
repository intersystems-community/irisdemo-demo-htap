package com.irisdemo.htap.config;

import org.springframework.stereotype.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.*;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.boot.web.servlet.context.ServletWebServerInitializedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.boot.web.server.LocalServerPort;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class Config 
{
	Logger logger = LoggerFactory.getLogger(Config.class);
	
	/*
	WORKER CONFIGURATION COMING FROM THE MASTER
	*/
	private String masterHostName;
	private String masterPort;
	private String thisHostName;
	private int thisServerPort;
	private String workerNodePrefix;
	
	private boolean disableJournalForDropTable;
	private boolean disableJournalForTruncateTable;

	
	private String ingestionJDBCURL;
	private String ingestionJDBCUserName;
	private String ingestionJDBCPassword;
	private int ingestionBatchSize;
	private int ingestionNumThreadsPerWorker;
	
	/*
	 * Statements
	 */
	private String insertStatement;
	private String queryByIdStatement;
	private String queryStatement;
	private String irisProcDisableJournalDrop;
	private String irisProcDisableJournal;
	private String tableDropStatement;
	private String tableCreateStatement;
	private String tableTruncateStatement;
	
	public void setWorkerNodePrefix(String workerNodePrefix)
	{
		this.workerNodePrefix=workerNodePrefix;
	}
	
	public String getWorkerNodePrefix()
	{
		return this.workerNodePrefix;
	}
		
	public void setInsertStatement(String insertStatement) 
	{
		logger.info("Setting INSERT statement = " + insertStatement);
		this.insertStatement=insertStatement;
	}

	public String getQueryStatement() 
	{
		return queryStatement;
	}

	public String getQueryByIdStatement() 
	{
		return queryByIdStatement;
	}

	public void setQueryStatement(String queryStatement) 
	{
		logger.info("Setting QUERY statement = " + queryStatement);
		this.queryStatement=queryStatement;
	}

	public void setQueryByIdStatement(String queryByIdStatement) 
	{
		logger.info("Setting QUERY By ID statement = " + queryByIdStatement);
		this.queryByIdStatement=queryByIdStatement;
	}

	public String getInsertStatement() 
	{
		return insertStatement;
	}
	
	@Value( "${HOSTNAME}" )
	public void setThisHostName(String thisHostName) {
		logger.info("This hostname is " + thisHostName);
		this.thisHostName = thisHostName;
	}

	public void setThisServerPort(int thisServerPort) {
		logger.info("This server port is " + thisServerPort);
		this.thisServerPort = thisServerPort;
	}

	public int getThisServerPort() {
		return this.thisServerPort;
	}

	public String getThisHostName() {
		return thisHostName;
	}

	public String getMasterHostName() {
		return masterHostName;
	}
		
	@Value( "${MASTER_HOSTNAME}" )
	public void setMasterHostName(String masterHostName) {
		logger.info("Setting MASTER_HOSTNAME = " + masterHostName);
		this.masterHostName = masterHostName;
	}

	public String getMasterPort() {
		return masterPort;
	}
		
	@Value( "${MASTER_PORT:80}" )
	public void setMasterPort(String masterPort) {
		logger.info("Setting MASTER_PORT = " + masterPort);
		this.masterPort = masterPort;
	}
	
	public int getIngestionNumThreadsPerWorker() 
	{
		return ingestionNumThreadsPerWorker;
	}
	
	public void setIngestionNumThreadsPerWorker(int value) 
	{
		logger.info("Setting INGESTION_THREADS_PER_WORKER = " + value);
		ingestionNumThreadsPerWorker=value;
	}

	public String getIngestionJDBCURL() {
		return ingestionJDBCURL;
	}
	
	public void setIngestionJDBCURL(String ingestionJDBCURL) {
		logger.info("Setting INGESTION_JDBC_URL = " + ingestionJDBCURL);
		this.ingestionJDBCURL = ingestionJDBCURL;
	}

	public String getIngestionJDBCUserName() {
		return ingestionJDBCUserName;
	}
	
	public void setIngestionJDBCUserName(String ingestionJDBCUserName) {
		logger.info("Setting INGESTION_JDBC_USERNAME = " + ingestionJDBCUserName);
		this.ingestionJDBCUserName = ingestionJDBCUserName;
	}

	public String getIngestionJDBCPassword() {
		return ingestionJDBCPassword;
	}
	
	public void setIngestionJDBCPassword(String ingestionJDBCPassword) {
		logger.info("Setting INGESTION_JDBC_PASSWORD = " + ingestionJDBCPassword);
		this.ingestionJDBCPassword = ingestionJDBCPassword;
	}

	public int getIngestionBatchSize() {
		return ingestionBatchSize;
	}
	
	public void setIngestionBatchSize(int ingestionBatchSize) {
		logger.info("Setting INGESTION_BATCH_SIZE = " + ingestionBatchSize);
		this.ingestionBatchSize = ingestionBatchSize;
	}

	public boolean getDisableJournalForDropTable() {
		return disableJournalForDropTable;
	}
	
	public void setDisableJournalForDropTable(boolean disableJournalForDropTable) {
		logger.info("Setting DISABLE_JOURNAL_FOR_DROP_TABLE = " + disableJournalForDropTable);
		this.disableJournalForDropTable = disableJournalForDropTable;
	}

	public boolean getDisableJournalForTruncateTable() {
		return disableJournalForTruncateTable;
	}
	
	public void setDisableJournalForTruncateTable(boolean disableJournalForTruncateTable) {
		logger.info("Setting DISABLE_JOURNAL_FOR_TRUNCATE_TABLE = " + disableJournalForTruncateTable);
		this.disableJournalForTruncateTable = disableJournalForTruncateTable;
	}

	public String getIrisProcDisableJournal() {
		return irisProcDisableJournal;
	}

	public void setIrisProcDisableJournal(String irisProcDisableJournal) {
		logger.info("Got disable journal create procedure for IRIS.");
		this.irisProcDisableJournal = irisProcDisableJournal;
	}

	public String getTableDropStatement() {
		return tableDropStatement;
	}

	public void setTableDropStatement(String tableDropStatement) {
		logger.info("Got table drop statement.");
		this.tableDropStatement = tableDropStatement;
	}

	public String getTableCreateStatement() {
		return tableCreateStatement;
	}

	public void setTableCreateStatement(String tableCreateStatement) {
		logger.info("Got table create statement.");
		this.tableCreateStatement = tableCreateStatement;
	}

	public String getIrisProcDisableJournalDrop() {
		return irisProcDisableJournalDrop;
	}

	public void setIrisProcDisableJournalDrop(String irisProcDisableJournalOnDrop) {
		logger.info("Got disable journal drop procedure for IRIS.");
		this.irisProcDisableJournalDrop = irisProcDisableJournalOnDrop;
	}

	public String getTableTruncateStatement() {
		return tableTruncateStatement;
	}

	public void setTableTruncateStatement(String tableTruncateStatement) {
		logger.info("Got table truncate statement.");
		this.tableTruncateStatement = tableTruncateStatement;
	}

}