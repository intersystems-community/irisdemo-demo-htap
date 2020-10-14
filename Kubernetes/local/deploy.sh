#!/bin/bash

source ./utils.sh

kubectl apply -f ./deployment-ui.yml
exit_if_error "Could not apply deployment-ui.yml"

kubectl apply -f ./deployment-master.yml
exit_if_error "Could not apply deployment-master.yml"

kubectl apply -f ./deployment-iris.yml
exit_if_error "Could not apply deployment-iris.yml"

kubectl apply -f ./deployment-workers.yml
exit_if_error "Could not apply deployment-workers.yml"