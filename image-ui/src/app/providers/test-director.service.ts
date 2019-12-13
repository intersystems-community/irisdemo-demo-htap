import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class TestDirectorService {

  constructor(private http: HttpClient) { }

  baseURL: string = "http://" + window.location.host + "/master"
  apiConfig: any = {
    testConnection: "/test",
    startTest: "/startSpeedTest",
    stopTest: "/stopSpeedTest",
    getMetrics: "/getMetrics",
    getTitle: "/getTitle",
    getApplicationConfig: "/getApplicationConfig",
    updateApplicationConfig: "/updateApplicationConfig"
  }

  getHostName(){
    // let hostName:  string  = window.location.hostname

    // if(hostName.includes("CN-IRISSpeedTest-0001")){
    //   hostName = hostName.replace("htapui", "htapmaster");
    //   hostName = hostName.replace("0001", "0002")
    // }else{
    //   hostName = this.baseURL
    // }

    // return hostName;

    return this.baseURL;
  }

  generateURL(apiEndpoint: string): string {
    return this.getHostName() + this.apiConfig[apiEndpoint];
  }

  testConnection(): Observable<any>{
    return this.http.get<any>(this.generateURL("testConnection"));
  }

  startTest(): Observable<any>{
    return this.http.post<any>(this.generateURL("startTest"), {});
  }

  stopTest(): Observable<any>{
    return this.http.post<any>(this.generateURL("stopTest"), {});
  }

  getMetrics(): Observable<any>{
    return this.http.get<any>(this.generateURL("getMetrics"));
  }

  getTitle(): Observable<any>{
    return this.http.get<any>(this.generateURL("getTitle"));
  }

  getApplicationConfig(): Observable<any>{
    return this.http.get<any>(this.generateURL("getApplicationConfig"));
  }

  updateApplicationConfig(newApplicationConfig: any): Observable<any>{
    return this.http.post<any>(this.generateURL("updateApplicationConfig"), newApplicationConfig);
  }
}
