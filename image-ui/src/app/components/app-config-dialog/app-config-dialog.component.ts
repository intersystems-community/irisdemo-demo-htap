import { Component, OnInit, Inject } from '@angular/core';
import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';

import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

import { TestDirectorService } from '../../providers/test-director.service'

@Component({
  selector: 'app-app-config-dialog',
  templateUrl: './app-config-dialog.component.html',
  styleUrls: ['./app-config-dialog.component.css']
})
export class AppConfigDialogComponent implements OnInit {

  configFormGroup: FormGroup;
  allowConfigUpdate: boolean = false;
  hideIngestPassword: boolean = true;
  hideConsumptionPassword: boolean = true;
  loading: boolean = false;

  constructor(
    public dialogRef: MatDialogRef<AppConfigDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
    private formBuilder: FormBuilder,
    private testDirector: TestDirectorService
    ) {
      this.createForm();
      this.retrieveApplicationConfig();
    }
  
  ngOnInit() {
    this.configFormGroup.statusChanges.subscribe( (status) => {
      console.log(status); //status will be "VALID", "INVALID", "PENDING" or "DISABLED"
      if(status === "VALID"){
        this.allowConfigUpdate = true;
      }else{
        this.allowConfigUpdate = false;
      }
    })
  }

  onNoClick(): void {
    this.dialogRef.close();
  }

  createForm() {
    this.configFormGroup = this.formBuilder.group({
      'maxTimeToRunInSeconds': [null, [Validators.required]],
      'ingestionJDBCURL': [null, [Validators.required]],
      'ingestionJDBCUserName': [null, [Validators.required]],
      'ingestionJDBCPassword': [null, [Validators.required]],
      'ingestionBatchSize': [1000, [Validators.required]],
      'ingestionNumThreadsPerWorker': [2, [Validators.required]],
      'ingestionWaitTimeBetweenBatchesInMillis': [0, [Validators.required]],

      'consumptionJDBCURL': [null, [Validators.required]],
      'consumptionJDBCUserName': [null, [Validators.required]],
      'consumptionJDBCPassword': [null, [Validators.required]],
      'consumptionTimeBetweenQueriesInMillis': [0, [Validators.required]],
      'consumptionNumThreadsPerWorker': [1, [Validators.required]],
      'consumptionNumOfKeysToFetch': [1, [Validators.required]]
      
    });
  }

  updateFormWithConfigValue(config: any): void {
    console.log(config);
    this.configFormGroup.setValue({
      maxTimeToRunInSeconds: config.maxTimeToRunInSeconds, 
      ingestionJDBCURL: config.ingestionJDBCURL, 
      ingestionJDBCUserName: config.ingestionJDBCUserName,
      ingestionJDBCPassword: config.ingestionJDBCPassword,
      ingestionBatchSize: config.ingestionBatchSize,
      ingestionNumThreadsPerWorker: config.ingestionNumThreadsPerWorker,
      ingestionWaitTimeBetweenBatchesInMillis: config.ingestionWaitTimeBetweenBatchesInMillis,
      consumptionJDBCURL: config.consumptionJDBCURL,
      consumptionJDBCUserName: config.consumptionJDBCUserName,
      consumptionJDBCPassword: config.consumptionJDBCPassword,
      consumptionTimeBetweenQueriesInMillis: config.consumptionTimeBetweenQueriesInMillis,
      consumptionNumThreadsPerWorker: config.consumptionNumThreadsPerWorker,
      consumptionNumOfKeysToFetch: config.consumptionNumOfKeysToFetch
    });
  }

  retrieveApplicationConfig(): void {
    this.testDirector.getApplicationConfig().subscribe( 
      response => {
        this.updateFormWithConfigValue(response);
      },
      error => {
        alert("an error occured subscribing to Application Config Subscription")
      }
    )
  }

  updateApplicationConfig(): void {
    let newConfig = this.configFormGroup.value;
    this.loading = true;
    this.testDirector.updateApplicationConfig(newConfig).subscribe( 
      response => {
        this.updateFormWithConfigValue(response);
        this.loading = false;
        this.onNoClick()
      },
      error => {
        this.loading = false;
        this.onNoClick()
        alert("an error occured subscribing to Application Config Update Subscription")
      }
    )
  }

}
