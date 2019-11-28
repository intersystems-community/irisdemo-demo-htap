package com.irisdemo.htap.config;

import org.springframework.stereotype.*;

import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.*;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;

@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class Config
{
	Logger logger = LoggerFactory.getLogger(Config.class);
	
	/* 
	GENERAL CONFIGURATION 
	*/
	private boolean startConsumers;
	private boolean disableJournalForDropTable;
	private boolean disableJournalForTruncateTable;
	private String irisProcDisableJournalDrop;
	private String irisProcDisableJournal;
	private String tableDropStatement;
	private String tableCreateStatement;
	private String tableTruncateStatement;
	
	/* 
	INGESTION CONFIGURATION 
	*/
	private String ingestionJDBCURL;
	private String ingestionJDBCUserName;
	private String ingestionJDBCPassword;
	private int ingestionBatchSize;
	private int ingestionNumThreadsPerWorker;
	private String insertStatement;

	/* 
	CONSUMPTION CONFIGURATION 
	*/
	private String consumptionJDBCURL;
	private String consumptionJDBCUserName;
	private String consumptionJDBCPassword;
	private int consumptionNumThreadsPerWorker;
	private int consumptionTimeBetweenQueriesInMillis;
	private String queryStatement;
	private String queryByIdStatement;

	public Config()
	{
		try
		{
			queryStatement=Util.getSingleStatementFromFile("TABLE_SELECT.sql");
			logger.info("Read QUERY statement from file TABLE_SELECT.sql: " + queryStatement);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read QUERY statement from file TABLE_SELECT.sql");
		}

		try
		{
			queryByIdStatement=Util.getSingleStatementFromFile("TABLE_SELECT_ROW.sql");
			logger.info("Read QUERY statement from file TABLE_SELECT_ROW.sql: " + queryByIdStatement);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read QUERY By ID statement from file TABLE_SELECT_ROW.sql");
		}

		try
		{
			insertStatement=Util.getSingleStatementFromFile("TABLE_INSERT.sql");
			logger.info("Read INSERT statement from file TABLE_INSERT.sql:" + insertStatement);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read INSERT statement from file TABLE_INSERT.sql");
		}
		
		try
		{
			irisProcDisableJournalDrop=Util.getSingleStatementFromFile("IRIS_PROC_DISABLEJOURNAL_DROP.sql");
			logger.info("Read statement from file IRIS_PROC_DISABLEJOURNAL_DROP.sql:" + irisProcDisableJournalDrop);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read statement from file IRIS_PROC_DISABLEJOURNAL_DROP.sql");
		}
		
		try
		{
			irisProcDisableJournal=Util.getSingleStatementFromFile("IRIS_PROC_DISABLEJOURNAL.sql");
			logger.info("Read statement from file IRIS_PROC_DISABLEJOURNAL.sql:" + irisProcDisableJournal);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read statement from file IRIS_PROC_DISABLEJOURNAL.sql");
		}
		
		try
		{
			tableDropStatement=Util.getSingleStatementFromFile("TABLE_DROP.sql");
			logger.info("Read statement from file TABLE_DROP.sql:" + tableDropStatement);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read statement from file TABLE_DROP.sql");
		}
		
		try
		{
			tableCreateStatement=Util.getSingleStatementFromFile("TABLE_CREATE.sql");
			logger.info("Read statement from file TABLE_CREATE.sql:" + tableCreateStatement);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read statement from file TABLE_CREATE.sql");
		}
		
		try
		{
			tableTruncateStatement=Util.getSingleStatementFromFile("TABLE_TRUNCATE.sql");
			logger.info("Read statement from file TABLE_TRUNCATE.sql:" + tableTruncateStatement);
		}
		catch (IOException ioE)
		{
			logger.warn("Could not read statement from file TABLE_TRUNCATE.sql");
		}
	}
	
	public int getIngestionNumThreadsPerWorker() 
	{
		return ingestionNumThreadsPerWorker;
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

	public String getInsertStatement()
	{
		return insertStatement;
	}

	public String getTableDropStatement()
	{
		return tableDropStatement;
	}

	public String getTableCreateStatement()
	{
		return tableCreateStatement;
	}

	@Value( "${INGESTION_THREADS_PER_WORKER:10}" )
	public void setIngestionNumThreadsPerWorker(int value) 
	{
		logger.info("Setting INGESTION_THREADS_PER_WORKER = " + value);
		ingestionNumThreadsPerWorker=value;
	}

	public boolean getStartConsumers() {
		return startConsumers;
	}
	
	@Value( "${START_CONSUMERS:true}" )
	public void setStartConsumers(boolean startConsumers) {
		logger.info("Setting START_CONSUMERS = " + startConsumers);
		this.startConsumers = startConsumers;
	}

	public boolean getDisableJournalForDropTable() {
		return disableJournalForDropTable;
	}
	
	@Value( "${DISABLE_JOURNAL_FOR_DROP_TABLE:true}" )
	public void setDisableJournalForDropTable(boolean disableJournalForDropTable) {
		logger.info("Setting DISABLE_JOURNAL_FOR_DROP_TABLE = " + disableJournalForDropTable);
		this.disableJournalForDropTable = disableJournalForDropTable;
	}

	public boolean getDisableJournalForTruncateTable() {
		return disableJournalForTruncateTable;
	}
	
	@Value( "${DISABLE_JOURNAL_FOR_TRUNCATE_TABLE:true}" )
	public void setDisableJournalForTruncateTable(boolean disableJournalForTruncateTable) {
		logger.info("Setting DISABLE_JOURNAL_FOR_TRUNCATE_TABLE = " + disableJournalForTruncateTable);
		this.disableJournalForTruncateTable = disableJournalForTruncateTable;
	}

	public String getIngestionJDBCURL() {
		return ingestionJDBCURL;
	}
	
	@Value( "${INGESTION_JDBC_URL}" )
	public void setIngestionJDBCURL(String ingestionJDBCURL) {
		logger.info("Setting INGESTION_JDBC_URL = " + ingestionJDBCURL);
		this.ingestionJDBCURL = ingestionJDBCURL;
	}

	public String getIngestionJDBCUserName() {
		return ingestionJDBCUserName;
	}
	
	@Value( "${INGESTION_JDBC_USERNAME}" )
	public void setIngestionJDBCUserName(String ingestionJDBCUserName) {
		logger.info("Setting INGESTION_JDBC_USERNAME = " + ingestionJDBCUserName);
		this.ingestionJDBCUserName = ingestionJDBCUserName;
	}

	public String getIngestionJDBCPassword() {
		return ingestionJDBCPassword;
	}
	
	@Value( "${INGESTION_JDBC_PASSWORD}" )
	public void setIngestionJDBCPassword(String ingestionJDBCPassword) {
		logger.info("Setting INGESTION_JDBC_PASSWORD = " + ingestionJDBCPassword);
		this.ingestionJDBCPassword = ingestionJDBCPassword;
	}

	public int getIngestionBatchSize() {
		return ingestionBatchSize;
	}
	
	@Value( "${INGESTION_BATCH_SIZE:1000}" )
	public void setIngestionBatchSize(int ingestionBatchSize) {
		logger.info("Setting INGESTION_BATCH_SIZE = " + ingestionBatchSize);
		this.ingestionBatchSize = ingestionBatchSize;
	}

	public String getConsumptionJDBCURL() {
		return consumptionJDBCURL;
	}
	
	@Value( "${CONSUMER_JDBC_URL}" )
	public void setConsumptionJDBCURL(String consumptionJDBCURL) {
		logger.info("Setting CONSUMER_JDBC_URL = " + consumptionJDBCURL);
		this.consumptionJDBCURL = consumptionJDBCURL;
	}

	public String getConsumptionJDBCUserName() {
		return consumptionJDBCUserName;
	}
	
	@Value( "${CONSUMER_JDBC_USERNAME}" )
	public void setConsumptionJDBCUserName(String consumptionJDBCUserName) {
		logger.info("Setting CONSUMER_JDBC_USERNAME = " + consumptionJDBCUserName);
		this.consumptionJDBCUserName = consumptionJDBCUserName;
	}

	public String getConsumptionJDBCPassword() {
		return consumptionJDBCPassword;
	}
	
	@Value( "${CONSUMER_JDBC_PASSWORD}" )
	public void setConsumptionJDBCPassword(String consumptionJDBCPassword) {
		logger.info("Setting CONSUMER_JDBC_PASSWORD = " + consumptionJDBCPassword);
		this.consumptionJDBCPassword = consumptionJDBCPassword;
	}

	public int getConsumptionNumThreadsPerWorker() {
		return consumptionNumThreadsPerWorker;
	}
	
	@Value( "${CONSUMER_THREADS_PER_WORKER:10}" )
	public void setConsumptionNumThreadsPerWorker(int consumptionNumThreadsPerWorker) {
		logger.info("Setting CONSUMER_THREADS_PER_WORKER= " + consumptionNumThreadsPerWorker);
		this.consumptionNumThreadsPerWorker = consumptionNumThreadsPerWorker;
	}

	public int getConsumptionTimeBetweenQueriesInMillis() {
		return consumptionTimeBetweenQueriesInMillis;
	}
	
	@Value( "${CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS:0}" )
	public void setConsumptionTimeBetweenQueriesInMillis(int consumptionTimeBetweenQueriesInMillis) {
		logger.info("Setting CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS = " + consumptionTimeBetweenQueriesInMillis);
		this.consumptionTimeBetweenQueriesInMillis = consumptionTimeBetweenQueriesInMillis;
	}

	public String getIrisProcDisableJournalDrop() {
		return irisProcDisableJournalDrop;
	}

	public void setIrisProcDisableJournalDrop(String irisProcDisableJournalDrop) {
		this.irisProcDisableJournalDrop = irisProcDisableJournalDrop;
	}

	public String getIrisProcDisableJournal() {
		return irisProcDisableJournal;
	}

	public void setIrisProcDisableJournal(String irisProcDisableJournal) {
		this.irisProcDisableJournal = irisProcDisableJournal;
	}

	public String getTableTruncateStatement() {
		return tableTruncateStatement;
	}

	public void setTableTruncateStatement(String tableTruncateStatement) {
		this.tableTruncateStatement = tableTruncateStatement;
	}

}