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

  testRunning: boolean = false;
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

  ngOnInit() {}

  handleMetricsResponse(currentMetrics: any): void {

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

    let ingestionMatch =  this.latestMetrics.numberOfRowsIngested === currentMetrics.numberOfRowsIngested;
    let consumptionMatch = this.latestMetrics.numberOfRowsConsumed === currentMetrics.numberOfRowsConsumed;
    if(!this.testRunning && ingestionMatch && consumptionMatch){
      this.$metricsSubscription.unsubscribe();
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
    this.clearGraphs();
    this.$startSubscription = this.testDirector.startTest().subscribe(
      response => {
        this.$startSubscription.unsubscribe();
        this.testRunning = true;
        //this.startTestSafetyKill();
        this.monitorMetrics();
      },
      error => {
        this.$startSubscription.unsubscribe();
        alert("an error occured subscribing to Start Subscription")
      }
    )
  }

  stopTest(): void {
    this.$stopSubscription = this.testDirector.stopTest().subscribe(
      response => {
        this.$stopSubscription.unsubscribe();
        this.testRunning = false;
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
    const metricsStatusCheck = 
    interval(1 * 1000).pipe(flatMap(() => this.testDirector.getMetrics()))
    
    this.$metricsSubscription = metricsStatusCheck.subscribe(
      metricsResponse => {
        this.runTime++;
        console.log(metricsResponse);
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
