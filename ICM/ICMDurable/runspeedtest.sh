#!/bin/sh
source /ICMDurable/env.sh

# UI
icm run -stateDir /ICMDurable/State \
    --machine ${ICM_LABEL}-CN-IRISSpeedTest-0001 \
    --container htapui \
    --image intersystemsdc/irisdemo-demo-htap:ui-version-1.0 \
    --options "-p 80:4200"

# Master
icm run -stateDir /ICMDurable/State \
    --machine ${ICM_LABEL}-CN-IRISSpeedTest-0002 \
    --container htapmaster \
    --image intersystemsdc/irisdemo-demo-htap:master-version-1.0 \
    --options "-p 80:8080 -e INGESTION_THREADS_PER_WORKER=${INGESTION_THREADS_PER_WORKER} -e INGESTION_BATCH_SIZE=${INGESTION_BATCH_SIZE} -e INGESTION_JDBC_URL=jdbc:IRIS://${IRIS_HOSTNAME}:${IRIS_PORT}/SPEEDTEST -e INGESTION_JDBC_USERNAME=SuperUser -e INGESTION_JDBC_PASSWORD=sys -e CONSUMER_JDBC_URL=jdbc:IRIS://${IRIS_ECP_HOSTNAME}:${IRIS_ECP_PORT}/SPEEDTEST -e CONSUMER_JDBC_USERNAME=SuperUser -e CONSUMER_JDBC_PASSWORD=sys -e CONSUMER_PROGRESSION=${CONSUMER_PROGRESSION} -e CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS=${CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS}"

# Worker 1
icm run -stateDir /ICMDurable/State \
    --machine asamary-CN-IRISSpeedTest-0003 \
    --container htapworker1 \
    --image intersystemsdc/irisdemo-demo-htap:iris-jdbc-ingest-worker-version-1.0 \
    --options "-e MASTER_HOSTNAME=${MASTER_HOSTNAME} -e MASTER_PORT=${MASTER_PORT}"

# Worker 2
icm run -stateDir /ICMDurable/State \
    --machine asamary-CN-IRISSpeedTest-0004 \
    --container htapworker2 \
    --image intersystemsdc/irisdemo-demo-htap:iris-jdbc-ingest-worker-version-1.0 \
    --options "-e MASTER_HOSTNAME=${MASTER_HOSTNAME} -e MASTER_PORT=${MASTER_PORT}"


 
