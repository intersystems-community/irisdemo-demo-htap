#!/bin/sh

source /ICMDurable/utils.sh

printf "\n\n${RED}WARNING: If you continue, this script will regenerate all your SSH/TLS keys and reset your defaults.json and definition.json files."
printf "\n\n${RESET}Do you want to continue? Type yes if you do: "
read answer

if [ "$answer" != 'yes' ];
then
    printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
    exit 0
fi

rm -f /ICMDurable/env.sh
rm -f ./defaults.json
rm -f ./definitions.json
source ./clean.sh

#
# Setting up SSH and TLS
# 

export SSH_DIR=/ICMDurable/keys
export TLS_DIR=/ICMDurable/keys
echo "export SSH_DIR=${SSH_DIR}" >> /ICMDurable/env.sh
echo "export TLS_DIR=${TLS_DIR}" >> /ICMDurable/env.sh

rm -rf ${SSH_DIR}
rm -rf ${TLS_DIR}

printf "\n\n${GREEN}Generating SSH keys on $SSH_DIR:\n${RESET}"
/ICM/bin/keygenSSH.sh $SSH_DIR

printf "\n\n${GREEN}Generating TLS keys on $TLS_DIR:\n${RESET}"
/ICM/bin/keygenTLS.sh $TLS_DIR

#
# LABEL
#

printf "\n\n${GREEN}Please enter with the label for your ICM machines (ex: asamary): ${RESET}"
read ICM_LABEL
exit_if_empty $ICM_LABEL

echo "export ICM_LABEL=$ICM_LABEL" >> /ICMDurable/env.sh
echo "export IRIS_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local" >> /ICMDurable/env.sh
echo "export IRIS_ECP_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local" >> /ICMDurable/env.sh

#
# Configuring Container Types
#

printf "\n\n${GREEN}If you are testing IRIS gainst another database, you may want more than one master."
printf "\n${GREEN}How many Masters?: ${RESET}"
read HTAP_MASTERS
exit_if_empty $HTAP_MASTERS

# echo "export HTAP_MASTERS=$HTAP_MASTERS" >> /ICMDurable/env.sh

# # CN = Container Type - The first container will be 1
# CNi=0

# i=0
# while [ ! $i -eq $HTAP_MASTERS ]
# do
#     i=`expr $i + 1`
#     CNi=`expr $CNi + 1`
#     echo "export MASTER_${i}_HOSTNAME=htapmaster-${ICM_LABEL}-CN-IRISSpeedTest-$(printf %04d $CNi).weave.local" >> /ICMDurable/env.sh
#     echo "export MASTER_${i}_PORT=8080" >> /ICMDurable/env.sh
# done

printf "\n\n${GREEN}How many Ingestion Workers per Master?: ${RESET}"
read HTAP_INGESTION_WORKERS
exit_if_empty $HTAP_INGESTION_WORKERS

echo "export HTAP_INGESTION_WORKERS=$HTAP_INGESTION_WORKERS" >> /ICMDurable/env.sh

printf "\n\n${GREEN}How many Query Workers per Master?: ${RESET}"
read HTAP_QUERY_WORKERS
exit_if_empty $HTAP_QUERY_WORKERS

echo "export HTAP_QUERY_WORKERS=$HTAP_QUERY_WORKERS" >> /ICMDurable/env.sh

MAX_CN=`expr $HTAP_MASTERS + ($HTAP_MASTERS*$HTAP_INGESTION_WORKERS) + ($HTAP_MASTERS*$HTAP_QUERY_WORKERS)`
echo "export MAX_CN=$MAX_CN" >> /ICMDurable/env.sh

rm -f ./.CNcount
echo 0 >> .CNcount

#
# Recreating definitions.json and defaults.json files
#

cp ./template-defaults.json ./defaults.json
cp ./template-definitions.json ./definitions.json
sed -E -i '' "s;<Label>;$ICM_LABEL;g" ./defaults.json

printf "\n\n${GREEN}Docker Hub username?: ${RESET}"
read DOCKER_USERNAME
exit_if_empty $DOCKER_USERNAME

printf "\n\n${GREEN}Docker Hub password?: ${RESET}"
read DOCKER_PASSWORD
exit_if_empty $DOCKER_PASSWORD

sed -E -i '' "s;<DockerUsername>;$DOCKER_USERNAME;g" ./defaults.json
sed -E -i '' "s;<DockerPassword>;$DOCKER_PASSWORD;g" ./defaults.json

//TODO:

#
# Reminding user of the requirement for AWS credential files
#
if [ ! -f ./credentials.ADFS-PowerUsers ];
then
    printf "\n\n${YELLOW}Put your AWS credentials on file credentials.ADFS-PowerUsers${RESET}\n\n"

    echo "[default]" >> ./credentials.ADFS-PowerUsers
    echo "aws_access_key_id = <your aws access key>" >> ./credentials.ADFS-PowerUsers
    echo "aws_secret_access_key = <your aws secret access key>" >> ./credentials.ADFS-PowerUsers
    echo "aws_session_token = <your aws session token>" >> ./credentials.ADFS-PowerUsers
fi

