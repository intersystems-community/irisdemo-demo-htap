source ./envar.sh
source ../../utils.sh

#
#Iris Deployment uninstalled as per https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=AIKO
#

#REMOVING IRIS FIRST
printf "\n\n${GREEN}Deleting IRIS from cluster...${RESET}"
kubectl delete -f ./iris-deployment.yaml
exit_if_error "Could not delete IRIS"

if [ "$COMMUNITY" == "false" ];
then 

    kubectl delete pvc --all
    exit_if_error "Could not delete PVCs"
    kubectl delete svc/iris-svc
    exit_if_error "Could not delete iris service"


    #remove IKO from cluster
    printf "\n\n${GREEN}Deleting IKO from cluster...${RESET}"
    helm uninstall intersystems
    exit_if_error "Could not delete IKO"


    kubectl delete -f ./storage-class.yaml
    exit_if_error "Could not delete storage class"
fi

#remove all deployment yamls

kubectl delete -f ./deployment-master.yaml
exit_if_error "Could not delete master"
kubectl delete -f ./deployment-ui.yaml
exit_if_error "Could not delete the ui"
kubectl delete -f ./service-ui.yaml
exit_if_error "Could not delete service UI"
kubectl delete -f ./deployment-workers.yaml
exit_if_error "Could not delete workers"


if [ "$LOCAL" != "true" ];
then
    printf "\n\n${GREEN}Using EKS to unprovision the cluster...${RESET}"
    eksctl delete cluster -f ./cluster-config.yaml
    exit_if_error "Could not delete cluster"
fi

