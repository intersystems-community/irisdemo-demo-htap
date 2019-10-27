import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class TestDirectorService {

  constructor(private http: HttpClient) { }

  baseURL: string = "http://localhost:10002/master"
  apiConfig: any = {
    testConnection: "/test",
    startTest: "/startSpeedTest",
    stopTest: "/stopSpeedTest",
    getMetrics: "/getMetrics"
  }

  generateURL(apiEndpoint: string): string {
    return this.baseURL + this.apiConfig[apiEndpoint];
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
}
