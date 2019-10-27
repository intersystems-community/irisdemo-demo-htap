import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgxChartsModule } from '@swimlane/ngx-charts';

/*Importing layout components*/
import { TopNavComponent } from './layout/top-nav/top-nav.component';
import { ContentLayoutComponent } from './layout/content-layout/content-layout.component';
import { FooterComponent } from './layout/footer/footer.component';

/*Importing App Modules*/
import { TestRunnerModule } from './modules/test-runner/test-runner.module'

@NgModule({
  declarations: [
    AppComponent,
    TopNavComponent,
    ContentLayoutComponent,
    FooterComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    HttpClientModule,
    NgxChartsModule,

    TestRunnerModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
