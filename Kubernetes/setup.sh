source ./utils.sh

#
#Setting up LABEL for our cluster
#

printf "\n\n${GREEN}Please enter with the label for your Kubernetes cluster (ex: asamaryCluster1): ${RESET}"
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
#Will you be deploying locally or AWS? (no license key needed)
#
printf "\n\n${GREEN}Are you going to deploy the demo locally (answer yes or something else if not)?: ${RESET}"
read irisLocalAnswer
exit_if_empty $irisLocalAnswer

#
#Will you be using IRIS community? (no license key needed)
#
if [ "$irisLocalAnswer" != "yes" ];
then
    LOCAL=false
    printf "\n\n${GREEN}Are you using IRIS Community (answer yes or something else if not)?: ${RESET}"
    read irisCommunityAnswer
    exit_if_empty $irisCommunityAnswer
else
    LOCAL=true
fi

if [ "$irisCommunityAnswer" == "yes" ] || [ "$irisLocalAnswer" == "yes" ];
then
    #DON'T NEED TO ASK ABOUT MIRRORING
    #DON'T NEED TO ASK ABOUT SHARDING
    #ASK ABOUT MACHINE TYPE TEMPLATE (USE THIS INFORMATION TO POPULATE template-cluster-config.yaml AND template-storage-class.yaml)
    COMMUNITY=true
    MIRROR=false
    SHARDING=false
    SHARDS=1
    INSTANCES=1
    NAMESPACE=USER

else
    COMMUNITY=false
    NAMESPACE=IRISCLUSTER

    printf "\n\n${GREEN}Enter your Docker Username: ${RESET}"
    read DOCKER_USER
    exit_if_empty $DOCKER_USER

    printf "\n\n${GREEN}Enter your Docker Password: ${RESET}"
    read -s DOCKER_PASSWORD
    exit_if_empty $DOCKER_PASSWORD
    

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

echo "export HTAP_INGESTION_WORKERS=$HTAP_INGESTION_WORKERS" >> $DEPLOYMENT_FOLDER/envar.sh

printf "\n\n${GREEN}How many Query Workers?: ${RESET}"
read HTAP_QUERY_WORKERS
exit_if_empty $HTAP_QUERY_WORKERS

echo "export HTAP_QUERY_WORKERS=$HTAP_QUERY_WORKERS" >> $DEPLOYMENT_FOLDER/envar.sh




if [ "$irisLocalAnswer" != "yes" ];
then 
    #
    #
    #Choosing template to initialize envar.sh from where default values will be loaded (for the 
    #instance type of the machines, storage, etc)
    #
    #


    printf "\n\n${GREEN}Please enter with the AWS instance type: ${RESET}"
    instanceList=$(ls ./Templates/AWS/instances)
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


    cp ./Templates/AWS/instances/$INSTANCE_TYPE/envar.sh $DEPLOYMENT_FOLDER/envar.sh
    source $DEPLOYMENT_FOLDER/envar.sh

    cp ./Templates/AWS/instances/$INSTANCE_TYPE/data.cpf $DEPLOYMENT_FOLDER/data.cpf
fi



echo "LOCAL=$LOCAL" >> $DEPLOYMENT_FOLDER/envar.sh
echo "CLUSTER_LABEL=$CLUSTER_LABEL" >> $DEPLOYMENT_FOLDER/envar.sh
echo "COMMUNITY=$COMMUNITY" >> $DEPLOYMENT_FOLDER/envar.sh
echo "MIRROR=$MIRROR" >> $DEPLOYMENT_FOLDER/envar.sh
echo "SHARDING=$SHARDING" >> $DEPLOYMENT_FOLDER/envar.sh
echo "SHARDS=$SHARDS" >> $DEPLOYMENT_FOLDER/envar.sh
echo "INSTANCES=$INSTANCES" >> $DEPLOYMENT_FOLDER/envar.sh
echo "DOCKER_USER=$DOCKER_USER" >> $DEPLOYMENT_FOLDER/envar.sh
echo "DOCKER_PASSWORD=$DOCKER_PASSWORD" >> $DEPLOYMENT_FOLDER/envar.sh



