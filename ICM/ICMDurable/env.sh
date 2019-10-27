#!/bin/sh

export SSH_DIR=/ICMDurable/keys
export TLS_DIR=/ICMDurable/keys

export ICM_LABEL=asamary

export MASTER_HOSTNAME=htapmaster-${ICM_LABEL}-CN-IRISSpeedTest-0002.weave.local
export MASTER_PORT=8080

export IRIS_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local
export IRIS_PORT=51773

export IRIS_ECP_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local
export IRIS_ECP_PORT=51773

export INGESTION_THREADS_PER_WORKER=30
export INGESTION_BATCH_SIZE=10000

export CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS=0
export CONSUMER_PROGRESSION=10
