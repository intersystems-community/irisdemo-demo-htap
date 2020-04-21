import { Component, OnInit } from '@angular/core';

import { interval, Subscription } from 'rxjs';
import { take, flatMap } from 'rxjs/operators';

import { TestDirectorService } from '../../../../providers/test-director.service'

@Component({
  selector: 'app-test-runner-root',
  templateUrl: './test-runner-root.component.html',
  styleUrls: ['./test-runner-root.component.css']
})
export class TestRunnerRootComponent implements OnInit {

  testRunningStatus = "stopped";
  hasResultsToDownload: boolean = false;
  testRunTime: number = 15;
  latestMetrics: any = {};

  $metricsSubscription: Subscription;
  $startSubscription: Subscription;
  $stopSubscription: Subscription;

  /*High Level Test Statistics*/
  runTime: number= 0;
  rowsIngested: number = 0;
  rowsConsumed: number = 0;
  mbIngested: number = 0;
  mbConsumed: number = 0;
  avgQueryTime: number = 0;

  // Shared Graph Configurations
  sharedGraphConfiguration: any = {
    xAxisLabel: "Time",
    animations: true,
    showXAxis: true,
    showYAxis: true,
    gradient: false,
    showLegend: true,
    showXAxisLabel: true,
    showYAxisLabel: true,
    xScaleMin: 0,
    yScaleMin: 0,
    colorScheme: {
      domain: ['#333695', '#00A09A']
    }
  }

  dataIngestMB = [
    {
      "name": "Insert Rate Mb/s",
      "series": [
        
      ]
    },
  
    {
      "name": "Avg Insert Rate Mb/s",
      "series": [
        
      ]
    },
  ];

  dataIngestRecords = [
    {
      "name": "Insert Rate Records/s",
      "series": [
        
      ]
    },
    {
      "name": "Avg Insert Rate Records/s",
      "series": [
        
      ]
    },
  ];

  dataConsumptionRecords = [
    {
      "name": "Query Rate Records/s",
      "series": [
        
      ]
    },
  
    {
      "name": "Avg Query Rate Records/s",
      "series": [
        
      ]
    },
  ];

  constructor(private testDirector: TestDirectorService) { }

  ngOnInit() {
    this.catchUpIfServerIsRunningSpeedTest();
  }

  handleMetricsResponse(currentMetrics: any): void {
    this.runTime = currentMetrics.runTimeInSeconds; // Test runtime is dictated by the server now

    this.rowsConsumed = currentMetrics.numberOfRowsConsumed;
    this.rowsIngested = currentMetrics.numberOfRowsIngested;
    this.mbConsumed = currentMetrics.mbconsumed;
    this.mbIngested = currentMetrics.mbingested;
    this.avgQueryTime = currentMetrics.avgQueryAndConsumptionTimeInMs;

    this.dataIngestRecords[0].series.push({name: this.runTime, value: currentMetrics.recordsIngestedPerSec})
    this.dataIngestRecords[1].series.push({name: this.runTime, value: currentMetrics.avgRecordsIngestedPerSec})
    this.dataIngestRecords = [...this.dataIngestRecords];

    this.dataIngestMB[0].series.push({name: this.runTime, value: currentMetrics.mbingestedPerSec})
    this.dataIngestMB[1].series.push({name: this.runTime, value: currentMetrics.avgMBIngestedPerSec})
    this.dataIngestMB = [...this.dataIngestMB];

    this.dataConsumptionRecords[0].series.push({name: this.runTime, value: currentMetrics.recordsConsumedPerSec})
    this.dataConsumptionRecords[1].series.push({name: this.runTime, value: currentMetrics.avgRecordsConsumedPerSec})
    this.dataConsumptionRecords = [...this.dataConsumptionRecords];

    // let ingestionMatch =  this.latestMetrics.numberOfRowsIngested === currentMetrics.numberOfRowsIngested;
    // let consumptionMatch = this.latestMetrics.numberOfRowsConsumed === currentMetrics.numberOfRowsConsumed;
    
    // When we request the speed test to stop from the UI, the server will process the request
    // as it has always done it. But the metrics returned now include its status (speedTestrunning)
    // The server may also simply stop the test if the time to stop has come
    // So, now, we will only stop subscription if the server told us to do so.
    //console.log(currentMetrics);

    switch (currentMetrics.speedTestRunningStatus)
    {
      case 0:
        if (this.$metricsSubscription)
        this.$metricsSubscription.unsubscribe();
        
        this.testRunningStatus = "stopped";
        this.hasResultsToDownload = true;
        break;

      case 1:
        this.testRunningStatus = "starting";
        break;

      case 2:
        this.testRunningStatus = "running";
        break;
    }

    this.latestMetrics = currentMetrics;
  }

  clearGraphs(): void {
    this.runTime = 0;
    this.dataIngestRecords[0].series = [];
    this.dataIngestRecords[1].series = [];
    this.dataIngestMB[0].series = [];
    this.dataIngestMB[1].series = [];
    this.dataConsumptionRecords[0].series = [];
    this.dataConsumptionRecords[1].series = [];
  }

  startTestSafetyKill(): void {
    setTimeout(() =>{
      this.stopTest();
    }, 1000 * this.testRunTime)
  }

  runTest(): void {
    
    // We will assume the test will be running so the Run Test button will be hidden
    this.testRunningStatus = "starting";
    this.hasResultsToDownload = false;
    this.clearGraphs();
    this.$startSubscription = this.testDirector.startTest().subscribe(
      response => {
        this.$startSubscription.unsubscribe();
        
        //this.startTestSafetyKill();
        this.monitorMetrics();
      },
      error => {
        this.testRunningStatus = "stopped";
        this.$startSubscription.unsubscribe();
        alert("an error occured subscribing to Start Subscription")
      }
    )
  }

  // In the situation where the browser was closed and the server was left running the speed test,
  // we can simply reopen the application and this will try to get the metrics only once. 
  catchUpIfServerIsRunningSpeedTest(): void {
    this.$startSubscription = this.testDirector.getMetrics().subscribe(
      response => {
        this.$startSubscription.unsubscribe();
        
        console.log(response);

        if (response.speedTestRunningStatus!=0) // Is test starting or already running?
        {
          this.runTest();
        }
        else if (response.runTimeInSeconds>0) // Was test running and has already stopped?
        {
          // Don't start the test to catch up. Just update the graph with the last results. 
          // We should implement a service to download the entire data we have stored in the server to
          // populate the graph again. But the user will be able to use the new green "Results" button
          // to download the CSV file themselves.
          this.handleMetricsResponse(response);
        }
        else
        {
          this.clearGraphs();
        }

      },
      error => {
        this.$startSubscription.unsubscribe();
      }
    )
  }

  stopTest(): void {
    this.$stopSubscription = this.testDirector.stopTest().subscribe(
      response => {
        this.$stopSubscription.unsubscribe();
        console.log("Stopping Test");
      },
      error => {
        this.$stopSubscription.unsubscribe();
        alert("an error occured subscribing to Stop Subscription")
      }
    )
  }

  monitorMetrics(): void {
    /*Take Metrics Every 2 seconds*/
    const metricsStatusCheck = interval(1 * 1000).pipe(flatMap(() => this.testDirector.getMetrics()))
    
    this.$metricsSubscription = metricsStatusCheck.subscribe(
      metricsResponse => {
        //console.log(metricsResponse);
        
        this.handleMetricsResponse(metricsResponse);

      },
      error =>{
        alert("an error occured subscribing to metrics Status")
        this.$metricsSubscription.unsubscribe();
      }
    );
  }

  onSelect(event) {
    console.log(event);
  }
}
