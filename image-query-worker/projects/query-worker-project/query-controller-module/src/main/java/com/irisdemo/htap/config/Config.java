package com.irisdemo.htap.config;

import org.springframework.stereotype.*;
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
	WORKER CONFIGURATION
	*/
	private String masterHostName;
	private String masterPort;
	private String thisHostName;
	private int thisServerPort;
	private String workerNodePrefix;
	
	/* 
	GENERAL CONFIGURATION THAT WILL BE COMING FROM THE MASTER
	*/
	private boolean startConsumers;

	/* 
	INGESTION CONFIGURATION THAT WILL BE COMING FROM THE MASTER
	*/
	private String ingestionJDBCURL;
	private String ingestionJDBCUserName;
	private String ingestionJDBCPassword;
	private int ingestionBatchSize;
	private int ingestionNumThreadsPerWorker;
	private String insertStatement;
	private String queryByIdStatement;

	/* 
	CONSUMPTION CONFIGURATION THAT WILL BE COMING FROM THE MASTER
	*/
	private String consumptionJDBCURL;
	private String consumptionJDBCUserName;
	private String consumptionJDBCPassword;
	private int consumptionNumThreadsPerWorker;
	private int consumptionTimeBetweenQueriesInMillis;
	private String queryStatement;
	private int consumptionNumOfKeysToFetch;

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

	public void setThisServerPort(int thisServerPort) {
		logger.info("This server port is " + thisServerPort);
		this.thisServerPort = thisServerPort;
	}

	public int getThisServerPort() {
		return this.thisServerPort;
	}

	public void setConsumptionNumOfKeysToFetch(int consumptionNumOfKeysToFetch) {
		logger.info("Number of keys to fetch: " + consumptionNumOfKeysToFetch);
		this.consumptionNumOfKeysToFetch = consumptionNumOfKeysToFetch;
	}

	public int getConsumptionNumOfKeysToFetch() {
		return this.consumptionNumOfKeysToFetch;
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

	public boolean getStartConsumers() {
		return startConsumers;
	}
	
	public void setStartConsumers(boolean startConsumers) {
		logger.info("Setting START_CONSUMERS = " + startConsumers);
		this.startConsumers = startConsumers;
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

	public String getConsumptionJDBCURL() {
		return consumptionJDBCURL;
	}
	
	public void setConsumptionJDBCURL(String consumptionJDBCURL) {
		logger.info("Setting CONSUMER_JDBC_URL = " + consumptionJDBCURL);
		this.consumptionJDBCURL = consumptionJDBCURL;
	}

	public String getConsumptionJDBCUserName() {
		return consumptionJDBCUserName;
	}
	
	public void setConsumptionJDBCUserName(String consumptionJDBCUserName) {
		logger.info("Setting CONSUMER_JDBC_USERNAME = " + consumptionJDBCUserName);
		this.consumptionJDBCUserName = consumptionJDBCUserName;
	}

	public String getConsumptionJDBCPassword() {
		return consumptionJDBCPassword;
	}
	
	public void setConsumptionJDBCPassword(String consumptionJDBCPassword) {
		logger.info("Setting CONSUMER_JDBC_PASSWORD = " + consumptionJDBCPassword);
		this.consumptionJDBCPassword = consumptionJDBCPassword;
	}

	public int getConsumptionNumThreadsPerWorker() {
		return consumptionNumThreadsPerWorker;
	}
	
	public void setConsumptionNumThreadsPerWorker(int consumptionNumThreadsPerWorker) {
		logger.info("Setting CONSUMER_THREADS_PER_WORKER = " + consumptionNumThreadsPerWorker);
		this.consumptionNumThreadsPerWorker = consumptionNumThreadsPerWorker;
	}

	public int getConsumptionTimeBetweenQueriesInMillis() {
		return consumptionTimeBetweenQueriesInMillis;
	}
	
	public void setConsumptionTimeBetweenQueriesInMillis(int consumptionTimeBetweenQueriesInMillis) {
		logger.info("Setting CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS = " + consumptionTimeBetweenQueriesInMillis);
		this.consumptionTimeBetweenQueriesInMillis = consumptionTimeBetweenQueriesInMillis;
	}

}