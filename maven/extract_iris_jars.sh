#!/bin/bash

# I created this script in order to extract the InterSystems jar files from the iris docker container
# and register them on my local maven so that I can 

# To run this script, make sure docker-compose up is run first.

rm -rf ./irislib
mkdir ./irislib

docker run -d --name iris --rm intersystemsdc/irisdemo-base-irisdb-community:version-1.8.0
sleep 10

docker cp iris:/usr/irissys/dev/java/lib/JDK18/intersystems-jdbc-3.2.0.jar ./irislib/
docker cp iris:/usr/irissys/dev/java/lib/JDK18/intersystems-xep-3.2.0.jar ./irislib/
docker cp iris:/usr/irissys/dev/java/lib/JDK18/intersystems-utils-3.2.0.jar ./irislib/

docker stop iris