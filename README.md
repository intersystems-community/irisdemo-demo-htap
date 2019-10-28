# HTAP Demo

This demo shows how IRIS can ingest thousands or millions of records per second while allowing for queries on the same cluster. Works on a single IRIS instance or on an IRIS cluster on the cloud (using ICM - still working on this).

The picture bellow shows the architecture of the HTAP Demo:

![Demo Landing Page](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-twittersentiment/master/README.png?raw=true)

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

After all the containers have started, open the demo landing page on [http://localhost:9092/csp/appint/demo.csp](http://localhost:52773/csp/appint/demo.csp).

Use the username **SuperUser** and the password **sys**. This is just a demo that is running on your machine, so we are using a default password. You will see the demo landing page. Everything that is purple on this screen is something you can click an open a specific screen of the demo. Click on the bottom/right button that reads **Show Instructions** to understand how to configure your Twitter credentials on the demo.

# Architecture

This demo uses docker-compose to start four services:

* twittersrv - This service runs an IRIS integration production that has a native business service that implements the HTTP Streaming Protocol and the statuses/filter API for streaming tweets in real time. You are going to need Twitter Credentials to use the API (and run the demo). 
* twittersentiment - This is where all tweets are being stored. We want to do that in order to use NLP capabilities to explore past and current tweets to keep enhancing our dictionaries and services. This box exposes a REST service we call from the twittersrv to get the sentiment score.
* callcenterdb - This service is the database of a simulated legacy CRM application. This database is IRIS and it exposes a SOAP service that the twittersrv calls to create a ticket in the callcenter application.
* callcenterui - This is a Java application that simulates the UI of the CRM application. 

# Highlights

This demo helps us to demonstrate:
* IRIS Community
* Product features:
    - Containers Support
    - Native Twitter Streaming Integration (requires a Twitter credential)
    - Basic IRIS Productions (Business Services, Processes and Operations)
    - Business Processes
    - Business Rules with Tweets Metadata (number of followers, number of retweets, etc) and the sentiment score of the tweets' text.
    - Message Trace
    - IRIS NLP with Sentiment Analysis, Business Dictionaries and Negation
    - IRIS NLP Explorer
    - SQL
    - SOAP Integration 
    - REST Integration
* Java Application built with Java Prime Faces and IRIS JDBC

# Report any Issues

Please, report any issues on the [Issues section](https://github.com/intersystems-community/irisdemo-demo-twittersentiment/issues).
