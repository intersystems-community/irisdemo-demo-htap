#!/bin/bash

IRIS_TAG=$(cat ./ICMDurable/CONF_IRISVERSION) 
IRIS_PRIVATE_REPO=$(cat ./ICMDurable/CONF_DOCKERHUB_REPOSITORY)

clear

docker run --rm -it -v $PWD/ICMDurable:/ICMDurable --cap-add SYS_TIME $IRIS_PRIVATE_REPO:$IRIS_TAG
printf "\nExited icm container\n"

