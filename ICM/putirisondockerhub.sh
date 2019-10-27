#!/bin/bash

#
# Parameters
#
TAG=2019.2.0-released
QUAYTAG=2019.2.0-released

#
# CONSTANTS
#
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

#
# UTILITY FUNCTIONS
#
function showError() {
    red
    printf "\nERROR: $1\n"
    nocolor
}

function showMessage() {
    green
    printf "\n$1\n"
    nocolor
}

function printfY() {
    yellow
    printf "$1"
    nocolor
}

function printfR() {
    red
    printf "$1"
    nocolor
}

function printfG() {
    green
    printf "$1"
    nocolor
}

function nocolor() {
    printf "${NC}"
}

function yellow() {
    printf "${YELLOW}"
}

function red() {
    printf "${RED}"
}

function green() {
    printf "${GREEN}"
}

# checkError(errorMsg, successMsg)
# 
# If last command terminated with an error, prints errorMsg and exits with error returned.
# IF last command did not terminated with an error, prints successMsg.
function checkError() {
    if [ ! $? -eq 0 ]
    then 
        printfR "\n$1\n"
        exit $?
    else
        if [ ! -z "$2" ]
        then
            printfG "\n$2\n"
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
        printfR "\n\nABORTING: Docker username is required.\n\n"
        exit 1
    fi

    if [ -z "$dockerPassword" ]
    then
        printfR "\n\nABORTING: Docker password is required\n\n"
        exit 1
    fi

    printfY "\n\nLogging in...\n"
    if [ -z "$1" ]
    then
        printfY "\n\nTrying to log in on docker hub...\n"
        docker login -u $dockerUsername -p $dockerPassword
    else
        printfY "\n\nTrying to log in on $1...\n"
        docker login -u $dockerUsername -p $dockerPassword $1
    fi
    checkError "Login failed." "Login successful!"
}

#
# MAIN
#

printfY "\n\nLoggin into docker.iscinternal.com (VPN Required!) to download newer images...\n"
dockerLogin docker.iscinternal.com

printfY "\n\nPulling images...\n"

docker pull docker.iscinternal.com/intersystems/iris:$QUAYTAG
checkError "Pull failed." "Pull successful!"

printfY "\n\Tagging images...\n"

docker tag docker.iscinternal.com/intersystems/iris:$QUAYTAG amirsamary/irisdemo:iris.$TAG
checkError "Tagging failed." "Tagging successful!"

printfY "\n\nLoggin into Docker Hub:\n"
dockerLogin

printfY "\n\Uploading images...\n"

docker push amirsamary/irisdemo:iris.$TAG
checkError "Upload failed." "Upload successful!"
