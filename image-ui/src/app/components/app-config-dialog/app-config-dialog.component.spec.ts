import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AppConfigDialogComponent } from './app-config-dialog.component';

describe('AppConfigDialogComponent', () => {
  let component: AppConfigDialogComponent;
  let fixture: ComponentFixture<AppConfigDialogComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AppConfigDialogComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AppConfigDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