cp ./Templates/AWS/template-cluster-config.yaml $DEPLOYMENT_FOLDER/cluster-config.yaml
cp ./Templates/AWS/template-storage-class.yaml $DEPLOYMENT_FOLDER/storage-class.yaml
cp ./Templates/AWS/template-service-ui.yaml $DEPLOYMENT_FOLDER/service-ui.yaml

cp ./Templates/common/deployment-master.yaml $DEPLOYMENT_FOLDER/deployment-master.yaml
cp ./Templates/common/deployment-ui.yaml $DEPLOYMENT_FOLDER/deployment-ui.yaml
cp ./Templates/common/deployment-workers.yaml $DEPLOYMENT_FOLDER/deployment-workers.yaml

cp ./Templates/AWS/template-provision.sh $DEPLOYMENT_FOLDER/provision.sh
chmod +x $DEPLOYMENT_FOLDER/provision.sh
cp ./Templates/AWS/template-unprovision.sh $DEPLOYMENT_FOLDER/unprovision.sh
chmod +x $DEPLOYMENT_FOLDER/unprovision.sh


if [ "$COMMUNITY" == "true" ];
then
    cp ./Templates/template-community-deployment.yaml $DEPLOYMENT_FOLDER/iris-deployment.yaml
else
    cp ./Templates/template-iris-deployment.yaml $DEPLOYMENT_FOLDER/iris-deployment.yaml
fi




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
sed -E -i '' "s;<WIJ_STORAGE_SIZE>;$WIJ_STORAGE_SIZE;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml
sed -E -i '' "s;<J1_STORAGE_SIZE>;$J1_STORAGE_SIZE;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml
sed -E -i '' "s;<J2_STORAGE_SIZE>;$J2_STORAGE_SIZE;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml
sed -E -i '' "s;<MIRROR>;$MIRROR;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml
sed -E -i '' "s;<CPUS>;$CPUS;g" $DEPLOYMENT_FOLDER/iris-deployment.yaml


sed -E -i '' "s;<NAMESPACE>;$NAMESPACE;g" $DEPLOYMENT_FOLDER/deployment-master.yaml

sed -E -i '' "s;<IOPS_PER_GB_NORMAL>;$IOPS_PER_GB_NORMAL;g" $DEPLOYMENT_FOLDER/storage-class.yaml
sed -E -i '' "s;<IOPS_PER_GB_SLOW>;$IOPS_PER_GB_SLOW;g" $DEPLOYMENT_FOLDER/storage-class.yaml
sed -E -i '' "s;<IOPS_PER_GB_FAST>;$IOPS_PER_GB_FAST;g" $DEPLOYMENT_FOLDER/storage-class.yaml

if [ "$LOCAL" != false ];
then
    sed -E -i '' '/nodeSelector/d' $DEPLOYMENT_FOLDER/deployment-workers.yaml
    sed -E -i '' '/node-label/d' $DEPLOYMENT_FOLDER/deployment-workers.yaml

    sed -E -i '' '/nodeSelector/d' $DEPLOYMENT_FOLDER/deployment-master.yaml
    sed -E -i '' '/node-label/d' $DEPLOYMENT_FOLDER/deployment-master.yaml

    sed -E -i '' '/nodeSelector/d' $DEPLOYMENT_FOLDER/deployment-ui.yaml
    sed -E -i '' '/node-label/d' $DEPLOYMENT_FOLDER/deployment-ui.yaml
    

fi

printf "\n\n${YELLOW}You can now change to $DEPLOYMENT_FOLDER and run ./provision.sh to provision the infrastructure on Kubernetes.\n\n${RESET}"