package com.irisdemo.htap;

import java.io.IOException;
import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import com.irisdemo.htap.workersrv.AccumulatedMetrics;
import com.irisdemo.htap.workersrv.WorkerService;
import com.irisdemo.htap.workersrv.WorkerService.ConsumersAlreadyRunningException;

@CrossOrigin()
@RestController
public class AppController 
{

    @Autowired
    WorkerService workerService;
    
    @Autowired
    AccumulatedMetrics accumulatedMetrics;

    /**
     * This is called by the container HEALTHCHECK
     **/
    @GetMapping(value = "/worker/test")
    public int test() 
    {
        return 1;
    }

    @PostMapping(value = "/worker/startSpeedTest")
    public void startSpeedTest() throws Exception, IOException, SQLException, ConsumersAlreadyRunningException 
    {
        workerService.startConsumers();
    }

    @PostMapping(value = "/worker/stopSpeedTest")
    public void stopSpeedTest() 
    {
        workerService.stopAllConsumers();
    }

    @GetMapping(value = "/worker/getActiveFeeds")
    public int getActiveFeeds() 
    {
        return workerService.getNumberOfConsumersRunning();
    }
    
    @GetMapping("/worker/getMetrics")
    public AccumulatedMetrics getMetrics() 
    {
        return accumulatedMetrics;
    }


}