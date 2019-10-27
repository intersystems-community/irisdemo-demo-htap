import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TestRunnerRootComponent } from './root/test-runner-root/test-runner-root.component';

import { NgxChartsModule } from '@swimlane/ngx-charts';

import { TestDirectorService } from '../../providers/test-director.service'


@NgModule({
  declarations: [TestRunnerRootComponent],
  imports: [
    CommonModule,
    NgxChartsModule
  ],
  providers: [
    TestDirectorService
  ],
  exports:[
    TestRunnerRootComponent
  ]
})
export class TestRunnerModule { }
