#!/bin/bash

source ./ICMDurable/base_env.sh

clear

docker run --name icm -it -v $PWD/ICMDurable:/ICMDurable --cap-add SYS_TIME $IRIS_PRIVATE_REPO:icm.$IRIS_TAG
printf "\nExited icm container\n"
printf "\nRemoving icm container...\nContainer removed:  "
docker rm icm