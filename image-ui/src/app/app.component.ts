import { Component } from '@angular/core';

import { HttpClient } from '@angular/common/http';
import { TestDirectorService } from './providers/test-director.service'
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  
  $titleSubscription: Subscription;
  title: string = 'IRIS Speed Test';

  constructor(private http: HttpClient, private testDirector: TestDirectorService) {
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

}
