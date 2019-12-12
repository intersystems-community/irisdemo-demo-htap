import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
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

/*Importing Angualr Material Modules*/
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule } from '@angular/material/dialog';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';

import { AppConfigDialogComponent } from './components/app-config-dialog/app-config-dialog.component';

@NgModule({
  declarations: [
    AppComponent,
    TopNavComponent,
    ContentLayoutComponent,
    FooterComponent,
    AppConfigDialogComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    AppRoutingModule,
    HttpClientModule,
    NgxChartsModule,

    MatButtonModule,
    MatDialogModule,
    MatInputModule,
    MatFormFieldModule,
    MatIconModule,

    TestRunnerModule
  ],
  entryComponents: [
    AppConfigDialogComponent
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
