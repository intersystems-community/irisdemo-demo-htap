#!/bin/sh

RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

exit_if_error() {

	if [ $? -ne 0 ];
	then
		printf "\n\n${RED}"
		echo "ERROR: $1"
		printf "\n\n${RESET}"
		exit 1
	fi
}

exit_if_terraform_error() {

	if [ $? -ne 0 ];
	then
		printf "\n\n${RED}"
		echo "ERROR: $1"
		printf "\n${YELLOW}"
		cat */*/terraform.err

		printf "\n\n${RESET}"
		exit 1
	fi
}

exit_if_empty() {
    if [ -z "$1" ];
    then
        printf "\n\n${PURPLE}Exiting.${RESET}"
        exit 0
    fi
}

deploy()
{
    IMAGE_PREFIX=$1
    MASTER_SPEEDTEST_TITLE=$2
    
    if [ "$IMAGE_PREFIX" = "iris" ];
    then
        IRIS_DM_MACHINE_NAME="${ICM_LABEL}-DM-IRISSpeedTest-0001"
        if [ $CONTAINERLESS == "true" ];
        then
            IRIS_HOSTNAME=$(icm inventory | awk "/$IRIS_DM_MACHINE_NAME/{ print \$3 }")
        else
            IRIS_HOSTNAME="iris-${IRIS_DM_MACHINE_NAME}.weave.local"
        fi

        INGESTION_JDBC_URL=jdbc:IRIS://${IRIS_HOSTNAME}:${IRIS_PORT}/SPEEDTEST

        # I do not support ECP just yet. Walking into that direction...
        CONSUMER_JDBC_URL=jdbc:IRIS://${IRIS_HOSTNAME}:${IRIS_ECP_PORT}/SPEEDTEST

        JDBC_USERNAME=SuperUser
        JDBC_PASSWORD=sys

    else
        INGESTION_JDBC_URL=$3
        CONSUMER_JDBC_URL=$4
        JDBC_USERNAME=$5
        JDBC_PASSWORD=$6
    fi

    CN_MACHINE_GROUP=${ICM_LABEL}-CN-IRISSpeedTest

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
    
    UI_MACHINE_NAME=${CN_MACHINE_GROUP}-$(printf %04d $CNi)
    MASTER_MACHINE_NAME=${CN_MACHINE_GROUP}-$(printf %04d $CNi)
    MASTER_HOSTNAME=htapmaster-${MASTER_MACHINE_NAME}.weave.local

    # Master will be available on port 8080 which is not open on the firewal. But that is ok,
    # because the HTAP UI calls the master through a proxy that is configured to redirect the call
    # on the server, to port 8080. The containers can see each other behind the firewall!
    # That is also why we are adding to the HTAP UI's /etc/hosts file an entry that maps htapmaster hostname
    # to its real address (see icm run above).

    printf "\n\n${YELLOW}Deploying HTAP Demo MASTER for ${MASTER_SPEEDTEST_TITLE}...\n\n${RESET}"
    icm run -stateDir /ICMDurable/State \
        --machine ${MASTER_MACHINE_NAME} \
        --container htapmaster \
        --image intersystemsdc/irisdemo-demo-htap:master-${HTAP_DEMO_VERSION} \
        --options "-e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_SPEEDTEST_TITLE=\"${MASTER_SPEEDTEST_TITLE}\" -e INGESTION_JDBC_URL=${INGESTION_JDBC_URL} -e CONSUMER_JDBC_URL=${CONSUMER_JDBC_URL} -e INGESTION_JDBC_USERNAME=${JDBC_USERNAME} -e INGESTION_JDBC_PASSWORD=${JDBC_PASSWORD} -e CONSUMER_JDBC_USERNAME=${JDBC_USERNAME} -e CONSUMER_JDBC_PASSWORD=${JDBC_PASSWORD}"

    exit_if_error "Deploying HTAP Demo Master for ${MASTER_SPEEDTEST_TITLE} failed."

    icm exec --container htapmaster --machine ${MASTER_MACHINE_NAME} --command "cat /etc/hosts | grep htapmaster"
    HTAP_MASTER_IP=$(cat ./State/${CN_MACHINE_GROUP}/${MASTER_MACHINE_NAME}/docker.out | awk '{print $1}')

    if [ -z "$HTAP_MASTER_IP" ];
    then
        printf "\n\n${RED}Could not find IP address of HTAP Master.\n\n${RESET}"
        exit 1
    else
        printf "\n\n${GREEN}IP address of HTAP Master is ${HTAP_MASTER_IP}.\n\n${RESET}"
    fi

    printf "\n\n${YELLOW}Waiting htapmaster to be healthy."
    while [ ! "$(icm  ps --machine ${MASTER_MACHINE_NAME} | grep htapmaster | awk '{print $5}')" == "healthy" ];
    do
        sleep 1
        printf "."
    done

    # HTAP Demo UI will be available on port 80 that is already open on the firewall for us.
    printf "\n\n${YELLOW}Deploying HTAP Demo UI for ${MASTER_SPEEDTEST_TITLE}...\n\n${RESET}"
    icm run -stateDir /ICMDurable/State \
        --machine ${UI_MACHINE_NAME} \
        --container htapui \
        --image intersystemsdc/irisdemo-demo-htap:ui-${HTAP_DEMO_VERSION} \
        --options "-p 80:4200 --add-host htapmaster:$HTAP_MASTER_IP"
    
    exit_if_error "Deploying HTAP Demo UI for ${MASTER_SPEEDTEST_TITLE} failed."

    #
    # Configuring Ingestion Workers for IRIS
    #

    iIW=0
    while [ ! $iIW -eq $HTAP_INGESTION_WORKERS ]
    do
        iIW=`expr $iIW + 1`
        CNi=`expr $CNi + 1`

        UI_INGESTION_WORKER_MACHINE=${ICM_LABEL}-CN-IRISSpeedTest-$(printf %04d $CNi)

        printf "\n\n${YELLOW}Deploying ${MASTER_SPEEDTEST_TITLE} Ingestion Worker #${iIW}...\n\n${RESET}"
        icm run -stateDir /ICMDurable/State \
            --machine ${UI_INGESTION_WORKER_MACHINE} \
            --container htapIngestionWorker \
            --image intersystemsdc/irisdemo-demo-htap:${IMAGE_PREFIX}-jdbc-ingest-worker-${HTAP_DEMO_VERSION} \
            --options "-p 80:8080 --add-host htapmaster:$HTAP_MASTER_IP -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=htapmaster -e MASTER_PORT=8080"
        
        exit_if_error "Deploying ${MASTER_SPEEDTEST_TITLE} Ingestion Worker failed."
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

        printf "\n\n${YELLOW}Deploying ${MASTER_SPEEDTEST_TITLE} Query Worker #${iQW}...\n\n${RESET}"
        icm run -stateDir /ICMDurable/State \
            --machine ${UI_QUERY_WORKER_MACHINE} \
            --container htapQueryWorker \
            --image intersystemsdc/irisdemo-demo-htap:${IMAGE_PREFIX}-jdbc-query-worker-${HTAP_DEMO_VERSION} \
            --options "-p 80:8080 --add-host htapmaster:$HTAP_MASTER_IP -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=htapmaster -e MASTER_PORT=8080"

        exit_if_error "Deploying ${MASTER_SPEEDTEST_TITLE} Query Worker failed."
    done

    rm -f ./.CNcount
    echo $CNi >> ./.CNcount

    printf "\n\n${GREEN}URL to ${MASTER_SPEEDTEST_TITLE} Speed Test is at:${RESET}"
    UI_MACHINE_IP=$(icm inventory | grep ${UI_MACHINE_NAME} | awk '/.*/{ print $2 }')
    printf "\n\n\thttp://${UI_MACHINE_IP}"
}   


# $1 is the machine name
# $2 is the container name
bounce_container_at_machine() {

    printf "\n${YELLOW}Bouncing container $1 at $2...\n${RESET}"
    
    icm stop -stateDir /ICMDurable/State \
        --machine $2 \
        --container $1
    exit_if_error "Failed to stop container $2 at machine $1."

    icm start -stateDir /ICMDurable/State \
        --machine $2 \
        --container $1
    exit_if_error "Failed to start container $2 at machine $1."

}