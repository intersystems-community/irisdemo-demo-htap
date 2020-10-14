#!/bin/bash

source ./utils.sh

kubectl delete -f ./deployment-ui.yml
exit_if_error "Could not delete deployment-ui.yml"

kubectl delete -f ./deployment-master.yml
exit_if_error "Could not delete deployment-master.yml"

kubectl delete -f ./deployment-iris.yml
exit_if_error "Could not apply deployment-iris.yml"

kubectl delete -f ./deployment-workers.yml
exit_if_error "Could not delete deployment-workers.yml"