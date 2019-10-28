# HTAP Demo

This demo shows how IRIS can ingest thousands or millions of records per second while allowing for queries on the same cluster. Works on a single IRIS instance or on an IRIS cluster on the cloud (using ICM - still working on this).

The picture bellow shows the architecture of the HTAP Demo:

![Demo Landing Page](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/README.png?raw=true)

Each This demo uses docker-compose to start four services:

* htapui - this is the Angular UI you use to run the demo.
* htapirisdb - this is IRIS Community! So you don't need an IRIS license to run this demo. But it is bad because IRIS Community has two important limitations:
 - Max of 5 connections: So we won't be able to use a high number of threads
 - Max Database size of 10Gb: So we won't be able to let the speed test run for too long
* htapmaster - This is the HTAP Demo master. The UI talks to it and to start/stop the speed test.
* ingest-worker1 - This is an ingestion worker. You can actually have more than one ingestion worker. Just give each one a different service name. They will try to flood IRIS with INSERTs.
* query-worker1 - This is the a consumption worker. You can have more than one of these as well. 

If you want to run the speed test demo on IRIS standard, there is an example of a docker-compose.yml file for it. But you are going to need an IRIS license to run it. The example is on iris-enterprise-docker-compose.xml.


## How to run the demo

To just run the demo on your PC, make sure you have Docker installed on your machine. You can quickly get it up and running with the folloing commands:

```bash
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/docker-compose.yml
wget https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/.env
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

# Report any Issues

Please, report any issues on the [Issues section](https://github.com/intersystems-community/irisdemo-demo-htap/issues).
