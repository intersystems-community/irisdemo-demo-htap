#!/bin/bash

ICM_TAG=$(cat ./ICMDurable/CONF_ICM_TAG) 
ICM_REPO=$(cat ./ICMDurable/CONF_ICM_REPO)

clear

printf "\nStarting ICM with $ICM_REPO:$ICM_TAG..."
docker run --rm -it -v $PWD/ICMDurable:/ICMDurable --cap-add SYS_TIME $ICM_REPO:$ICM_TAG
printf "\nExited icm container\n"

