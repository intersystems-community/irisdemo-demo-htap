package com.irisdemo.htap.config;

import org.springframework.stereotype.*;

import com.irisdemo.htap.App;
import com.irisdemo.htap.db.Util;

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
	private String consumptionProgression;
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

	public String getConsumptionProgression() {
		return consumptionProgression;
	}
	
	@Value( "${CONSUMER_PROGRESSION:10}" )
	public void setConsumptionProgression(String consumptionProgression) {
		logger.info("Setting CONSUMER_PROGRESSION = " + consumptionProgression);
		this.consumptionProgression = consumptionProgression;
	}

	public int getConsumptionTimeBetweenQueriesInMillis() {
		return consumptionTimeBetweenQueriesInMillis;
	}
	
	@Value( "${CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS:0}" )
	public void setConsumptionTimeBetweenQueriesInMillis(int consumptionTimeBetweenQueriesInMillis) {
		logger.info("Setting CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS = " + consumptionTimeBetweenQueriesInMillis);
		this.consumptionTimeBetweenQueriesInMillis = consumptionTimeBetweenQueriesInMillis;
	}

}