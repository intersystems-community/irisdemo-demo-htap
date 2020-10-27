source ./env.sh
source /Kubernetes/utils.sh

#
#Iris Deployment uninstalled as per https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=AIKO
#

#REMOVING IRIS FIRST
printf "\n\n${GREEN}Deleting IRIS from cluster...${RESET}"
kubectl delete -f iris-deployment.yaml
exit_if_error "Could not delete IRIS"
kubectl delete pvc --all
exit_if_error "Could not delete PVCs"
kubectl delete svc/iris-svc
exit_if_error "Could not delete iris service"

#remove IKO from cluster
printf "\n\n${GREEN}Deleting IKO from cluster...${RESET}"
helm uninstall intersystems
exit_if_error "Could not delete IKO"

#remove all deployment yamls

kubectl delete -f ../../common/deployment-master.yml
exit_if_error "Could not delete master"
kubectl delete -f ../../common/deployment-ui.yml
exit_if_error "Could not delete the ui"
kubectl delete -f ../../common/deployment-workers.yml
exit_if_error "Could not delete workers"
kubectl delete -f ./storage-class.yaml
exit_if_error "Could not delete storage class"

printf "\n\n${GREEN}Using EKS to unprovision the cluster...${RESET}"

eksctl delete cluster -f ./cluster-config.yaml
exit_if_error "Could not delete cluster"
