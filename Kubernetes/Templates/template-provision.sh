source ./env.sh
source /Kubernetes/utils.sh
#PROVISIONING STRUCTURE:
#use eks to create cluster on AWS (this automatically makes kubectl point at this new cluster) we need to read AWS creds from somewhere


printf "\n\n${GREEN}Initializing cluster on EKS..${RESET}"
eksctl create cluster -f ./cluster-config.yaml
exit_if_error "Failure to create cluster on EKS"

#use helm install to install IKO on cluster (for now we depend on the user to have the file from which to install)

printf "\n\n${GREEN}Installing IKO on the cluster using Helm...${RESET}"
helm install intersystems ../../IKO/iris_operator*/chart/iris-iris_operator
exit_if_error "Helm IKO installation failed"



#kubectl apply each one of the deployment yamls

if [ "$COMMUNITY" == "false" ];
then 
    printf "\n\n${GREEN}Creating iris-key-secret on the cluster...${RESET}"
    kubectl delete secret/iris-key-secret
    kubectl create secret generic iris-key-secret --from-file=../../license/iris.key
    exit_if_error "Secret creation failed. Make sure your iris license key is inside Kubernetes/license"
fi

printf "\n\n${GREEN}Deploying pods on the nodes...${RESET}"

kubectl apply -f ../../common/deployment-master.yml
exit_if_error "Could not deploy master"
kubectl apply -f ../../common/deployment-ui.yml
exit_if_error "Could not deploy the ui"
kubectl apply -f ../../common/deployment-workers.yml
exit_if_error "Could not deploy workers"
kubectl apply -f ./storage-class.yaml
exit_if_error "Could not deploy storage class"
kubectl apply -f ./iris-deployment.yaml
exit_if_error "Could not deploy iris"
