#!/bin/bash
source ../.env

clear

docker run --name icm -it -v $PWD/ICMDurable:/ICMDurable --cap-add SYS_TIME ${ICM_IMAGE}
printf "\nExited icm container\n"
printf "\nRemoving icm container...\nContainer removed:  "
docker rm icm