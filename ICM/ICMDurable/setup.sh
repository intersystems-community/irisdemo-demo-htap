#!/bin/sh

source /ICMDurable/utils.sh
source /ICMDurable/base_env.sh

setupWorkarounds

export SSH_DIR=/ICMDurable/keys
export TLS_DIR=/ICMDurable/keys

if [ ! -d ./keys ];
then
    printf "\n\n${GREEN}Generating SSH keys on $SSH_DIR:\n${RESET}"
    /ICM/bin/keygenSSH.sh $SSH_DIR

    printf "\n\n${GREEN}Generating TLS keys on $TLS_DIR:\n${RESET}"
    /ICM/bin/keygenTLS.sh $TLS_DIR
fi

#
# Setting up LABEL for our machines
#

printf "\n\n${GREEN}Please enter with the label for your ICM machines (ex: asamaryTest1): ${RESET}"
read ICM_LABEL
exit_if_empty $ICM_LABEL

if [ ! -d /ICMDurable/Deployments ];
then
    mkdir /ICMDurable/Deployments
fi

DEPLOYMENT_FOLDER=/ICMDurable/Deployments/$ICM_LABEL

rm -rf $DEPLOYMENT_FOLDER
mkdir $DEPLOYMENT_FOLDER

echo "export DEPLOYMENT_FOLDER=${DEPLOYMENT_FOLDER}" >> $DEPLOYMENT_FOLDER/env.sh
echo "export SSH_DIR=${SSH_DIR}" >> $DEPLOYMENT_FOLDER/env.sh
echo "export TLS_DIR=${TLS_DIR}" >> $DEPLOYMENT_FOLDER/env.sh
echo "export ICM_LABEL=$ICM_LABEL" >> $DEPLOYMENT_FOLDER/env.sh
echo "export IRIS_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local" >> $DEPLOYMENT_FOLDER/env.sh
echo "export IRIS_ECP_HOSTNAME=iris-${ICM_LABEL}-DM-IRISSpeedTest-0001.weave.local" >> $DEPLOYMENT_FOLDER/env.sh

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

printf "\n\n${GREEN}Do you want ECP (answer yes or something else if not)?: ${RESET}"
read irisWithECPAnswer
exit_if_empty $irisWithECPAnswer

if [ "$irisWithECPAnswer" == "yes" ];
then
    ECP="true"
    printf "\n\n${GREEN}How many compute nodes do you need?: ${RESET}"
    read ecpCount
    exit_if_empty $ecpCount
else
    ECP="false"
fi

#
# Configuring additional machines with enough non-IRIS containers for the number
# of HTAP UI/Master and Workers we need
#

printf "\n${GREEN}How many Speed Test Masters do you want?: ${RESET}"
read HTAP_MASTERS
exit_if_empty $HTAP_MASTERS

echo "export HTAP_MASTERS=$HTAP_MASTERS" >> $DEPLOYMENT_FOLDER/env.sh

printf "\n\n${GREEN}How many Ingestion Workers per Master?: ${RESET}"
read HTAP_INGESTION_WORKERS
exit_if_empty $HTAP_INGESTION_WORKERS

echo "export HTAP_INGESTION_WORKERS=$HTAP_INGESTION_WORKERS" >> $DEPLOYMENT_FOLDER/env.sh

printf "\n\n${GREEN}How many Query Workers per Master?: ${RESET}"
read HTAP_QUERY_WORKERS
exit_if_empty $HTAP_QUERY_WORKERS

echo "export HTAP_QUERY_WORKERS=$HTAP_QUERY_WORKERS" >> $DEPLOYMENT_FOLDER/env.sh

# Doing basic math in shell script sucks... But I have learned that "let" is better and will come back to change this
tmpW=`expr $HTAP_MASTERS \* $HTAP_INGESTION_WORKERS`
tmpQ=`expr $HTAP_MASTERS \* $HTAP_QUERY_WORKERS`
tmpW=`expr $tmpW + $tmpQ`
MAX_CN=`expr $HTAP_MASTERS + $tmpW`

echo "export MAX_CN=$MAX_CN" >> $DEPLOYMENT_FOLDER/env.sh

