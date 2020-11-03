source ./envar.sh
source ../../utils.sh
#PROVISIONING STRUCTURE:


if [ "$LOCAL" == "true" ];
then
    #use eks to create cluster on AWS (this automatically makes kubectl point at this new cluster) we need to read AWS creds from somewhere
    printf "\n\n${GREEN}Initializing cluster on EKS..${RESET}"
    eksctl create cluster -f ./cluster-config.yaml
    exit_if_error "Failure to create cluster on EKS"
fi




#kubectl apply each one of the deployment yamls

if [ "$COMMUNITY" == "false" ];
then 

    #use helm install to install IKO on cluster (for now we depend on the user to have the file from which to install)
    printf "\n\n${GREEN}Installing IKO on the cluster using Helm...${RESET}"
    helm uninstall intersystems
    helm install intersystems ../../IKO/iris_operator*/chart/iris-operator
    exit_if_error "Helm IKO installation failed"

    printf "\n\n${GREEN}Creating iris-key-secret on the cluster...${RESET}"
    kubectl delete secret/iris-key-secret
    kubectl create secret generic iris-key-secret --from-file=../../license/iris.key
    exit_if_error "Secret creation failed. Make sure your iris license key is inside Kubernetes/license"

    kubectl apply -f ./storage-class.yaml
    exit_if_error "Could not deploy storage class"
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
sleep 2
kubectl apply -f ./iris-deployment.yaml
exit_if_error "Could not deploy iris"


