## 2.8.5 (June 12, 2023)
  - Removing kubernetes stuff and adding support for IRIS 2023.2

## 2.8.4 (January 26, 2022)
  - Bumping IRIS version to 2021.2.0.649.0

## 2.8.2 (January 08, 2022)
  - Bumping IRIS version to 2021.2.0.637.0

## 2.8.1 (December 28, 2021)
  - Fixing version of parent docker image to node:10.24.1-alpine3.11 in order to prevent error 'Error: error:0308010C:digital envelope routines::unsupported'

## 2.8.0 (December 28, 2021)
  - Bumped IRIS and ICM version to 2021.2.0.619.0

## 2.7.2 (August 10, 2021)
  - Making worker machine type and java JMX configurable

## 2.7.1 (August 10, 2021)
  - Increasing amount of memory of query workers to 6144Mb

## 2.7.0 (August 10, 2021)
  - Making the query workers fetch all keys (not only the first 4)
  - Making speed test containers run with --security-opt seccomp=unconfined --privileged
  - Bumping IRIS version to 2021.1.0.215.0
  - Adding code that helps us to extract jar files from a running IRIS image and register it on our local maven repository.

## 2.6.1 (July 21, 2021)
  - Adding functions to stop/start containers in machines
  - IRIS 2021.1.215 uses port 1972 as its default Super Server port.
  - Eliminating asyncwij from merge.cpf because it seems it is not supported anymore by IRIS 2021.1
  - Bumping the version of IRIS to 2021.1.215.0
  - fixing global buffers for m5.xlarge
  - added support for ECP
  - Fixing issue with powershell that would cause it to crash when multiple lines were intered in CONF_ICM_TAG or CONF_ICM_REPO
  - Documentation fixes and fix to ICM registry location
  - Fixing typo on license folder name
  - Making sure the license folder will exist
  - Several Angular UI security updates

## 2.6.0 (December 04, 2020)
 - Adding support for Kubernetes
 - Bumping to IRIS base image 1.7.1 because of messages.log problem.
 - Making workers exist after an exception so that Kubernetes can restart the container for us.

## 2.5.2 (October 14, 2020)
  - Making workers register with their IP addresses so that HTAP Demo can work on Kubernetes.

## 2.5.1 (October 13, 2020)
  - Improving error message given by workers when it is not possible to register with the master. In that case, the workers will also not exit instead of staying there doing nothing.
  - Bumping IRIS version to 2020.3.0.200.0
  - Update README.md
  - Adding support for Oracle on AWS

## 2.5.0 (September 02, 2020)
  - Normalizing code so that both container and containerless speedtests are deployed in the same way using VM ICM roles.
  - Making sure that ICMDurable/license/replace_this_file_with_your_iris_key is not there when it is time to provision
  - Leaving 10Gb left on the data folder when pre-expanding IRIS database
  - Making speedtest container image names shorter because of new ICM version
  - Using newer version of docker. Fixing missing ;; on deployspeedtest.sh
  - Changing ICM and IRIS version to 2020.3.0.200.0

## 2.4.26 (August 23, 2020)
  - Adding mariadb and postgres results
  
## 2.4.21 (June 23, 2020)
  - Improving documentation for using ICM with the HTAP demo.

## 2.4.18 (June 10, 2020)
  - Adding support for Sybase ASE
  - Adding more comments to SQL Server results
  - Template for m5.8xlarge
  - Adding script that removes all containers from AWS.

## 2.4.17 (May 19, 2020)
  - Fixing a dead lock when using more than one ingestion worker or query worker
  - Using getVPC to get VPC info
  - Using more recent amazon images
  - Fixing a bug with the ICM code that was using wrong state dir
  - Documentation - what is the difference against sysbench?
  - Adding documentation for the 2 new columns in results csv file.

## 2.4.16 (May 12, 2020)
  - Assigning independent thread pool to workers so that a higher number of threads can be used per worker
  - Adding more statistics. Fixing bug with avg metrics when throttling
  - Fixing avg rec/s for SQL Server
  - Fixing problem when avg curves for ingestion and query would be wrong if throttling was in use (adding ms wait time for batches and queries)
  - Changing the settings UI to allow for specifying a number of ms to wait between every inserted batch
  - Changing the report file to include the number of threads that were active on every second during the entire test

## 2.4.15 (April 27, 2020)
  - Adding dead lock optimizations to SQL Server

## 2.4.14 (April 27, 2020)
  - Finishing support for SQL Server on AWS

## 2.4.12 (April 23, 2020)
  - Correcting measurements of SAP HANA speed test.
  - Detecting where to create database file on SQL Server automatically

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
