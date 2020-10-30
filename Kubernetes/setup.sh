source ./utils.sh

#
#Setting up LABEL for our cluster
#

printf "\n\n${GREEN}Please enter with the label for your EKS machines (ex: asamaryCluster1): ${RESET}"
read CLUSTER_LABEL
exit_if_empty $CLUSTER_LABEL

if [ ! -d ./Deployments ];
then
    mkdir ./Deployments
fi

DEPLOYMENT_FOLDER=Deployments/$CLUSTER_LABEL

#
#Delete existing folder of the same name if it exists.
#
rm -rf $DEPLOYMENT_FOLDER
mkdir $DEPLOYMENT_FOLDER


#
#Will you be using IRIS community? (no license key needed)
#
printf "\n\n${GREEN}Are you using IRIS Community (answer yes or something else if not)?: ${RESET}"
read irisCommunityAnswer
exit_if_empty $irisCommunityAnswer

if [ "$irisCommunityAnswer" == "yes" ];
then
    #DON'T NEED TO ASK ABOUT MIRRORING
    #DON'T NEED TO ASK ABOUT SHARDING
    #ASK ABOUT MACHINE TYPE TEMPLATE (USE THIS INFORMATION TO POPULATE template-cluster-config.yaml AND template-storage-class.yaml)
    COMMUNITY=true
    MIRROR=false
    SHARDING=false
    SHARDS=1
    INSTANCES=1

else
    COMMUNITY=false

    printf "\n\n${GREEN}Do you want IRIS with Mirroring (answer yes or something else if not)?: ${RESET}"
    read irisWithMirroringAnswer
    exit_if_empty $irisWithMirroringAnswer

    if [ "$irisWithMirroringAnswer" == "yes" ];
    then
        MIRROR=true
        mirrors=2
    else
        MIRROR=false
        mirrors=1
    fi

    printf "\n\n${GREEN}Do you want IRIS with Sharding (answer yes or something else if not)?: ${RESET}"
    read irisWithShardingAnswer
    if [ "$irisWithShardingAnswer" == "yes" ];
    then
        SHARDING=true
        printf "\n\n${GREEN}How many shards do you want?: ${RESET}"
        read SHARDS
        exit_if_empty $SHARDS
        INSTANCES=$((SHARDS*mirrors))
    else
        SHARDING=false
        SHARDS=1
        INSTANCES=$mirrors
    fi

fi


printf "\n\n${GREEN}How many Ingestion Workers?: ${RESET}"
read HTAP_INGESTION_WORKERS
exit_if_empty $HTAP_INGESTION_WORKERS

echo "export HTAP_INGESTION_WORKERS=$HTAP_INGESTION_WORKERS" >> $DEPLOYMENT_FOLDER/env.sh

printf "\n\n${GREEN}How many Query Workers?: ${RESET}"
read HTAP_QUERY_WORKERS
exit_if_empty $HTAP_QUERY_WORKERS

echo "export HTAP_QUERY_WORKERS=$HTAP_QUERY_WORKERS" >> $DEPLOYMENT_FOLDER/env.sh



#
#
#Choosing template to initialize env.sh from where default values will be loaded (for the 
#instance type of the machines, storage, etc)
#
#


printf "\n\n${GREEN}Please enter with the AWS instance type: ${RESET}"

instanceList=$(ls ./Templates/AWS)
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


cp ./Templates/AWS/$INSTANCE_TYPE/env.sh $DEPLOYMENT_FOLDER/env.sh
source $DEPLOYMENT_FOLDER/env.sh





echo "CLUSTER_LABEL=$CLUSTER_LABEL" >> $DEPLOYMENT_FOLDER/env.sh
echo "COMMUNITY=$COMMUNITY" >> $DEPLOYMENT_FOLDER/env.sh
echo "MIRROR=$MIRROR" >> $DEPLOYMENT_FOLDER/env.sh
echo "SHARDING=$SHARDING" >> $DEPLOYMENT_FOLDER/env.sh
echo "SHARDS=$SHARDS" >> $DEPLOYMENT_FOLDER/env.sh
echo "INSTANCES=$INSTANCES" >> $DEPLOYMENT_FOLDER/env.sh


cp ./Templates/template-cluster-config.yaml $DEPLOYMENT_FOLDER/cluster-config.yaml
chmod +x $DEPLOYMENT_FOLDER/cluster-config.yaml

cp ./Templates/template-storage-class.yaml $DEPLOYMENT_FOLDER/storage-class.yaml
chmod +x $DEPLOYMENT_FOLDER/storage-class.yaml

cp ./Templates/template-provision.sh $DEPLOYMENT_FOLDER/provision.sh
chmod +x $DEPLOYMENT_FOLDER/provision.sh

cp ./Templates/template-unprovision.sh $DEPLOYMENT_FOLDER/unprovision.sh
chmod +x $DEPLOYMENT_FOLDER/unprovision.sh


if [ "$COMMUNITY" == "true" ];
then
    cp ./Templates/template-community-deployment.yaml $DEPLOYMENT_FOLDER/iris-deployment.yaml
else
    cp ./Templates/template-iris-deployment.yaml $DEPLOYMENT_FOLDER/iris-deployment.yaml
fi

chmod +x $DEPLOYMENT_FOLDER/iris-deployment.yaml



#
# Filling values in the yaml files in the deployment folder
#

sed -E -i '' "s;<CLUSTER_LABEL>;$CLUSTER_LABEL;g" $DEPLOYMENT_FOLDER/cluster-config.yaml
sed -E -i '' "s;<IRIS_INSTANCE_TYPE>;$IRIS_INSTANCE_TYPE;g" $DEPLOYMENT_FOLDER/cluster-config.yaml
sed -E -i '' "s;<INSTANCES>;$INSTANCES;g" $DEPLOYMENT_FOLDER/cluster-config.yaml
sed -E -i '' "s;<HTAP_INGESTION_WORKERS>;$HTAP_INGESTION_WORKERS;g" $DEPLOYMENT_FOLDER/cluster-config.yaml
sed -E -i '' "s;<HTAP_QUERY_WORKERS>;$HTAP_QUERY_WORKERS;g" $DEPLOYMENT_FOLDER/cluster-config.yaml

sed -E -i '' "s;<SHARDS>;$SHARDS;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml
sed -E -i '' "s;<STORAGE_SIZE>;$STORAGE_SIZE;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml
sed -E -i '' "s;<MIRROR>;$MIRROR;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml


sed -E -i '' "s;<IOPS_PER_GB>;$IOPS_PER_GB;g" $DEPLOYMENT_FOLDER/storage-class.yaml



printf "\n\n${YELLOW}You can now change to $DEPLOYMENT_FOLDER and run ./provision.sh to provision the infrastructure on EKS.\n\n${RESET}"