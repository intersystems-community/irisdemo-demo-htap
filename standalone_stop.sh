#!/bin/bash

# Spring boot mode. Service means it will run on the background
MODE="service"

echo
echo '********************************************************************************'
echo 'Stopping UI'
echo '********************************************************************************'
echo


echo
echo '********************************************************************************'
echo 'Stopping Master'
echo '********************************************************************************'
echo

./master.jar stop

echo
echo '********************************************************************************'
echo 'Stopping IRIS JDBC Ingestion Worker'
echo '********************************************************************************'
echo

./iris-jdbc-ingest-worker.jar stop

echo
echo '********************************************************************************'
echo 'Stopping IRIS JDBC Query Worker'
echo '********************************************************************************'
echo

./iris-jdbc-query-worker.jar stop
