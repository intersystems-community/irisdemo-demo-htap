#!/bin/bash

POD=$(kubectl get pods -o=custom-columns='DATA:metadata.name' | grep $1)
kubectl exec -it $POD $2 -- sh 