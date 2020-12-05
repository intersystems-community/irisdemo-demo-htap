#!/bin/bash
source ../../utils.sh

kubectl delete -f ./service-ui.yaml
exit_if_error "Could not deploy service UI"
kubectl delete -f ./deployment-master.yaml
exit_if_error "Could not deploy master"
kubectl delete -f ./deployment-ui.yaml
exit_if_error "Could not deploy the ui"
kubectl delete -f ./deployment-workers.yaml
exit_if_error "Could not deploy workers"


kubectl apply -f ./deployment-master.yaml
exit_if_error "Could not deploy master"
kubectl apply -f ./deployment-ui.yaml
exit_if_error "Could not deploy the ui"
kubectl apply -f ./deployment-workers.yaml
exit_if_error "Could not deploy workers"
kubectl apply -f ./service-ui.yaml
exit_if_error "Could not deploy service UI"
