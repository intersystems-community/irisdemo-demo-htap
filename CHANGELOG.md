## 2.3.0 (January 31, 2020)
  - IRIS Speed Test is now based on IRIS Community 2020.1.0.197.0
  - Adding reference to the readmission demo to the "other demos" section
  - Reverting to IRIS 2019.3. 
  - Adding Enable CallIn Procedure to Master to support XEP
  - Removing env.sh
  - Multiple ICM instance types now supported. Adding support for merge.cpf

## 2.2.1 (December 31, 2019)
  - Adding support to SAP HANA for ICM
  - Documentation

## 2.1.0 (December 19, 2019)
  - Adding support for ICM. Fixing UI bugs. Allowing configuration of the Speed TEst from the UI
  - Adding support for SAP HANA
  - Upgrading to docker-compose format 3.7. Eliminating condition under depends_on
  - fixing computeAggregateMetrics method to use seconds instead of milliseconds when appropriate
  - Removing target folder. Fixing typos on README.md
  - adding updates for chart axis naming
  - adding updates for dynamic title population
  - Adding server side support for getTitle()
  - Improving standalone scripts and documentation

## 2.0.5 (December 02, 2019)
  - Architecture refactored to support multiple databases and connectivity models beyond JDBC.
  - Added support for MySQL
  - Can now be run standalone

## 1.0 
  - Initial version
