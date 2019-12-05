#!/bin/bash
#
# Use this script to START an Ingestion Worker service
#
# You can either use this script directly by clonning this repository on the server where 
# the worker will be running or use it as a basis to build your own script.
#
# The environment variables bellow will allow the worker to find its master and connect to it.
# Once connected, the worker will get all the configuration information it needs to do its job.
#

export MASTER_HOSTNAME=localhost
export MASTER_PORT=8080
export WORKER_PORT=8081

# This is used so that the worker can report the correct hostname for this server to the master so that
# the master can reach it
export HOSTNAME=$(hostname)

# Spring boot mode. Service means it will run on the background
export MODE="service"
export PID_FOLDER=$PWD/pids
export LOG_FOLDER=$PWD/logs
export LOG_FILENAME=ingestion_worker.log

# COLOR CONSTANTS
PURPLE='\033[0;35m'
NOCOLOR='\033[0m'

printf "${PURPLE}\n"
echo '********************************************************************************'
echo "Starting Ingestion Worker as a service at server ${HOSTNAME}"
echo '********************************************************************************'
printf "${NOCOLOR}\n"

../../image-ingest-worker/projects/iris-jdbc-ingest-worker.jar start --server.port=$WORKER_PORT

printf "${PURPLE}\n"
echo '********************************************************************************'
echo "Service started! Look at ${LOG_FOLDER}/${LOG_FILENAME} for messages."
echo '********************************************************************************'
printf "${NOCOLOR}\n"
