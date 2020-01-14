# Hybrid Transactional-Analytical Processing (HTAP) Demo

The capability to ingest thousands or millions of records per second while allowing for simultaneous queries in real time is required by many use cases across multiple industries, e.g. equity trade processing, fraud detection, IoT applications including anomaly detection and real time OEE, etc.  Gartner calls this capability ["HTAP" (Hybrid Transactional Analytical Processing)](https://www.gartner.com/imagesrv/media-products/pdf/Kx/KX-1-3CZ44RH.pdf). Others such as Forrester call it [Translytics](https://www.forrester.com/report/The+Forrester+Wave+Translytical+Data+Platforms+Q4+2017/-/E-RES134282). InterSystems IRIS is a powerful, scalable, high performance and resource efficient transactional-analytic data platform that provides the performance of in-memory databases with the consistency, availability, reliability, lower costs of traditional databases. 

This demo shows how InterSystems IRIS can ingest thousands of records per second while allowing for simultaneous queries on the data on the same cluster with very high performance for both ingestion and querying, and with low resource utilization. The demo works on a single IRIS instance or on an IRIS cluster on the cloud.

The same demo can be run on SAP HANA, MySQL, and Amazon Aurora MySQL to compare performance and resource utilization in “apples-to-apples” comparisons.

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
* **docker-compose-enterprise-iris.yml** - If you want to run the speed test demo on IRIS standard, there is an example of a docker-compose.yml file for it.

## How to run the demo against IRIS Community

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

## How to run the demo against other databases

You can currently run this demo with MySQL and SAP HANA.

### MySQL

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

### SAP Hana

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

## Can I run this Speed Test on AWS?

Yes. Follow instructions [here](https://github.com/intersystems-community/irisdemo-demo-htap/blob/master/ICM/README.md).

## How do I configure this demo to run with more workers, threads, etc?

Look at the docker-compose.yml file and you will notice environment variables that will allow you to configure everything. The provided docker-compose yml files are just good starting points. You can copy them and change your copies to have more workers (it won't make a lot of difference if you are running on your PC), higher number of threads per worker type, change the ingestion batch size, wait time in milliseconds between queries on the consumter, etc.

## Can I change the table name or structure?

Yes, but you will have to:
* Fork this repo on your PC
* Change the source code
* Rebuild the demo on your PC using the shellscript build.sh.

Changing the table structure should be simple. 

After forking, you need to change the files on folder [/image-master/projects/master/src/main/resources](https://github.com/intersystems-community/irisdemo-demo-htap/tree/master/image-master/projects/master/src/main/resources).

If you change the TABLE structure, make sure you use the same data types I am using on the existing table. Those are the data types supported. You can also change the name of the table. 

Then, change the other *.sql scripts to match your changes. The INSERT script, the SELECT script, etc.

Finally, just run the build.sh to rebuild the demo and you should be ready to go!

# Can I run this without containers?

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

# Report any Issues

We have already a list of things to:
  * Implement an XEP (Extreme Event Processing) based version of this demo. 
  * Add support to databases such as Postgress.
  * Make the UI more responsive when stopping and restarting the Speed Test. We truncate the table before restarting the speed test and this may take some time and a lot of journal entries. The UI will become unresponsive for a while and there is no indication that anything is being done. We need to fix this.
  
Please, report any issues on the [Issues section](https://github.com/intersystems-community/irisdemo-demo-htap/issues).

# Other demo applications

There are other IRIS demo applications that touch different subjects such as NLP, ML, Integration with AWS services, Twitter services, performance benchmarks etc. Here are some of them:
* [HTAP Demo](https://github.com/intersystems-community/irisdemo-demo-htap) - Hybrid Transaction-Analytical Processing benchmark. See how fast IRIS can insert and query at the same time. You will notice it is up to 20x faster than AWS Aurora!
* [Fraud Prevention](https://github.com/intersystems-community/irisdemo-demo-fraudprevention) - Apply Machine Learning and Business Rules to prevent frauds in financial services transactions using IRIS.
* [Twitter Sentiment Analysis](https://github.com/intersystems-community/irisdemo-demo-twittersentiment) - Shows how IRIS can be used to consume Tweets in realtime and use its NLP (natural language processing) and business rules capabilities to evaluate the tweet's sentiment and the metadata to make decisions on when to contact someone to offer support.
* [HL7 Appointments and SMS (text messages) application](https://github.com/intersystems-community/irisdemo-demo-appointmentsms) -  Shows how IRIS for Health can be used to parse HL7 appointment messages to send SMS (text messages) appointment reminders to patients. It also shows real time dashboards based on appointments data stored in a normalized data lake.
