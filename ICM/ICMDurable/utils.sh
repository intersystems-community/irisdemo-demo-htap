#!/bin/sh

source /ICMDurable/base_env.sh

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

#
# Workaround for Prodlog 161538
#
prodlog161538() {
    # Always test first
    if [ ! -z "$(cat /ICM/etc/toHost/mountVolumes.sh | grep 1..26)" ];
    then 
        sed -i  "s/1..26/0..26/g" /ICM/etc/toHost/mountVolumes.sh
    fi
}

# provision.sh scripts instantiated from the template will call this every time they run
# in order to apply required workarounds for this stage. As ICM is started fresh every time 
# a new ICM container is started, we must always check and apply required workarounds
provisionWorkarounds() {
    prodlog161538
}

# deployiris.sh scripts instantiated from the template will call this every time they run
# in order to apply required workarounds for this stage. As ICM is started fresh every time 
# a new ICM container is started, we must always check and apply required workarounds
deployirisWorkarounds() {
    prodlog161538
}

# setup.sh scripts instantiated from the template will call this every time they run
# in order to apply required workarounds for this stage. As ICM is started fresh every time 
# a new ICM container is started, we must always check and apply required workarounds
setupWorkarounds() {
    echo
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

terraform_aws_open_ports() {
    if [ -z "$(cat /ICM/etc/Terraform/AWS/Instance/infrastructure.tf | grep "39013 \# SAP" )" ];
    then
        printf "\n\n${GREEN}Configuring Terraform for opening required TCP ports...\n\n${RESET}"
        
        # for HTAP Workers to be able to talk to master and vice versa
        ingress8080='ingress \{\n from_port=8080 \# HTAP \n to_port=8080 \n protocol=\"tcp\"\n cidr_blocks = \[var\.allow_cidr\]\n\}'

        # for SAP HANA
        ingress39013='ingress \{\n from_port=39013 \# HTAP \n to_port=39013 \n protocol=\"tcp\"\n cidr_blocks = \[var\.allow_cidr\]\n\}'

        # for AWS Aurora
        ingress3306='ingress \{\n from_port=3306 \# HTAP \n to_port=3306 \n protocol=\"tcp\"\n cidr_blocks = \[var\.allow_cidr\]\n\}'

        # for AWS SQL Server
        ingress1433='ingress \{\n from_port=1433 \# HTAP \n to_port=1433 \n protocol=\"tcp\"\n cidr_blocks = \[var\.allow_cidr\]\n\}'

        # for AWS PostgreSQL
        ingress5432='ingress \{\n from_port=5432 \# HTAP \n to_port=5432 \n protocol=\"tcp\"\n cidr_blocks = \[var\.allow_cidr\]\n\}'

        # /a is used for appending after the pattern
        sed -E -i  "/ *vpc_id *= *var.aws_vpc_default_id *$/a $ingress8080 \n $ingress39013 \n $ingress3306 \n $ingress1433 \n $ingress5432" /ICM/etc/Terraform/AWS/Instance/infrastructure.tf
         
    fi
}

# $1 must be machine name
# $2 must be container name
docker_rm() {
    if [ ! -z "$(icm ssh --machine $1 --command "docker ps" | grep $2)" ];
    then
        printf "\n\n${YELLOW}Removing container $2 at machine $1...\n\n${RESET}"
        icm ssh  \
            --machine $1 --command "docker rm -f $2"
    fi
}

# $1 must be machine name
# $2 must be image name
docker_pull() {
    printf "\n${YELLOW}Pulling image $2 on machine $1...\n${RESET}"
    icm ssh  \
        --machine $1 \
        --command "docker pull $2"
    exit_if_error "Could not pull image $2 at machine $1."
}

# $1 must be machine name
# Return on variable INTERNAL_IP
internal_ip() {
    MACHINE_GROUP=$(echo "$1" | egrep -o '[0-9a-zA-Z]+-[a-zA-Z]+-[a-zA-Z]+')

    # The following command will return something like ip-10-0-1-11
    icm ssh --machine $1 --command hostname
    # The following command will take ip-10-0-1-11, transform - into . and return from character 4 onward
    INTERNAL_IP=$(cat ./state/${MACHINE_GROUP}/$1/ssh.out | sed -e 's/-/./g' - | cut -b 4-)
}

# $1 must be machine name
# $2 must be container name
# $3 must be image name
# $4 must be docker options
docker_run() {
    printf "\n\n${YELLOW}Creating container $2 at machine $1...\n\n${RESET}"
    
    internal_ip $1

    icm ssh  \
        --machine $1 \
        --command "docker run -d --name $2 -e HOSTNAME=$INTERNAL_IP $4 $3"
    exit_if_error "Error when creating container $2 at machine $1 with image $3"
}

# $1 must be machine name
# $2 must be container name
remove_container() {
    printf "\n${YELLOW}Stopping and removing container $2 at machine $1...${RESET}\n"
        
    icm ssh  \
        --machine $1 \
        --command "docker stop $2;docker rm $2; exit 0"
}

remove_all_containers() {
    LABEL=${PWD##*/}
    INVENTORY=$(icm inventory | awk "/$LABEL-VM-/ {print \$1}")
    for MACHINE in $INVENTORY
    do
        printf "\n\n${PURPLE}Stopping and removing containers at machine $MACHINE...\n${RESET}"
        remove_container $MACHINE htapmaster
        remove_container $MACHINE htapui
        remove_container $MACHINE ingw
        remove_container $MACHINE qryW
    done

    echo 0 > ./.CNcount
}

find_iris_database_size() {
    
    export DATABASE_SIZE_IN_GB=`expr $(cat ./defaults.json | awk 'BEGIN { FS = "\"" } /"DataVolumeSize"/ { print $4 }') - 10`
}

deploy()
{
    IMAGE_PREFIX=$1
    MASTER_SPEEDTEST_TITLE=$2
    
    if [ "$IMAGE_PREFIX" = "iris" ];
    then
        IRIS_DM_MACHINE_NAME="${ICM_LABEL}-DM-IRISSpeedTest-0001"

        internal_ip $IRIS_DM_MACHINE_NAME
        IRIS_HOSTNAME=$INTERNAL_IP        

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

    find_iris_database_size

    CN_MACHINE_GROUP="${ICM_LABEL}-VM-IRISSpeedTest"

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

    # Master will be available on port 8080 which is not open on the firewal. But that is ok,
    # because the HTAP UI calls the master through a proxy that is configured to redirect the call
    # on the server, to port 8080. The containers can see each other behind the firewall!
    # That is also why we are adding to the HTAP UI's /etc/hosts file an entry that maps htapmaster hostname
    # to its real address (see icm run above).

    printf "\n\n${GREEN}Deploying HTAP Demo MASTER for ${MASTER_SPEEDTEST_TITLE}...\n\n${RESET}"
    docker_rm ${UI_MACHINE_NAME} htapmaster
    
    docker_pull ${UI_MACHINE_NAME} intersystemsdc/irisdemo-demo-htap:master-${HTAP_DEMO_VERSION}

    docker_run ${UI_MACHINE_NAME} htapmaster intersystemsdc/irisdemo-demo-htap:master-${HTAP_DEMO_VERSION} "-p 8080:8080 -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_SPEEDTEST_TITLE=\"${MASTER_SPEEDTEST_TITLE}\" -e DATABASE_SIZE_IN_GB=\"$DATABASE_SIZE_IN_GB\" -e INGESTION_JDBC_URL=\"${INGESTION_JDBC_URL}\" -e CONSUMER_JDBC_URL=\"${CONSUMER_JDBC_URL}\" -e INGESTION_JDBC_USERNAME=\"${JDBC_USERNAME}\" -e INGESTION_JDBC_PASSWORD=\"${JDBC_PASSWORD}\" -e CONSUMER_JDBC_USERNAME=\"${JDBC_USERNAME}\" -e CONSUMER_JDBC_PASSWORD=\"${JDBC_PASSWORD}\""

    internal_ip $MASTER_MACHINE_NAME
    HTAP_MASTER_IP=$INTERNAL_IP 

    if [ -z "$HTAP_MASTER_IP" ];
    then
        printf "\n\n${RED}Could not find IP address of HTAP Master.\n\n${RESET}"
        exit 1
    else
        printf "\n\n${GREEN}IP address of HTAP Master is ${HTAP_MASTER_IP}.\n\n${RESET}"
    fi

    printf "\n\n${YELLOW}Waiting htapmaster to be healthy."
    while [ -z "$(icm ssh --machine ${MASTER_MACHINE_NAME} --command "docker ps" | grep htapmaster | grep \(healthy\))" ];
    do
        sleep 1
        printf "."
    done
    
    # HTAP Demo UI will be available on port 80 that is already open on the firewall for us.
    printf "\n\n${GREEN}Deploying HTAP Demo UI for ${MASTER_SPEEDTEST_TITLE}...\n\n${RESET}"
    docker_rm ${UI_MACHINE_NAME} htapui
    
    docker_pull ${UI_MACHINE_NAME} intersystemsdc/irisdemo-demo-htap:ui-${HTAP_DEMO_VERSION}

    docker_run ${UI_MACHINE_NAME} htapui intersystemsdc/irisdemo-demo-htap:ui-${HTAP_DEMO_VERSION} "-p 80:4200 --add-host htapmaster:$HTAP_MASTER_IP"

    #
    # Configuring Ingestion Workers for IRIS
    #

    iIW=0
    while [ ! $iIW -eq $HTAP_INGESTION_WORKERS ]
    do
        iIW=`expr $iIW + 1`
        CNi=`expr $CNi + 1`

        INGESTION_WORKER_MACHINE=${ICM_LABEL}-VM-IRISSpeedTest-$(printf %04d $CNi)        

        printf "\n\n${GREEN}Deploying ${MASTER_SPEEDTEST_TITLE} Ingestion Worker #${iIW}...\n\n${RESET}"
        INGESTION_WORKER_MACHINE_DNS=$(icm inventory | awk "/$INGESTION_WORKER_MACHINE/{ print \$3 }")    

        docker_rm ${INGESTION_WORKER_MACHINE} ingw
        
        docker_pull ${INGESTION_WORKER_MACHINE} intersystemsdc/irisdemo-demo-htap:${IMAGE_PREFIX}-jdbc-ingest-worker-${HTAP_DEMO_VERSION}

        docker_run ${INGESTION_WORKER_MACHINE} ingw intersystemsdc/irisdemo-demo-htap:${IMAGE_PREFIX}-jdbc-ingest-worker-${HTAP_DEMO_VERSION} "-p 8080:8080 --add-host htapmaster:$HTAP_MASTER_IP -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=htapmaster -e MASTER_PORT=8080"
    done

    #
    # Configuring Query Workers for IRIS
    #

    iQW=0
    while [ ! $iQW -eq $HTAP_QUERY_WORKERS ]
    do
        iQW=`expr $iQW + 1`
        CNi=`expr $CNi + 1`

        QUERY_WORKER_MACHINE=${ICM_LABEL}-VM-IRISSpeedTest-$(printf %04d $CNi)

        printf "\n\n${GREEN}Deploying ${MASTER_SPEEDTEST_TITLE} Query Worker #${iQW}...\n\n${RESET}"
        QUERY_WORKER_MACHINE_DNS=$(icm inventory | awk "/$QUERY_WORKER_MACHINE/{ print \$3 }")    

        docker_rm ${QUERY_WORKER_MACHINE} qryW

        docker_pull ${QUERY_WORKER_MACHINE} intersystemsdc/irisdemo-demo-htap:${IMAGE_PREFIX}-jdbc-query-worker-${HTAP_DEMO_VERSION}

        docker_run ${QUERY_WORKER_MACHINE} qryW intersystemsdc/irisdemo-demo-htap:${IMAGE_PREFIX}-jdbc-query-worker-${HTAP_DEMO_VERSION} "-p 8080:8080 --add-host htapmaster:$HTAP_MASTER_IP -e JAVA_OPTS=-Xmx${JAVA_XMX} -e MASTER_HOSTNAME=htapmaster -e MASTER_PORT=8080"
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
    
    icm ssh  \
        --machine $2 \
        --command "docker restart $1"
    exit_if_error "Failed to restart container $2 at machine $1."
}

#
# $1 - Database's name
# $2 - Default username
read_endpoint_and_credentials() {

    printf "\nEnter with $1's end point:${RESET}\n"
    read DB_HOSTNAME
    exit_if_empty $DB_HOSTNAME

    if [ -z "$2" ];
    then
        printf "\nEnter with $1's username:${RESET}\n"
        read DB_JDBC_USERNAME
        exit_if_empty $DB_JDBC_USERNAME
    else
        printf "\nEnter with $1's username ($2):${RESET}\n"
        read DB_JDBC_USERNAME
        if [ -z "$DB_JDBC_USERNAME" ];
        then
            DB_JDBC_USERNAME=$2
        fi
    fi

    printf "\nEnter with $1's password:${RESET}\n"
    read -s DB_JDBC_PASSWORD
    exit_if_empty $DB_JDBC_PASSWORD

    export DB_HOSTNAME
    export DB_JDBC_USERNAME
    export DB_JDBC_PASSWORD
}

getVPC()
{
    export VPC_ID=$(cat ./state/$ICM_LABEL-IRISSpeedTest/terraform.tfstate | grep vpc_id | head -1 | awk -F\" '{print $4}')
}
