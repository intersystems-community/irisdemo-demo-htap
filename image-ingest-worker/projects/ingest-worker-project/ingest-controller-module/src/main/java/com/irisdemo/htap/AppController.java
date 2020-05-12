package com.irisdemo.htap;

import java.io.IOException;
import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.annotation.Order;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.irisdemo.htap.workersrv.WorkerMetricsAccumulator;
import com.irisdemo.htap.workersrv.WorkerService;

@CrossOrigin()
@RestController
public class AppController 
{

    @Autowired
    WorkerService workerService;
    
    @Autowired
    WorkerMetricsAccumulator accumulatedMetrics;

    /**
     * This is called by the container HEALTHCHECK
     **/
    @GetMapping(value = "/worker/test")
    public int test() 
    {
        return 1;
    }

    @PostMapping(value = "/worker/prepare")
    public void prepareDatabaseForSpeedTest() throws Exception 
    {
        workerService.prepareDatabaseForSpeedTest();
    }

    @PostMapping(value = "/worker/truncateTable")
    public void truncateTable() throws Exception 
    {
        workerService.truncateTable();
    }

    @PostMapping(value = "/worker/startSpeedTest")
    public void startSpeedTest() throws Exception, IOException, SQLException 
    {
        workerService.startSpeedTest();
    }

    @PostMapping(value = "/worker/stopSpeedTest")
    public void stopSpeedTest() 
    {
        workerService.stopSpeedTest();
    }
    
    @GetMapping("/worker/getMetrics")
    public WorkerMetricsAccumulator getMetrics() 
    {
        return accumulatedMetrics;
    }


}