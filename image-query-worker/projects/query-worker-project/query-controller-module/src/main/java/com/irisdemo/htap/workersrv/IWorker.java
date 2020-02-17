package com.irisdemo.htap.workersrv;

import java.io.IOException;
import java.sql.SQLException;
import java.util.concurrent.CompletableFuture;

import org.springframework.scheduling.annotation.Async;

public interface IWorker 
{
	@Async
    public CompletableFuture<Long> startOneConsumer(int threadNum) throws IOException, SQLException, ClassNotFoundException;
}
