#!/bin/bash

source ../utils.sh

kubectl apply -f ../deployment-ui.yml
exit_if_error "Could not apply deployment-ui.yml"

kubectl apply -f ../deployment-master.yml
exit_if_error "Could not apply deployment-master.yml"

kubectl apply -f ../deployment-workers.yml
exit_if_error "Could not apply deployment-workers.yml"

kubectl apply -f ./storage-class-iris*.yml
exit_if_error "Could not apply storage-class.yml"

kubectl create secret generic iris-key-secret --from-file=../iris.key
exit_if_error "Could not create iris key (Check that it is in appropriate directory)"

helm install intersystems ../iris_operator-2.0.0.222.0/chart/iris-operator/
exit_if_error "Error with chart installation for iris kubernetes operator"


kubectl apply -f ../deployment-iris-mirror.yml
exit_if_error "Could not apply deployment-iris.yml"


printf "\n\nWhen you are done, run the ./delete.sh script.\n\n"