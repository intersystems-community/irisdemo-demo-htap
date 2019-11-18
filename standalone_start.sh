#!/bin/bash

INGESTION_THREADS_PER_WORKER=10
DISABLE_JOURNAL_FOR_DROP_TABLE=false
DISABLE_JOURNAL_FOR_TRUNCATE=false
INGESTION_THREADS_PER_WORKER=10
INGESTION_BATCH_SIZE=1000
INGESTION_JDBC_URL=jdbc:IRIS://localhost:51773/USER
INGESTION_JDBC_USERNAME=SuperUser
INGESTION_JDBC_PASSWORD=sys
CONSUMER_JDBC_URL=jdbc:IRIS://localhost:51773/USER
CONSUMER_JDBC_USERNAME=SuperUser
CONSUMER_JDBC_PASSWORD=sys
CONSUMER_THREADS_PER_WORKER=10
CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS=0

# Spring boot mode. Service means it will run on the background
MODE="service"

echo
echo '********************************************************************************'
echo 'Starting Master'
echo '********************************************************************************'
echo

./master.jar start

echo
echo '********************************************************************************'
echo 'Starting IRIS JDBC Ingestion Worker'
echo '********************************************************************************'
echo

./iris-jdbc-ingest-worker.jar start

echo
echo '********************************************************************************'
echo 'Starting IRIS JDBC Query Worker'
echo '********************************************************************************'
echo

./iris-jdbc-query-worker.jar start

echo
echo '********************************************************************************'
echo 'Starting IRIS Container for testing'
echo '********************************************************************************'
echo

docker run --init --rm -name iris_htap -p 51773:51773 -p 52773:52773 store/intersystems/iris-community:2019.4.0.379.0

echo
echo '********************************************************************************'
echo 'Starting UI'
echo '********************************************************************************'
echo

(
    cd ./image-ui && \
    npm run proxy
)