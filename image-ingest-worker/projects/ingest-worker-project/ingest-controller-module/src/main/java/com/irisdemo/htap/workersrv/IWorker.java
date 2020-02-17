package com.irisdemo.htap.workersrv;

import java.io.IOException;
import java.sql.SQLException;
import java.util.concurrent.CompletableFuture;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

public interface IWorker 
{
	@Async
	public CompletableFuture<Long> startOneFeed(String nodePrefix, int threadNum) throws IOException, SQLException, ClassNotFoundException;
	
	public void prepareDatabaseForSpeedTest() throws Exception;
	
	public void truncateTable() throws Exception;

}
