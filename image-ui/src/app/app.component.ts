import { Component } from '@angular/core';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

import { HttpClient } from '@angular/common/http';
import { TestDirectorService } from './providers/test-director.service'
import { Subscription } from 'rxjs';

import { AppConfigDialogComponent } from './components/app-config-dialog/app-config-dialog.component'

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  
  $titleSubscription: Subscription;
  title: string = 'IRIS Speed Test';

  constructor(private http: HttpClient, 
    private testDirector: TestDirectorService,
    public dialog: MatDialog) {
    this.setTitle()
  }

  setTitle(): void {
    this.$titleSubscription = this.testDirector.getTitle().subscribe(
      response => {
        this.$titleSubscription.unsubscribe();
        if(response.value){
          this.title = response.value;
        }
      },
      error => {
        this.$titleSubscription.unsubscribe();
        console.log("an error occured subscribing to Title Subscription")
      }
    )
  }

  /*This function notaion is used to bind this function to the correct scope*/
  openDialog = () => {
    const dialogRef = this.dialog.open(AppConfigDialogComponent, {
      width: '800px',
      data: {}
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');
    });
  }

}
