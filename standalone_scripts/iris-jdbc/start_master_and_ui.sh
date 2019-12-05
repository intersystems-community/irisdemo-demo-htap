#!/bin/bash
#
# Use this script to START the Master service and the Angular UI for the Speed Test.
#
# You can either use this script directly by clonning this repository on the server where 
# the master and the UI will be running or use it as a basis to build your own script.
#
# The environment variables bellow will allow you to configure the speed test.
# All the workers will get these configurations from the MASTER, so make sure you are 
# configuring the JDBC URLs to point to the correct IRIS endpoints and ports.
#

export DISABLE_JOURNAL_FOR_DROP_TABLE=false
export DISABLE_JOURNAL_FOR_TRUNCATE=false
export INGESTION_THREADS_PER_WORKER=1
export INGESTION_BATCH_SIZE=1000
export INGESTION_JDBC_URL=jdbc:IRIS://localhost:51773/USER
export INGESTION_JDBC_USERNAME=SuperUser
export INGESTION_JDBC_PASSWORD=sys
export CONSUMER_JDBC_URL=jdbc:IRIS://localhost:51773/USER
export CONSUMER_JDBC_USERNAME=SuperUser
export CONSUMER_JDBC_PASSWORD=sys
export CONSUMER_THREADS_PER_WORKER=1
export CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS=0

# Spring boot mode. Service means it will run on the background
export MODE="service"
export PID_FOLDER=$PWD/pids
export LOG_FOLDER=$PWD/logs
export LOG_FILENAME=master.log

#COLOR CONSTANTS
PURPLE='\033[0;35m'
NOCOLOR='\033[0m'

# Configure function cleanup() to be executed on CTRL+C
trap cleanup INT
function cleanup()
{
    # Restore normal CTRL+C behaviour
    trap - INT

    # Do the cleanup
    printf "${PURPLE}\n"
    echo '********************************************************************************'
    echo 'Stopping Master'
    echo '********************************************************************************'
    printf "${NOCOLOR}\n"

    ../../image-master/projects/master.jar stop
}

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting Master'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

../../image-master/projects/master.jar start --server.port=8080
echo 'Waiting 5 seconds for master to finish starting...'
sleep 5

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting the UI! It may take a while. When done, you should be able to open it'
echo "at http://$(hostname):4200"
echo " "
echo "When you are done with the speed test, you can CTRL+C here so we will stop the "
echo "master service and the Angular UI service for you."
echo '********************************************************************************'
printf "${NOCOLOR}\n"

(cd ../../image-ui && npm run standalone)


