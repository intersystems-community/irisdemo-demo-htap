import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'app-top-nav',
  templateUrl: './top-nav.component.html',
  styleUrls: ['./top-nav.component.css']
})
export class TopNavComponent implements OnInit {

  @Input() title: string;
  @Input() action: any;
   
  constructor() { }

  ngOnInit() {
  }

  performAction(): void{
    this.action();
  } 

}
