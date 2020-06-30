#!/bin/bash
#
# 1. This script is used by InterSystems employees so they can easily download ICM
# from InterSystems' internal docker registry. It is not meant for public usage.
#
# 2. This script is only useful today to download ICM from docker.iscinternal.com and retag it 
# from its full name (i.e: "docker.iscinternal.com/intersystems/icm:2020.2.0.204.0") to the same name
# used when downloading ICM from WRC (i.e.: "intersystems/icm:2020.2.0.204.0"). So, if you are following
# instructions on README.md on this folder and you are downloading ICM from WRC, you should not need this
# script! But you are free to use if you are confortable with using docker.iscinternal.com.
#

export ICM_REPO=$(cat ./ICMDurable/CONF_ICM_REPO)
export ICM_TAG=$(cat ./ICMDurable/CONF_ICM_TAG) 

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
        printf "\n\n${YELLOW}Trying to log in on $1...${NC}\n"
        docker login -u $dockerUsername -p $dockerPassword $1
    fi
    checkError "Login failed." "Login successful!"
}

#
# MAIN
#

printf "\n\n${YELLOW}Loggin into docker.iscinternal.com (VPN Required!) to download newer images...${NC}\n"
dockerLogin docker.iscinternal.com

printf "\n\n${YELLOW}Pulling image docker.iscinternal.com/intersystems/icm:$ICM_TAG...${NC}\n"
docker pull docker.iscinternal.com/intersystems/icm:$ICM_TAG
checkError "ICM Pull failed." "Pull successful!"


# InterSystems' internal docker registry tags the images with the full name of the docker registry on it. 
# Let's retag it to just intersystems/icm so that it will match the tag used by WRC
printf "\n${YELLOW}Tagging image docker.iscinternal.com/intersystems/icm:$ICM_TAG to $ICM_REPO:$ICM_TAG...${NC}\n"
docker tag docker.iscinternal.com/intersystems/icm:$ICM_TAG $ICM_REPO:$ICM_TAG
checkError "IRIS Tagging failed." "IRIS Tagging successful!"