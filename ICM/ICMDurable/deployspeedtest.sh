#!/bin/sh

source /ICMDurable/env.sh
source /ICMDurable/iris_env.sh
source /ICMDurable/utils.sh

export JAVA_XMX=2048Mb

deploy_for_iris()
{
    #
    # The first version of this script assumes that when testing IRIS, we will be testing only against 
    # the data master (DM). So, let's set up IRIS_HOSTNAME and IRIS_ECP_HOSTNAME to point to the first
    # IRIS data master
    #

    IRIS_HOSTNAME="iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local"
    IRIS_ECP_HOSTNAME=$IRIS_HOSTNAME

    #
    # We need to count how many containers of type CN we are using. We need to do this
    # counting on a "persistent variable". So we are keeping that on a file named
    # .CNcount. So it will be available in between runs of this script. That will allow us to
    # call this script once to, say, deploy the HTAP Demo for IRIS on the first set of CN
    # machines. Then call it again to deploy a second HTAP Demo for, say, AWS Aurora. The 
    # count would just keep going up as we start by reading the current count from file .CNcount.
    #

    CNi=$(cat .CNcount)

    #
    # UI and Master must be running on the same host machine
    #
    CNi=`expr $CNi + 1`
    UI_MACHINE_NAME=${ICM_LABEL}-CN-IRISSpeedTest-$(printf %04d $CNi)

    MASTER_MACHINE_NAME=${ICM_LABEL}-CN-IRISSpeedTest-$(printf %04d $CNi)
    MASTER_HOSTNAME=htapmaster-${MASTER_MACHINE_NAME}.weave.local

    # HTAP Demo UI will be available on port 80 that is already open on the firewall for us.
    printf "\n\n${YELLOW}Deploying HTAP Demo UI for IRIS...\n\n${RESET}"
    icm run -stateDir /ICMDurable/State \
        --machine ${UI_MACHINE_NAME} \
        --container htapui \
        --image intersystemsdc/irisdemo-demo-htap:ui-${HTAP_DEMO_VERSION} \
        --options "-p 80:4200 --add-host htapmaster:${MASTER_HOSTNAME}"
    
    exit_if_error "Deploying HTAP Demo UI for IRIS failed."

    # Master will be available on port 8080 which is not open on the firewal. But that is ok,
    # because the HTAP UI calls the master through a proxy that is configured to redirect the call
    # on the server, to port 8080. The containers can see each other behind the firewall!
    # That is also why we are adding to the HTAP UI's /etc/hosts file an entry that maps htapmaster hostname
    # to its real address (see icm run above).

    printf "\n\n${YELLOW}Deploying HTAP Demo MASTER for IRIS...\n\n${RESET}"
    icm run -stateDir /ICMDurable/State \
        --machine ${MASTER_MACHINE_NAME} \
        --container htapmaster \
        --image intersystemsdc/irisdemo-demo-htap:master-${HTAP_DEMO_VERSION} \
        --options "-p 8080:8080 -e JAVA_OPTS=-Xmx${JAVA_XMX}"

    exit_if_error "Deploying HTAP Demo Master for IRIS failed."
    #
    # Configuring Ingestion Workers for IRIS
    #

    iIW=0
    while [ ! $iIW -eq $HTAP_INGESTION_WORKERS ]
    do
        iIW=`expr $iIW + 1`
        CNi=`expr $CNi + 1`

        UI_INGESTION_WORKER_MACHINE=${ICM_LABEL}-CN-IRISSpeedTest-$(printf %04d $CNi)

        printf "\n\n${YELLOW}Deploying IRIS Ingestion Worker #${iIW}...\n\n${RESET}"
        icm run -stateDir /ICMDurable/State \
            --machine ${UI_INGESTION_WORKER_MACHINE} \
            --container htapIngestionWorker \
            --image intersystemsdc/irisdemo-demo-htap:iris-jdbc-ingest-worker-${HTAP_DEMO_VERSION} \
            --options "-p 80:8080 -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=${MASTER_HOSTNAME} -e MASTER_PORT=${MASTER_PORT}"
        
        exit_if_error "Deploying IRIS Ingestion Worker failed."
    done

    #
    # Configuring Query Workers for IRIS
    #

    iQW=0
    while [ ! $iQW -eq $HTAP_QUERY_WORKERS ]
    do
        iQW=`expr $iQW + 1`
        CNi=`expr $CNi + 1`

        UI_QUERY_WORKER_MACHINE=${ICM_LABEL}-CN-IRISSpeedTest-$(printf %04d $CNi)

        printf "\n\n${YELLOW}Deploying IRIS Query Worker #${iQW}...\n\n${RESET}"
        icm run -stateDir /ICMDurable/State \
            --machine ${UI_QUERY_WORKER_MACHINE} \
            --container htapIngestionWorker \
            --image intersystemsdc/irisdemo-demo-htap:iris-jdbc-query-worker-${HTAP_DEMO_VERSION} \
            --options "-p 80:8080 -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=${MASTER_HOSTNAME} -e MASTER_PORT=${MASTER_PORT}"

        exit_if_error "Deploying IRIS Query Worker failed."
    done

}

printf "\n\n${GREEN}Please, specify which speedtest you want to deploy. Available options are:"
printf "\n\n\t iris - InterSystems IRIS"
printf "\n\n\t mysql - MySQL/AWSAurora"
printf "\n\n\t hana - SAP HANA"
printf "\n${RESET}"

read SPEED_TEST_TO_DEPLOY
case $SPEED_TEST_TO_DEPLOY in
    iris)
        printf "\n\n${GREEN}Deploying HTAP demo for InterSystems IRIS...${RESET}\n\n"
        deploy_for_iris;
        ;;
    hana)
        ;;
    mysql)
        ;;
    *)
        printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
        exit 0
        ;;
esac

printf "\n\n${GREEN}Done!${RESET}\n\n"

