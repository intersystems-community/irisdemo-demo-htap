source ./envar.sh
source ../../utils.sh

if [ "$LOCAL" != "true" ] && [ "$1" != "-nc" ];
then
    #use eks to create cluster on AWS (this automatically makes kubectl point at this new cluster) we need to read AWS creds from somewhere
    printf "\n\n${GREEN}Initializing cluster on EKS..${RESET}"
    eksctl create cluster -f ./cluster-config.yaml
    exit_if_error "Failure to create cluster on EKS"
fi

#kubectl apply each one of the deployment yamls

if [ "$COMMUNITY" == "false" ];
then 

    printf "\n\n${GREEN}Installing IKO on the cluster using Helm...${RESET}"
    printf "\n${GREEN}Configuring docker hub secret...\n${RESET}"
    kubectl delete secret dockerhub-secret
    kubectl create secret docker-registry dockerhub-secret --docker-username=$DOCKER_USER --docker-password=$DOCKER_PASSWORD


    #use helm install to install IKO on cluster (for now we depend on the user to have the file from which to install)
    
    printf "\n${GREEN}Removing previous version of IKO...\n${RESET}"
    helm uninstall intersystems

    printf "\n${GREEN}Installing IKO on the cluster using Helm...\n${RESET}"
    IKO_FOLDER=$(ls -d ../../IKO/iris_operator-*/)
    IKO_TAG=$(cut -d "-" -f2 <<< $IKO_FOLDER)
    IKO_TAG=iko-$(cut -d "/" -f1 <<< $IKO_TAG)
    helm install intersystems ${IKO_FOLDER}chart/iris-operator --set operator.registry=angellopezque,operator.repository=iko,operator.tag=$IKO_TAG
    exit_if_error "Helm IKO installation failed"

    printf "\n${GREEN}Creating iris-key-secret on the cluster...\n${RESET}"
    kubectl delete secret/iris-key-secret
    kubectl create secret generic iris-key-secret --from-file=../../license/iris.key
    exit_if_error "Secret creation failed. Make sure your iris license key is inside Kubernetes/license"

    kubectl apply -f ./storage-class.yaml
    exit_if_error "Could not deploy storage class"

    kubectl delete cm/iris-cpf
    kubectl create cm iris-cpf --from-file data.cpf 
    exit_if_error "could not create cpf file"
fi

printf "\n\n${GREEN}Deploying pods on the nodes...${RESET}"

kubectl apply -f ./deployment-master.yaml
exit_if_error "Could not deploy master"
kubectl apply -f ./deployment-ui.yaml
exit_if_error "Could not deploy the ui"
kubectl apply -f ./deployment-workers.yaml
exit_if_error "Could not deploy workers"
kubectl apply -f ./service-ui.yaml
exit_if_error "Could not deploy service UI"
sleep 12
kubectl apply -f ./iris-deployment.yaml
exit_if_error "Could not deploy iris"

# kubectl port-forward svc/ui 4200:4200&
