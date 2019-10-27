import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TestRunnerRootComponent } from './test-runner-root.component';

describe('TestRunnerRootComponent', () => {
  let component: TestRunnerRootComponent;
  let fixture: ComponentFixture<TestRunnerRootComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TestRunnerRootComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TestRunnerRootComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
