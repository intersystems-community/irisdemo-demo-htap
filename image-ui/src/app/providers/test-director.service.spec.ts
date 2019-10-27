import { TestBed } from '@angular/core/testing';

import { TestDirectorService } from './test-director.service';

describe('TestDirectorService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: TestDirectorService = TestBed.get(TestDirectorService);
    expect(service).toBeTruthy();
  });
});
