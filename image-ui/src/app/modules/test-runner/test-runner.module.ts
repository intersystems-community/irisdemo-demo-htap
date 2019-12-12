import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TestRunnerRootComponent } from './root/test-runner-root/test-runner-root.component';

import { NgxChartsModule } from '@swimlane/ngx-charts';

import { TestDirectorService } from '../../providers/test-director.service'

/*Importing Angualr Material Modules*/
import { MatButtonModule } from '@angular/material/button';


@NgModule({
  declarations: [TestRunnerRootComponent],
  imports: [
    CommonModule,
    NgxChartsModule,
    MatButtonModule
  ],
  providers: [
    TestDirectorService
  ],
  exports:[
    TestRunnerRootComponent
  ]
})
export class TestRunnerModule { }