# .CNcount will start with zero. The script deployspeedtest.sh will increment it 
# as new images are deployed so we can deploy, say, 3 images for the IRIS Speed Test (one
# for the UI/Master, one for the ingestion worker and another for the query worker) and then
# provision additional 3 images for the SAP HANA Speed Test. They will all be given consecutive
# numbers (0001, 0002, 0003, 0004, etc...)
rm -f $DEPLOYMENT_FOLDER/.CNcount
echo 0 >> $DEPLOYMENT_FOLDER/.CNcount

#
# Recreating defaults.json file based on template chosen by user
#

printf "\n\n${GREEN}Please enter with the AWS instance type: ${RESET}"

instanceList=$(ls /ICMDurable/Templates/AWS)
instanceTypeNumber=0
IFS='
'
for instanceDesc in $instanceList;
do 
    instanceTypeNumber=$(($instanceTypeNumber+1))
    printf "\n\t${YELLOW} ${instanceTypeNumber} ${RESET}- $instanceDesc\n"
done

printf "\nChoice: "
read chosenInstanceTypeNumber

INSTANCE_TYPE=""
instanceTypeNumber=0
for instanceDesc in $instanceList;
do 
    instanceTypeNumber=$(($instanceTypeNumber + 1))
    if [ $instanceTypeNumber -eq $chosenInstanceTypeNumber ];
    then
        printf " ${GREEN}${instanceDesc}...${RESET}\n\n"
        INSTANCE_TYPE=${instanceDesc}
        break
    fi
done

#
# Is this a container based deployment of IRIS or is it containerless?
#

CONTAINERLESS=false
#
# Forcing container-less installation of IRIS. 
#
printf "\n\n${GREEN}Is this going to be a containerless installation of IRIS (answer yes or something else if not)?: ${RESET}"
read containerLessInstall
exit_if_empty $containerLessInstall

# containerLessInstall="yes"

