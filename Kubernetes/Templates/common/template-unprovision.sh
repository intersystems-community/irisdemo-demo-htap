source ./envar.sh
source ../../utils.sh

#
#Iris Deployment uninstalled as per https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=AIKO
#

#REMOVING IRIS FIRST
printf "\n\n${GREEN}Deleting IRIS from cluster...${RESET}"
kubectl delete -f ./iris-deployment.yaml

if [ "$COMMUNITY" == "false" ];
then 

    kubectl delete pvc --all
    kubectl delete svc/iris-svc


    #remove IKO from cluster
    printf "\n\n${GREEN}Deleting IKO from cluster...${RESET}"
    helm uninstall intersystems


    kubectl delete -f ./storage-class.yaml
fi

#remove all deployment yamls

kubectl delete -f ./deployment-master.yaml
kubectl delete -f ./deployment-ui.yaml
kubectl delete -f ./service-ui.yaml
kubectl delete -f ./deployment-workers.yaml


if [ "$LOCAL" != "true" ];
then
    printf "\n\n${GREEN}Using EKS to unprovision the cluster...${RESET}"
    eksctl delete cluster -f ./cluster-config.yaml
    exit_if_error "Could not delete cluster"
fi

