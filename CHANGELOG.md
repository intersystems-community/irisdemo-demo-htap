## 2.4.11 (April 23, 2020)
  - Adding support for specifying how many keys query workers should be fetching
  - Updating SAP HANA's results
  - Updating AWS Aurora Results
  - Displaying VPC information after provisioning just in case user wants to test just a non-IRIS database

## 2.4.10 (April 21, 2020)
  - Fixing problem with results.csv where initial lines had zero values
  - Better name for a method
  - Adding docker_safe_cleanup.sh script

## 2.4.9 (April 21, 2020)
  - Making sure we are using IRIS JDBC Driver for 2020.2

## 2.4.8 (April 21, 2020)
  - Allowing user to close web browser and reopen it on starting state.
  - Adding intermediate state 'starting' to the Run Test button.

## 2.4.7 (April 21, 2020)
  - Adding better workaround support to ICM scripts
  - Adding support for pre-expanding database for IRIS and SQL Server before test starts

## 2.4.5 (April 19, 2020)
  - Making Test be based on IRIS 2020.2.0.196.0
  - Immediately hide Start Button after pressing it. Show a starting message instead. Show stop button just after we know the test has been started successfully.
  - Adding support for SQL Server on AWS

## 2.4.4 (April 16, 2020)
  - Documenting metrics on CSV on README.md file
  - Adding missing metric to CSV file: queryAndConsumptionTimeInMs
  - Adding reference to the change log

## 2.4.3 (April 15, 2020)
  - Speed Test UI can now be closed, leaving the test running on the server. It can be opened again to check on progress and download the results of the test.
  - Adding new configuration field to the UI to specify maximum time to run the test
  - Adding stop_containers.sh to stand alone scripts.

## 2.4.2 (April 14, 2020)
  - Adding button to the UI so we can retrieve the results as a csv file.
  - Adding  --stateDir state to unprovision template
  - Adding more information to the README
  
## 2.4.1 (March 13, 2020)
  - Adding reconnect parameter to JDBC connection for SAP HANA
  - Documenting avg size of record in DATA and JOURNAL
  - Increasing size of DATA and JOURNAL so we can test IRIS for about 90min on AWS i3.xlarge against SAP HANA
  - Final results for SAP HANA
  - Moving change of firewall configurations from setup to provision
  - Fixing bug on ICM that prevented us from mounting the DATA volume
  - Documentation for running with AWS Aurora
  - Full support for SAP HANA Documentation
  
## 2.4.0 (February 17, 2020)
  - Support for SQL Server
  - Adding bouncespeedtest.sh script. When using an ICM deployment, it will restart all CN containers for us.
  - Adding support for AWS Aurora to ICM scripts

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