if [ "$containerLessInstall" == "yes" ];
then
    CONTAINERLESS=true
    
    IRIS_KIT=$(ls /ICMDurable/IRISKit/*.tar.gz) 
    if [ ! -z "$IRIS_KIT" ];
    then
        # for usage on deployiris.sh
        echo "export IRIS_KIT_LOCAL_PATH=$IRIS_KIT" >> $DEPLOYMENT_FOLDER/env.sh

        IRIS_KIT=$(echo $IRIS_KIT | cut -c21-) # removing ./IRISKit from the beggining

        # for usage on deployiris.sh
        echo "export IRIS_KIT_REMOTE_PATH=/tmp/$IRIS_KIT" >> $DEPLOYMENT_FOLDER/env.sh

        # for usage on definitions.json file
        IRIS_KIT=file://tmp/$IRIS_KIT
        echo "export IRIS_KIT=$IRIS_KIT" >> $DEPLOYMENT_FOLDER/env.sh

        printf "\n\n${YELLOW}ICM configured to provision $INSTANCE_TYPE machines on AWS.\n\n"
    else
        printf "\n\n${RED}You are missing the IRIS Kit in the IRISKit folder. We can't proceed with a containerless installation without it.${RESET}\n\n"
        exit 1
    fi
else
    printf "\n\n${YELLOW}Please enter with your docker credentials so we can pull the IRIS image from your private docker hub repository.${RESET}\n"
    printf "\n\n${GREEN}Docker Hub username?: ${RESET}"
    read DOCKER_USERNAME
    exit_if_empty $DOCKER_USERNAME

    printf "\n\n${GREEN}Docker Hub password?: ${RESET}"
    read -s DOCKER_PASSWORD
    exit_if_empty $DOCKER_PASSWORD

    echo "export DOCKER_USERNAME=$DOCKER_USERNAME" >> $DEPLOYMENT_FOLDER/env.sh
    echo "export DOCKER_PASSWORD=$DOCKER_PASSWORD" >> $DEPLOYMENT_FOLDER/env.sh
fi

echo "export CONTAINERLESS=$CONTAINERLESS" >> $DEPLOYMENT_FOLDER/env.sh

#
# Making changes to the template accordingly to user choices
#

cp ./Templates/AWS/$INSTANCE_TYPE/defaults.json $DEPLOYMENT_FOLDER/
cp ./Templates/AWS/$INSTANCE_TYPE/merge.cpf $DEPLOYMENT_FOLDER/

sed -E -i  "s;<Label>;$ICM_LABEL;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<Mirror>;$MIRROR;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<Zone>;$ZONE;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<Containerless>;$CONTAINERLESS;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<DockerUsername>;$DOCKER_USERNAME;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<DockerPassword>;$DOCKER_PASSWORD;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<IRISDockerImage>;$IRIS_DOCKER_IMAGE;g" $DEPLOYMENT_FOLDER/defaults.json
sed -E -i  "s;<UserCPF>;$DEPLOYMENT_FOLDER/merge.cpf;g" $DEPLOYMENT_FOLDER/defaults.json

if [ "$CONTAINERLESS" == "true" ];
then
    sed -E -i  "s;<KitURL>;$IRIS_KIT;g" $DEPLOYMENT_FOLDER/defaults.json
fi

globalBuffers8kMb=$(cat $DEPLOYMENT_FOLDER/merge.cpf | awk -F, '/^globals=/{ print $3 }')
routineBuffersMb=$(cat $DEPLOYMENT_FOLDER/merge.cpf | awk -F= '/^routines=/{ print $2 }')
buffersMb=$(($globalBuffers8kMb + $routineBuffersMb))
NR_HUGE_PAGES=$(($buffersMb + $buffersMb / 5)) # Adding 5% 
echo "export NR_HUGE_PAGES=$NR_HUGE_PAGES" >> $DEPLOYMENT_FOLDER/env.sh

#
# Creating definitions.json file
#
    echo "
    [
        {
        \"Role\": \"DM\",
        \"Count\": \"${DM_COUNT}\",
        \"LicenseKey\": \"iris.key\",
        \"KitURL\": \"file://tmp/IRIS-2020.1.0.215.0-lnxubuntux64.tar.gz\"
        } ">> $DEPLOYMENT_FOLDER/definitions.json

if [ $MAX_CN -gt 0 ];
then
    echo ",
        {
            \"Role\": \"VM\",
            \"Count\": \"${MAX_CN}\",
            \"DataVolumeType\": \"io1\",
            \"DataVolumeSize\": \"30\",
            \"DataVolumeIOPS\": \"100\",
            \"InstanceType\": \"c5.xlarge\"
        }" >> $DEPLOYMENT_FOLDER/definitions.json
fi
if [ "$ECP" == "true" ];
then
    echo "export ECP=$ECP" >> $DEPLOYMENT_FOLDER/env.sh
    echo ",
        {
            \"Role\": \"AM\",
            \"LicenseKey\": \"iris.key\",
            \"Count\": \"${ecpCount}\",
            \"LoadBalancer\": \"true\",
            \"KitURL\": \"file://tmp/IRIS-2020.1.0.215.0-lnxubuntux64.tar.gz\"
        }" >> $DEPLOYMENT_FOLDER/definitions.json
fi
echo "]" >> $DEPLOYMENT_FOLDER/definitions.json

rm -f $DEPLOYMENT_FOLDER/defaults.json.bak

#
# Copying additional scripts and making them executable
#
cp ./Templates/template_provision.sh $DEPLOYMENT_FOLDER/provision.sh
chmod +x $DEPLOYMENT_FOLDER/provision.sh

cp ./Templates/template_deployspeedtest.sh $DEPLOYMENT_FOLDER/deployspeedtest.sh
chmod +x $DEPLOYMENT_FOLDER/deployspeedtest.sh

cp ./Templates/template_deployiris.sh $DEPLOYMENT_FOLDER/deployiris.sh
chmod +x $DEPLOYMENT_FOLDER/deployiris.sh

cp ./Templates/template_bouncespeedtest.sh $DEPLOYMENT_FOLDER/bouncespeedtest.sh
chmod +x $DEPLOYMENT_FOLDER/bouncespeedtest.sh

cp ./Templates/template_uninstall_iris.sh $DEPLOYMENT_FOLDER/uninstall_iris.sh
chmod +x $DEPLOYMENT_FOLDER/uninstall_iris.sh

cp ./Templates/template_unprovision.sh $DEPLOYMENT_FOLDER/unprovision.sh
chmod +x $DEPLOYMENT_FOLDER/unprovision.sh

cp ./Templates/template_removespeedtest.sh $DEPLOYMENT_FOLDER/removespeedtest.sh
chmod +x $DEPLOYMENT_FOLDER/removespeedtest.sh

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

printf "\n\n${YELLOW}You can now change to $DEPLOYMENT_FOLDER and run ./provision.sh to provision the infrastructure on AWS.\n\n${RESET}"