# HTAP Demo

**DISCLAIMER: Running this demo on Docker, with reduced resources, on a single PC may lead to poor performance. I get about 60K inserts per second on my Mac (docker machine with 3 cores and 5Gb of RAM). But MySQL and Aurora can't do better than that running on bigger machines and with the best tunning! So, as long as you give people context, running this on Dockers is fine. But this speed test can also be run against MySQL. So, if you run it on your PC, try running it once against IRIS and again against MySQL. This just another way of providing context.**

The capability of ingesting thousands or millions of records per second while allowing for consistent queries in realtime is required by many use cases across multiple industries. Equity Trade processing, IoT data Ingestion for anomaly detection or realtime OEE, etc. Gartner calls this capability ["HTAP" (Hybrid Transactional Analytical Processing)](https://www.gartner.com/imagesrv/media-products/pdf/Kx/KX-1-3CZ44RH.pdf). Others such as Forrester call it Trans-analytics or [Translytics](https://www.forrester.com/report/The+Forrester+Wave+Translytical+Data+Platforms+Q4+2017/-/E-RES134282).

InterSystems IRIS is a very powerful and scalable Translytics data platform that provides the performance of in-memory databases with the consistency, reliability and SQL support of traditional databases. This demo shows how IRIS can support HTAP/Trans-analytics by ingesting thousands of records per second while allowing for consistent queries at the same time on a very small hardware footprint (your PC!). 

The picture bellow shows the architecture of the HTAP Demo:

![Demo Landing Page](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/README.png?raw=true)

This demo uses docker compose to start four services:

* **htapui** - this is the Angular UI you use to run the demo.
* **htapirisdb** - this is IRIS Community! So you don't need an IRIS license to run this demo. But it is bad because IRIS Community has two important limitations:
 * Max of 5 connections: So we won't be able to use a high number of threads
 * Max Database size of 10Gb: So we won't be able to let the speed test run for too long
* **htapmaster** - This is the HTAP Demo master. The UI talks to it and to start/stop the speed test.
* **ingest-worker1** - This is an ingestion worker. You can actually have more than one ingestion worker. Just give each one a different service name. They will try to flood the database with INSERTs.
* **query-worker1** - This is the a consumption worker. You can have more than one of these as well. 

Docker Compose expects a docker-compose.yml that describes these services. This demo actually provides many docker-compose.yml files and more will be added soon:
* **docker-compose.yml** - This is the default demo that runs the speed test against IRIS Community described on the bullets and picture above.
* **docker-compose-mysql.yml** - This is the speed test against MySQL. You will notice that the same test shows that IRIS is 20x faster than MySQL. We have run this test against AWS Aurora (that is a fine tuned version of MySQL) and the results were the same.
* **docker-compose-enterprise-iris.yml** - If you want to run the speed test demo on IRIS standard, there is an example of a docker-compose.yml file for it. But you are going to need an IRIS license to run it. The example is on iris-enterprise-docker-compose.xml.
* Other databases will be added soon.

## How to run the demo against IRIS Community

To just run the demo on your PC, make sure you have Docker installed on your machine. You can quickly get it up and running with the folloing commands:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose.yml
docker-compose up
```

You can also clone this repository to you local machine to get the entire source code. You will need git installed and you would need to be on your git folder:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-htap
cd irisdemo-demo-htap
docker-compose up
```

Both techniques should work and should trigger the download of the images that compose this demo and it will soon start all the containers. 

When starting, it is going to show you lots of messages from all the containers that are staring. That is fine. Don't worry.

When it is done, it will just hang there, without returning control to you. That is fine too. Just leave this window open. If you CTRL+C on this window, docker compose will stop all the containers (and stop the demo!).

After all the containers have started, open the it on [http://localhost:10000](http://localhost:10000).

Just click on the **Run Test** button to run the HTAP Demo!

When you are done, go back to that terminal and enter CTRL+C. You may also want to enter with the following commands to stop containers that may still be running and remove them:

```bash
docker-compose stop
docker-compose rm
```

This is important, specially if you are going back and forth between running the speed test on one database (say InterSystems IRIS) and some other (say MySQL).

## How to run the demo against other databases

Let's say we want to run this demo against MySQL. The steps a very similar:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose-mysql.yml
docker-compose -f ./docker-compose-mysql.yml up
```

Now, we are downloading a different docker-compose yml file. One that has the **mysql** suffix on it. And we must use **-f** option of the docker-compose command to say we want to use this file. As before, leave this terminal window open and open a browser at http://localhost:10000.

When you are done, go back to this terminal and enter CTRL+C. You may also want to enter with the following commands to stop containers that may still be running and remove them:

```bash
docker-compose -f ./docker-compose-mysql.yml stop
docker-compose -f ./docker-compose-mysql.yml rm
```

This is important, specially if you are going back and forth between running the speed test on one database (say InterSystems IRIS) and some other.

# How I configure this demo to run with more workers, threads, etc?

Look at the docker-compose.yml file and you will notice environment variables that will allow you to configure everything. The provided docker-compose yml files are just good starting points. You can copy them and change your copies to have more workers (it won't make a lot of difference if you are running on your PC), higher number of threads per worker type, change the ingestion batch size, wait time in milliseconds between queries on the consumter, etc.

# Can I change the table name or structure?

Yes, but you will have to rebuild the demo on your PC using the shellscript build.sh.

First, you need to change the files on folder [/image-master/projects/master/src/main/resources](https://github.com/intersystems-community/irisdemo-demo-htap/tree/master/image-master/projects/master/src/main/resources).

If you change the TABLE structure, make sure you use the same data types I am using on the existing table. Those are the data types supported. You can also change the name of the table. 

Then, change the other scripts to match your changes. The INSERT script, the SELECT script, etc.

Finally, just run the build.sh to rebuild the demo and you should be ready to go!

# Report any Issues

We have already a long list of things to:
* Things that are amost done:
  * Implement an XEP (Extreme Event Processing) based version of this demo. 
  * Add support to databases such as Postgress.
  * Add support for running this using ICM on AWS (so we can test against Aurora)
  * Allow configuration of the speed test through the UI instead of environment variables on the docker-compose.yml file.
* Things that are going to be fixed:
  * The label on the UI is always "IRIS Speed Test" even when we are testing against other databses. 
  * Make every graph show one single metric instead of combined metrics. When we mix metrics on the same chart, one may be on a much bigger scale than another.
  * Make the UI more responsive when stopping and restarting the Speed Test. We truncate the table before restarting the speed test and this may take some time and a lot of journal entries. The UI will become unresponsive for a while and there is no indication that anything is being done. We need to fix this.
  
Please, report any issues on the [Issues section](https://github.com/intersystems-community/irisdemo-demo-htap/issues).
