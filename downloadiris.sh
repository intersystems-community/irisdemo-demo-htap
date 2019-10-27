#!/bin/bash
#
# I am using this script to download IRIS from our internal docker-registry and push
# it to a private Docker Repo so I ICM can pull it when deploying to AWS
#

#
# Parameter
#
TAG=2019.3.0-latest
PRIVATE_DOCKER_REPO=amirsamary/irisdemo
#
# Constants
#

# Taking from InterSystems repository on Docker Hub:
ISC_IMAGENAME=docker.iscinternal.com/intersystems/iris:$TAG

# Pushing to our repository on Docker Hub:
DH_IMAGENAME=${PRIVATE_DOCKER_REPO}:iris.$TAG


printf "\n\nLoggin into docker.iscinternal.com (VPN Required!) to download newer images...\n"
docker login docker.iscinternal.com

printf "\n\nPulling images...\n"
docker pull $ISC_IMAGENAME
if [ $? -eq 0 ]; then
    printf "\nPull of $ISC_IMAGENAME succesful. \n"
else
    printf "\nPull of $ISC_IMAGENAME failed. \n"
    exit 0
fi

printf "\n\Tagging images...\n"
docker tag $ISC_IMAGENAME $DH_IMAGENAME

if [ $? -eq 0 ]; then
    printf "\Tagging of $ISC_IMAGENAME as $DH_IMAGENAME successful\n"
else
    printf "\Tagging of $ISC_IMAGENAME as $DH_IMAGENAME failed\n"
    exit 0
fi

printf "\n\nEnter with your credentials on docker hub so we can upload the images:\n"
docker login

printf "\n\Uploading images...\n"
docker push $DH_IMAGENAME
if [ $? -eq 0 ]; then
    printf "\Pushing of $DH_IMAGENAME successful.\n"
else
    printf "\Pushing of $DH_IMAGENAME successful.\n"
    exit 0
fi