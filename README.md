# Hybrid Transactional-Analytical Processing (HTAP) Demo

The capability to ingest thousands or millions of records per second while allowing for simultaneous queries in real time is required by many use cases across multiple industries, e.g. equity trade processing, fraud detection, IoT applications including anomaly detection and real time OEE, etc.  Gartner calls this capability ["HTAP" (Hybrid Transactional Analytical Processing)](https://www.gartner.com/imagesrv/media-products/pdf/Kx/KX-1-3CZ44RH.pdf). Others such as Forrester call it [Translytics](https://www.forrester.com/report/The+Forrester+Wave+Translytical+Data+Platforms+Q4+2017/-/E-RES134282). InterSystems IRIS is a powerful, scalable, high performance and resource efficient transactional-analytic data platform that provides the performance of in-memory databases with the consistency, availability, reliability, lower costs of traditional databases. 

This demo shows how InterSystems IRIS can ingest thousands of records per second while allowing for simultaneous queries on the data on the same cluster with very high performance for both ingestion and querying, and with low resource utilization. The demo works on a single IRIS instance or on an IRIS cluster on the cloud.

The same demo can be run on SAP HANA, MySQL, SqlServer and Amazon Aurora to compare performance and resource utilization in “apples-to-apples” comparisons. 

You can run the tests on AWS! Here are some results:
* [InterSystems IRIS x SAP HANA run on AWS](https://github.com/intersystems-community/irisdemo-demo-htap/blob/master/ICM/DOC/IRIS_x_SAPHANA.md):
  * InterSystems IRIS is 1.392x faster than SAP HANA at ingestion (39.25% faster)
  * Intersystems IRIS is 24.93x faster than SAP HANA at querying (2393% faster!)
* [InterSystems IRIS x AWS Aurora (MySQL)](https://github.com/intersystems-community/irisdemo-demo-htap/blob/master/ICM/DOC/IRIS_x_AWSAuroraMySql.md):
  * InterSystems IRIS is 9.35x faster than AWS Aurora at ingestion (835% faster!)
  * Intersystems IRIS is 5.85x faster than AWS Aurora at querying (485% faster!)

You can run the tests on your own PC using Dockers (3 CPUs and 7GB of RAM)! Here are some results:
* InterSystems IRIS x MySQL 8.0:
  * InterSystems IRIS is 31x faster than MySQL 8.0 at ingestion
  * Intersystems IRIS is 6x faster than MySQL 8.0 at querying
* InterSystems IRIS x SQL Server 2019 for Ubuntu
  * InterSystems IRIS is 2.2x faster than SQL Server 2019 at ingestion
  * Intersystems IRIS is 1346x faster than SQL Server 2019 at querying (not kidding!)


**When running the speed test against any database, before taking notes of the results, let the speed test run for a while to warm it up. That will allow the database to pre-expand and do other things. Every time you start the speed test, we TRUNCATE the table to start over.**

## 1 - Running the Speed Test on AWS

Follow [this link](/ICM/README.md) to see instructions on how to run this Speed Test on AWS comparing IRIS with other databases such as SAP HANA and AWS Aurora.

## 2 - How to run it on your PC

The pre-requisites for running the speed test on your PC are:
* Docker and Docker Compose
* Git (so you can clone this source code)

You can currently run this demo on your PC with InterSystems IRIS, MySQL, SqlServer and SAP HANA.

### 2.1 - Run it with IRIS Community

To run the demo on your PC, make sure you have Docker installed on your machine. You can quickly get it up and running with the following commands on your Mac or Linux PC:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose.yml
docker-compose up
```

If you are runing on Windows, download the [docker-compose.yml](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose.yml) file to a folder. Open a command prompt and change to that folder. Then run **docker-compose up**.

You can also clone this repository to your local machine to get the entire source code. You will need git installed and you would need to be on your git folder:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-htap
cd irisdemo-demo-htap
docker-compose up
```

Both techniques should work and should trigger the download of the images that compose this demo and it will soon start all the containers.

When starting, you will see lots of messages from all the containers that are staring. That is fine. Don't worry!

When it is done, it will just hang there, without returning control to you. That is fine too. Just leave this window open. If you CTRL+C on this window, docker compose will stop all the containers and stop the demo.

After all the containers have started, open a browser at [http://localhost:10000](http://localhost:10000) to see the demo UI. Just click on the **Run Test** button to run the HTAP Demo!

When you are done, go back to that terminal and enter CTRL+C. You may also want to enter with the following commands to stop containers that may still be running and remove them:

```bash
docker-compose stop
docker-compose rm
```

This is important, specially if you are going back and forth between running the speed test on one database (say InterSystems IRIS) and some other (say MySQL).

### 2.2 - MySQL on your PC

To run this demo against MySQL:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose-mysql.yml
docker-compose -f ./docker-compose-mysql.yml up
```

Now, we are downloading a different docker-compose yml file; one that has the **mysql** suffix on it. And we must use **-f** option with the docker-compose command to use this file. As before, leave this terminal window open and open a browser at http://localhost:10000.

When you are done running the demo, go back to this terminal and enter CTRL+C. You may also want to enter with the following commands to stop containers that may still be running and remove them:

```bash
docker-compose -f ./docker-compose-mysql.yml stop
docker-compose -f ./docker-compose-mysql.yml rm
```

This is important, specially if you are going back and forth between running the speed test on one database (say InterSystems IRIS) and some other.

In our tests, we found IRIS to ingest data 25X faster than MySQL and Amazon Aurora.

### 2.3 - SQL Server 2019-GA-ubuntu-16.04 on your PC

To run this demo against SQL Server:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose-sqlserver.yml
docker-compose -f ./docker-compose-sqlserver.yml up
```

As before, leave this terminal window open and open a browser at http://localhost:10000.

In our tests running on a local PC, we found IRIS to ingest data 2.5X faster than SQL Server while query rates were 400X faster! We will test it against AWS RDS SQL Server and report.

### 2.4 - SAP Hana on your PC

To run the speed test with SAP HANA on your PC you will need:
* A VM with Ubuntu 18 VM, docker and docker-compose - because SAP HANA requires some changes to the Linux Kernel parameters that we otherwise couldn't do using Docker for Mac or Docker for Windows. Also, SAP HANA requires a Linux Kernel version 4 or superior.
* Provision at least 9 GB of RAM to this VM otherwise it will not even start! It will crash with an unhelpful error message.

To run this demo against SAP HANA:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-htap
cd ./irisdemo-demo-htap
./run.sh hana
```

Wait for the images to download and for the containers to start. You will know when everything is up once docker-compose stops writing to the screen. But be patient - SAP HANA takes about 6 minutes to start! So, your screen will freeze for a minute or so and then you will see SAP HANA writing more text. It will repeat this for about 6 minutes.. Once you see the text "Startup finished!" you should be good to go. If it crashes with an error, it is probably because you need to give it more memory.

As you can see, it is not just a matter of running docker-compose up as it is with IRIS and MySQL. SAP HANA requires some configurations to the Linux Kernel. The run.sh will do these configurations for you.

In our tests running the Speed Test on a VM, we found IRIS to be 1.3X faster than SAP HANA for ingesting data, and 20X faster for querying data, and uses a fraction of the memory. 

## 3 - Resources

A video about this demo is in the works! In the meantime, [here](https://www.intersystems.com/resources/detail/a-superior-alternative-to-in-memory-databases-and-key-value-stores/) is an interesting article that talks about InterSystems IRIS architecture and what makes it faster.

## 4 - How does this benchmark compare against standard benchmarks such as YCSB or TPC-H?

The open-source Yahoo Cloud Serving Benchmark ([YCSB](https://en.wikipedia.org/wiki/YCSB)) project aims to develop a framework and common set of workloads for evaluating the performance of different “key-value” and “cloud” serving stores. 

Although there are workloads on YCSB that could be described as HTAP, YCSB doesn't necessarily rely on SQL to do it. This benchmark does.

TPC-H is focused on decision support systems (DSS) and that is not the use case we are exploring. 

This benchmark is about **ingestion rate** versus **query response time**. We have a single table with many columns of different data types. We want to measure how fast a database can ingest the records while, at the same time, allowing for responsive queries.

This is not a simple problem. Many industries such as Financial Services and IoT have to ingest thousands of records per second. At very high ingestion rates, memory is consumed very quickly. Traditional Databases need to write to disk to keep ingesting while In Memory Databases will also be forced to constantly write to disk as well. At the end of the day, the most efficient SQL database wins.

## 5 - Can I see the table?

Here is the the statement we send to all databases we support:

```SQL
CREATE TABLE SpeedTest.Account
(
    account_id VARCHAR(36) PRIMARY KEY,
    brokerageaccountnum VARCHAR(16),
    org VARCHAR(50),
    status VARCHAR(10),
    tradingflag VARCHAR(10),
    entityaccountnum VARCHAR(16),
    clientaccountnum VARCHAR(16),
    active_date DATETIME,
    topaccountnum VARCHAR(10),
    repteamno VARCHAR(8),
    repteamname VARCHAR(50),
    office_name VARCHAR(50),
    region VARCHAR(50),
    basecurr VARCHAR(50),
    createdby VARCHAR(50),
    createdts DATETIME,
    group_id VARCHAR(50),
    load_version_no BIGINT  
)
```

The Ingestion Worker will send as many INSERTs as possible as measure the number of records/sec inserted as well as the number of Megabytes/sec. 

The Query Worker will SELECT from this table by account_id and try to select as many records as possible measuring it as records/sec selected as well as Megabytes/sec select to test the **end-to-end performance** and to provide **proof of work**.

End-to-end performance has to do with the fact that some JDBC drivers have optmizations. If you just execute the query, the JDBC driver may not fetch the record from the server until you actually request for a value of a column. 

To proove that we are actually reading the columns we are SELECTing, we sum up the bytes of all the filds reeturned as **proof of work**.

## 6 - Architecture of the HTAP Demo

The architecture of the HTAP demo is shown below:

![Demo Landing Page](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/README.png?raw=true)

This demo uses docker compose to start five services:

* **htapui** - this is the Angular UI you use to run the demo.
* **htapirisdb** - since the demo is running on IRIS Community, you don't need an IRIS license to run it. But be aware that IRIS Community has two important limitations:
  * Max of 5 connections
  * Max Database size of 10Gb
* **htapmaster** - This is the HTAP Demo master. The UI talks to it and it talks to the workers to start/stop the speed test and collect metrics.
* **ingest-worker1** - This is an ingestion worker. You can actually have more than one ingestion worker; just give each one a different service name. They will try to INSERT records into the database as fast as possible.
* **query-worker1** - This is the consumption worker. You can have more than one of these as well. They will try to read records out of the database as fast as possible.

When running the demo on our PCs, we use Docker and Docker Compose. Docker Compose expects a **docker-compose.yml** that describes these services and the docker images they use. This demo actually provides many docker-compose.yml files and more will be added soon:
* **docker-compose.yml** - This is the default demo that runs the speed test against IRIS Community described on the bullets and picture above.
* **docker-compose-mysql.yml** - This is the speed test against MySQL. You will notice that the same test shows that IRIS is 25x faster than MySQL. Running this test against Amazon Aurora MySQL (that is a fine tuned version of MySQL) produced the same results.
* **docker-compose-sqlserver.yml** - This is the speed test against SqlServer for Dockers. 
* **docker-compose-enterprise-iris.yml** - If you want to run the speed test demo on IRIS standard, there is an example of a docker-compose.yml file for it.

## 7 - Can I run this without containers against a random IRIS Cluster?

Yes! The easiest way to get this done is to clone this repo on each server where you are planning on running the master and the UI (they run on the same server) and on each worker type (ingestion and query workers). You may have as many ingestion workers and query workers as you want! 

Then, for InterSystems IRIS, look at the files on folder [./standalone_scripts/iris-jdbc](https://github.com/intersystems-community/irisdemo-demo-htap/tree/master/standalone_scripts/iris-jdbc). There is a script for every server:
* **On the Master**: start_master_and_ui.sh - This script will start both the master and the UI.
* **On the Ingestion Workers**: start_ingestion_worker.sh - This script will start the ingestion worker which in turn will connect and register with the master.
* **On the Query Workers**: start_query_worker.sh - This script will start the query worker which in turn will connect and register with the master.

What about IRIS? You have two choices:
* You can use the start_iris.sh script to start an IRIS server on a docker container for a quick test.
* You can provision your IRIS cluster by hand or using ICM. Then you could do fancy things such as:
  * Have both the ingestion and query workers pointing to the same IRIS box
  * Configure IRIS with ECP and have the ingestion workers pointing to the database server while having the query workers pointing to the ECP servers
  * Configure a sharded IRIS cluster
  * etc.

Just make sure you change your start_master.sh script to configure the environment variables with the correct IRIS end points, usernames and passwords.

## 8 - Customizations

### 8.1 - How do I configure this demo to run with more workers, threads, etc?

Look at the docker-compose.yml file and you will notice environment variables that will allow you to configure everything. The provided docker-compose yml files are just good starting points. You can copy them and change your copies to have more workers (it won't make a lot of difference if you are running on your PC), higher number of threads per worker type, change the ingestion batch size, wait time in milliseconds between queries on the consumter, etc.

### 8.2 - Can I change the table name or structure?

Yes, but you will have to:
* Fork this repo on your PC
* Change the source code
* Rebuild the demo on your PC using the shellscript build.sh.

Changing the table structure should be simple. 

After forking, you need to change the files on folder [/image-master/projects/master/src/main/resources](https://github.com/intersystems-community/irisdemo-demo-htap/tree/master/image-master/projects/master/src/main/resources).

If you change the TABLE structure, make sure you use the same data types I am using on the existing table. Those are the data types supported. You can also change the name of the table. 

Then, change the other *.sql scripts to match your changes. The INSERT script, the SELECT script, etc.

Finally, just run the build.sh to rebuild the demo and you should be ready to go!

## 9 - Other demo applications

There are other IRIS demo applications that touch different subjects such as NLP, ML, Integration with AWS services, Twitter services, performance benchmarks etc. Here are some of them:
* [HTAP Demo](https://github.com/intersystems-community/irisdemo-demo-htap) - Hybrid Transaction-Analytical Processing benchmark. See how fast IRIS can insert and query at the same time. You will notice it is up to 20x faster than AWS Aurora!
* [Fraud Prevention](https://github.com/intersystems-community/irisdemo-demo-fraudprevention) - Apply Machine Learning and Business Rules to prevent frauds in financial services transactions using IRIS.
* [Twitter Sentiment Analysis](https://github.com/intersystems-community/irisdemo-demo-twittersentiment) - Shows how IRIS can be used to consume Tweets in realtime and use its NLP (natural language processing) and business rules capabilities to evaluate the tweet's sentiment and the metadata to make decisions on when to contact someone to offer support.
* [HL7 Appointments and SMS (text messages) application](https://github.com/intersystems-community/irisdemo-demo-appointmentsms) -  Shows how IRIS for Health can be used to parse HL7 appointment messages to send SMS (text messages) appointment reminders to patients. It also shows real time dashboards based on appointments data stored in a normalized data lake.
* [The Readmission Demo](https://github.com/intersystems-community/irisdemo-demo-readmission) - Patient Readmissions are said to be the "Hello World of Machine Learning" in Healthcare. On this demo, we use this problem to show how IRIS can be used to **safely build and operationalize** ML models for real time predictions and how this can be integrated into a random application. This **IRIS for Health** demo seeks to show how a full solution for this problem can be built.

## 10 - Report any Issues
  
Please, report any issues on the [Issues section](https://github.com/intersystems-community/irisdemo-demo-htap/issues).
