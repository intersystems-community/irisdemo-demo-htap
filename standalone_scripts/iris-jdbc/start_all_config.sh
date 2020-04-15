#!/bin/bash

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

# This is the name of the server where the master is. This is used by the workers only
# export MASTER_HOSTNAME=$(hostname)
export MASTER_HOSTNAME=localhost
export MASTER_PORT=8080

# This is used so that the workers can report the correct hostname for this server to the master so that
# the master can reach it
# export HOSTNAME=$(hostname)
export HOSTNAME=localhost

# Spring boot mode. Service means it will run on the background
export MODE="service"
export PID_FOLDER=$PWD/pids
export LOG_FOLDER=$PWD/logs

# COLOR CONSTANTS
PURPLE='\033[0;35m'
NOCOLOR='\033[0m'
