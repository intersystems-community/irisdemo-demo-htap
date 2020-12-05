#!/bin/bash

# Based on this very good article:
# https://poweruser.blog/tweaking-docker-desktops-kubernetes-on-win-mac-7a20aa9b1584

# Requires Helm 3

helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo update

# Fix kubectl top

kubectl create namespace my-metrics-server
helm install my-metrics-server --set "args={--kubelet-insecure-tls}" stable/metrics-server --namespace my-metrics-server

# Install Kubernetes Dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc6/aio/deploy/recommended.yaml

# Create service account for accessing the dashboard

# creating namespace "my-dashboard-sas"
kubectl create namespace my-dashboard-sas

# creating service account "my-dashboard-clusteradmin" in namespace "my-dashboard-sas"
kubectl -n my-dashboard-sas create serviceaccount my-dashboard-clusteradmin

# linking the service account "my-dashboard-clusteradmin" to the role "cluster-admin" in the same namespace
kubectl create clusterrolebinding my-dashboard-clusteradmin-role --clusterrole=cluster-admin --serviceaccount=my-dashboard-sas:my-dashboard-clusteradmin

# show secrets
kubectl -n my-dashboard-sas get secrets

printf "\n Now use command\n\n"
printf "\tkubectl -n my-dashboard-sas describe secret <SECRET>\n\n"
printf "To see the created secret. And use the command:\n\n"
printf "\tkubectl proxy\n"
printf "\nTo open a channel to the cluster and open the portal at:\n"
printf "\thttp://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login\n"
printf "\n"