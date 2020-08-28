#!/bin/sh

source ./env.sh
source /ICMDurable/utils.sh

printf "${GREEN}Bouncing master and worker containers...${RESET}"

let iWORKERS_PER_MASTER="$HTAP_INGESTION_WORKERS + $HTAP_QUERY_WORKERS"

let iLAST_MASTER="$HTAP_MASTERS + ($HTAP_MASTERS * $iWORKERS_PER_MASTER) - $iWORKERS_PER_MASTER"

iMASTER=1

while [ ! $iMASTER -gt $iLAST_MASTER ]
do

    MASTER_MACHINE_NAME=${ICM_LABEL}-VM-IRISSpeedTest-$(printf %04d $iMASTER)

    bounce_container_at_machine htapmaster $MASTER_MACHINE_NAME

    let iINGESTION_WORKER="$iMASTER + 1"
    let iLAST_INGESTION_WORKER="$iMASTER + $HTAP_INGESTION_WORKERS"
    while [ ! $iINGESTION_WORKER -gt $iLAST_INGESTION_WORKER ]
    do
        WORKER_MACHINE_NAME=${ICM_LABEL}-VM-IRISSpeedTest-$(printf %04d $iINGESTION_WORKER)

        bounce_container_at_machine htapIngestionWorker $WORKER_MACHINE_NAME

        let iINGESTION_WORKER="$iINGESTION_WORKER + 1"
    done

    let iQUERY_WORKER=$iINGESTION_WORKER
    let iLAST_QUERY_WORKER="$iMASTER + $HTAP_INGESTION_WORKERS + $HTAP_QUERY_WORKERS"
    
    while [ ! $iQUERY_WORKER -gt $iLAST_QUERY_WORKER ]
    do
        WORKER_MACHINE_NAME=${ICM_LABEL}-VM-IRISSpeedTest-$(printf %04d $iQUERY_WORKER)

        bounce_container_at_machine htapQueryWorker $WORKER_MACHINE_NAME

        let iQUERY_WORKER="$iQUERY_WORKER + 1"
    done

    let iMASTER="$iMASTER + $iWORKERS_PER_MASTER + 1"
done