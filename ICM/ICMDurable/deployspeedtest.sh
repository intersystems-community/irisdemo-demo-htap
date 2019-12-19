#!/bin/sh

source /ICMDurable/env.sh
source /ICMDurable/base_env.sh
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

    printf "\n\n${YELLOW}Deploying HTAP Demo MASTER for IRIS...\n\n${RESET}"
    icm run -stateDir /ICMDurable/State \
        --machine ${MASTER_MACHINE_NAME} \
        --container htapmaster \
        --image intersystemsdc/irisdemo-demo-htap:master-${HTAP_DEMO_VERSION} \
        --options "-e JAVA_OPTS=-Xmx${JAVA_XMX} -e INGESTION_JDBC_URL=jdbc:IRIS://${IRIS_HOSTNAME}:51773/SPEEDTEST -e CONSUMER_JDBC_URL=jdbc:IRIS://${IRIS_ECP_HOSTNAME}:51773/SPEEDTEST "

    exit_if_error "Deploying HTAP Demo Master for IRIS failed."

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
    while [ ! "$(icm  ps --machine asamary-CN-IRISSpeedTest-0001 | grep htapmaster | awk '{print $5}')" == "healthy" ];
    do
        sleep 1
        printf "."
    done

    # HTAP Demo UI will be available on port 80 that is already open on the firewall for us.
    printf "\n\n${YELLOW}Deploying HTAP Demo UI for IRIS...\n\n${RESET}"
    icm run -stateDir /ICMDurable/State \
        --machine ${UI_MACHINE_NAME} \
        --container htapui \
        --image intersystemsdc/irisdemo-demo-htap:ui-${HTAP_DEMO_VERSION} \
        --options "-p 80:4200 --add-host htapmaster:$HTAP_MASTER_IP"
    
    exit_if_error "Deploying HTAP Demo UI for IRIS failed."

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
            --options "-p 80:8080 --add-host htapmaster:$HTAP_MASTER_IP -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=htapmaster -e MASTER_PORT=8080"
        
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
            --container htapQueryWorker \
            --image intersystemsdc/irisdemo-demo-htap:iris-jdbc-query-worker-${HTAP_DEMO_VERSION} \
            --options "-p 80:8080 --add-host htapmaster:$HTAP_MASTER_IP -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=htapmaster -e MASTER_PORT=8080"

        exit_if_error "Deploying IRIS Query Worker failed."
    done

    rm -f ./.CNcount
    echo $CNi >> ./.CNcount

    printf "\n\n${GREEN}URL to IRIS Speed Test is at:${RESET}"
    UI_MACHINE_IP=$(icm inventory | grep ${UI_MACHINE_NAME} | awk '/.*/{ print $2 }')
    printf "\n\n\thttp://${UI_MACHINE_IP}"

    
}   

if [ ! -f ./.provisionHasBeenRun ];
then
    printf "\n\n${RED}You have not provisioned the infrastructure yet. Run 1) setup.sh, 2) provision.sh and 4) deployiris.sh before running this script.\n\n${RESET}"
    exit 1
fi

printf "\n\n${GREEN}Please, specify which speedtest you want to deploy. Available options are:"
printf "\n\n\t ${YELLOW}iris${RESET}  - InterSystems IRIS"
printf "\n\n\t ${YELLOW}mysql${RESET} - MySQL/AWSAurora (not implemented)"
printf "\n\n\t ${YELLOW}hana${RESET}  - SAP HANA (not implemented)"
printf "\n\n${RESET}"

read SPEED_TEST_TO_DEPLOY
case $SPEED_TEST_TO_DEPLOY in
    iris)
        printf "\n\n${GREEN}Deploying HTAP demo for InterSystems IRIS...${RESET}\n\n"
        deploy_for_iris
        break
        ;;
    hana)
        break
        ;;
    mysql)
        break
        ;;
    *)
        printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
        exit 0
        ;;
esac

printf "\n\n${GREEN}Done!${RESET}\n\n"



