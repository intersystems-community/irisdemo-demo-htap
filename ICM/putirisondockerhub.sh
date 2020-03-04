#!/bin/bash

export IRIS_TAG=$(cat ./ICMDurable/CONF_IRISVERSION) 
export IRIS_PRIVATE_REPO=$(cat ./ICMDurable/CONF_DOCKERHUB_REPOSITORY)

#
# CONSTANTS
#
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# checkError(errorMsg, successMsg)
# 
# If last command terminated with an error, prints errorMsg and exits with error returned.
# IF last command did not terminated with an error, prints successMsg.
function checkError() {
    if [ ! $? -eq 0 ]
    then 
        printf "${RED}\n$1\n${NC}"
        exit $?
    else
        if [ ! -z "$2" ]
        then
            printf "\n${GREEN}$2${NC}\n"
        fi
    fi
}

# dockerLogin <docker registry url>
#
# Can receive one parameter with the docker registry to log in to. Ex:
#
#   dockerLogin docker.iscinternal.com
#
# If no parameter is given, will do the docker login on Docker Hub.
#
function dockerLogin() {
    printf "\n\nDocker Credentials:\n"
    printf "\n\tLogin   : "
    read dockerUsername
    printf "\tPassword: "
    stty -echo
    read dockerPassword
    stty echo
    printf "\n\n"

    if [ -z "$dockerUsername" ]
    then
        printf "\n\n${RED}ABORTING: Docker username is required.${NC}\n\n"
        exit 1
    fi

    if [ -z "$dockerPassword" ]
    then
        printf "\n\n${RED}ABORTING: Docker password is required${NC}\n\n"
        exit 1
    fi

    printf "\n\n${YELLOW}Logging in...${NC}\n"
    if [ -z "$1" ]
    then
        printf "\n\n${YELLOW}Trying to log in on docker hub...${NC}\n"
        docker login -u $dockerUsername -p $dockerPassword
    else
        printfY "\n\n${YELLOW}Trying to log in on $1...${NC}\n"
        docker login -u $dockerUsername -p $dockerPassword $1
    fi
    checkError "Login failed." "Login successful!"
}

#
# MAIN
#

printf "\n\n${YELLOW}Loggin into docker.iscinternal.com (VPN Required!) to download newer images...${NC}\n"
dockerLogin docker.iscinternal.com

printf "\n\n${YELLOW}Pulling images...${NC}\n"

docker pull docker.iscinternal.com/intersystems/iris:$IRIS_TAG
checkError "IRIS Pull failed." "Pull successful!"

docker pull docker.iscinternal.com/intersystems/icm:$IRIS_TAG
checkError "ICM Pull failed." "Pull successful!"

printf "\n${YELLOW}Tagging images...${NC}\n"

docker tag docker.iscinternal.com/intersystems/iris:$IRIS_TAG $IRIS_PRIVATE_REPO:iris.$IRIS_TAG
checkError "IRIS Tagging failed." "IRIS Tagging successful!"

docker tag docker.iscinternal.com/intersystems/icm:$IRIS_TAG $IRIS_PRIVATE_REPO:icm.$IRIS_TAG
checkError "ICM Tagging failed." "ICM Tagging successful!"

printf "\n\n${YELLOW}Loggin into Docker Hub:${NC}\n"
dockerLogin

printf "\n${YELLOW}Uploading images...${NC}\n"

docker push $IRIS_PRIVATE_REPO:iris.$IRIS_TAG
checkError "IRIS Upload failed." "IRIS Upload successful!"

docker push $IRIS_PRIVATE_REPO:icm.$IRIS_TAG
checkError "ICM Upload failed." "ICM Upload successful!"
