#!/bin/sh

source /ICMDurable/utils.sh
source /ICMDurable/base_env.sh

printf "\n\n${RED}WARNING: If you continue, this script will regenerate all your SSH/TLS keys and reset your defaults.json and definition.json files."
printf "\n\n${RESET}Do you want to continue? Type yes if you do: "
read answer

if [ "$answer" != 'yes' ];
then
    printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
    exit 0
fi

rm -f ./.provisionHasBeenRun
rm -f /ICMDurable/env.sh
rm -f ./*.json

rm -f ./.provisionHasBeenRun
rm -rf /ICMDurable/State
mkdir /ICMDurable/State
rm -f /ICMDurable/*.log
rm -rf /ICMDurable/.terraform

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
# Setting up LABEL for our machines
#

printf "\n\n${GREEN}Please enter with the label for your ICM machines (ex: asamary): ${RESET}"
read ICM_LABEL
exit_if_empty $ICM_LABEL

echo "export ICM_LABEL=$ICM_LABEL" >> /ICMDurable/env.sh
echo "export IRIS_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local" >> /ICMDurable/env.sh
echo "export IRIS_ECP_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local" >> /ICMDurable/env.sh

printf "\n\n${GREEN}Do you want IRIS with Mirroring (answer yes or something else if not)?: ${RESET}"
read irisWithMirroringAnswer
exit_if_empty $irisWithMirroringAnswer

if [ "$irisWithMirroringAnswer" == "yes" ];
then
    DM_COUNT=2
    ZONE="us-east-1a,us-east-1b"
    MIRROR="true"
else
    DM_COUNT=1
    ZONE="us-east-1a"
    MIRROR="false"
fi

#
# Configuring additional machines with enough non-IRIS containers for the number
# of HTAP UI/Master and Workers we need
#

printf "\n\n${GREEN}If you are testing IRIS gainst another database, you may want more than one master."
printf "\n${GREEN}How many Masters?: ${RESET}"
read HTAP_MASTERS
exit_if_empty $HTAP_MASTERS

echo "export HTAP_MASTERS=$HTAP_MASTERS" >> /ICMDurable/env.sh

printf "\n\n${GREEN}How many Ingestion Workers per Master?: ${RESET}"
read HTAP_INGESTION_WORKERS
exit_if_empty $HTAP_INGESTION_WORKERS

echo "export HTAP_INGESTION_WORKERS=$HTAP_INGESTION_WORKERS" >> /ICMDurable/env.sh

printf "\n\n${GREEN}How many Query Workers per Master?: ${RESET}"
read HTAP_QUERY_WORKERS
exit_if_empty $HTAP_QUERY_WORKERS

echo "export HTAP_QUERY_WORKERS=$HTAP_QUERY_WORKERS" >> /ICMDurable/env.sh

# Doing basic math in shell script sucks...
tmpW=`expr $HTAP_MASTERS \* $HTAP_INGESTION_WORKERS`
tmpQ=`expr $HTAP_MASTERS \* $HTAP_QUERY_WORKERS`
tmpW=`expr $tmpW + $tmpQ`
MAX_CN=`expr $HTAP_MASTERS + $tmpW`

echo "export MAX_CN=$MAX_CN" >> /ICMDurable/env.sh

# .CNcount will start with zero. The script deployspeedtest.sh will increment it 
# as new images are deployed so we can deploy, say, 3 images for the IRIS Speed Test (one
# for the UI/Master, one for the ingestion worker and another for the query worker) and then
# provision additional 3 images for the SAP HANA Speed Test. They will all be given consecutive
# numbers (0001, 0002, 0003, 0004, etc...)
rm -f ./.CNcount
echo 0 >> .CNcount

#
# Recreating defaults.json file based on template chosen by user
#

printf "\n\n${GREEN}Please enter with the AWS instance type: ${RESET}"
printf "\n\n\t ${YELLOW}1${RESET} - m4.2xlarge"
printf "\n\t ${YELLOW}2${RESET} - m5.xlarge"
printf "\n\n"

read instanceTypeNumber
case $instanceTypeNumber in
    1)
        printf " ${GREEN}m4.2xlarge...${RESET}\n\n"
        INSTANCE_TYPE=m4.2xlarge
        break
        ;;
    2)
        printf " ${GREEN}m5.xlarge...${RESET}\n\n"
        INSTANCE_TYPE=m5.xlarge
        break
        ;;
    *)
        printf "\n\n${PURPLE}Invalid option. Exiting.${RESET}\n\n"
        exit 0
        ;;
esac

#
# Is this a container based deployment of IRIS or is it containerless?
#

# We don't support the HTAP demo with containerless IRIS. ICM will not
# allow us to deploy our HTAP application containers with a containerless IRIS on
# the same ICM deployment. :((
containerBased=yes
CONTAINERLESS=false
# printf "\n\n${GREEN}Is this going to be a container based installation of IRIS (answer yes or something else if not)?: ${RESET}"
# read containerBased
# exit_if_empty $containerBased

printf "\n\n${YELLOW}Please enter with your docker credentials so we can pull the images.${RESET}\n"
printf "\n\n${GREEN}Docker Hub username?: ${RESET}"
read DOCKER_USERNAME
exit_if_empty $DOCKER_USERNAME

printf "\n\n${GREEN}Docker Hub password?: ${RESET}"
read -s DOCKER_PASSWORD
exit_if_empty $DOCKER_PASSWORD

IRIS_KIT=$(ls ./IRISKit/*.tar.gz) 
if [ ! -z "$IRIS_KIT" ];
then
    # for usage on deployiris.sh
    echo "export IRIS_KIT_LOCAL_PATH=$IRIS_KIT" >> /ICMDurable/env.sh

    IRIS_KIT=$(echo $IRIS_KIT | cut -c11-) # removing ./IRISKit from the beggining

    # for usage on deployiris.sh
    echo "export IRIS_KIT_REMOTE_PATH=/tmp/$IRIS_KIT" >> /ICMDurable/env.sh

    # for usage on definitions.json file
    IRIS_KIT=file://tmp/$IRIS_KIT
    echo "export IRIS_KIT=$IRIS_KIT" >> /ICMDurable/env.sh

    printf "\n\n${YELLOW}ICM configured to provision $INSTANCE_TYPE machines on AWS.\n\n"
fi

echo "export CONTAINERLESS=$CONTAINERLESS" >> /ICMDurable/env.sh

#
# Making changes to the template accordingly to user choices
#

cp ./Templates/AWS/$INSTANCE_TYPE/defaults.json .
cp ./Templates/AWS/$INSTANCE_TYPE/merge.cpf .

sed -E -i  "s;<Label>;$ICM_LABEL;g" ./defaults.json
sed -E -i  "s;<Mirror>;$MIRROR;g" ./defaults.json
sed -E -i  "s;<Zone>;$ZONE;g" ./defaults.json
sed -E -i  "s;<Containerless>;$CONTAINERLESS;g" ./defaults.json
sed -E -i  "s;<DockerUsername>;$DOCKER_USERNAME;g" ./defaults.json
sed -E -i  "s;<DockerPassword>;$DOCKER_PASSWORD;g" ./defaults.json
sed -E -i  "s;<IRISDockerImage>;$IRIS_DOCKER_IMAGE;g" ./defaults.json

globalBuffers8kMb=$(cat ./merge.cpf | awk -F, '/^globals=/{ print $3 }')
routineBuffersMb=$(cat ./merge.cpf | awk -F= '/^routines=/{ print $2 }')
buffersMb=$(($globalBuffers8kMb + $routineBuffersMb))
NR_HUGE_PAGES=$(($buffersMb + $buffersMb / 5)) # Adding 5% 
echo "export NR_HUGE_PAGES=$NR_HUGE_PAGES" >> /ICMDurable/env.sh

#
# Creating definitions.json file
#
    echo "
    [
        {
        \"Role\": \"DM\",
        \"Count\": \"${DM_COUNT}\",
        \"LicenseKey\": \"iris.key\"" >> ./definitions.json

if [ "$CONTAINERLESS" == "true" ];
then
    echo ",
        \"KitURL\": \"$IRIS_KIT\"" >> ./definitions.json
fi

echo "    }" >> ./definitions.json

if [ $MAX_CN -gt 0 ];
then
    echo ",
        {
            \"Role\": \"CN\",
            \"Count\": \"${MAX_CN}\",
            \"DataVolumeType\": \"io1\",
            \"DataVolumeSize\": \"30\",
            \"DataVolumeIOPS\": \"100\",
            \"InstanceType\": \"c5.xlarge\"
        }" >> ./definitions.json
fi
echo "]" >> ./definitions.json

rm -f ./defaults.json.bak

#
# Reminding user of the requirement for AWS credential files
#
if [ ! -f ./aws.credentials ];
then
    printf "\n\n${YELLOW}Put your AWS credentials on file aws.credentials${RESET}\n\n"

    echo "[default]" >> ./aws.credentials
    echo "aws_access_key_id = <your aws access key>" >> ./aws.credentials
    echo "aws_secret_access_key = <your aws secret access key>" >> ./aws.credentials
    echo "aws_session_token = <your aws session token>" >> ./aws.credentials
fi

printf "\n\n${YELLOW}You can run ./provision.sh to provision the infrastructure on AWS now.\n\n${RESET}"