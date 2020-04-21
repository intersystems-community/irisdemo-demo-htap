#!/bin/bash
# 
# Author: Amir Samary
# Docker commands courtesy of Nicholai Mitchko.
#

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# Remove stopped containers 
stopped_containers=$(docker ps -f status=exited -aq)
if [ ! -z "$stopped_containers" ];
then
    printf "\n\n${YELLOW}Removing stopped containers...${RESET}\n"
    docker rm $stopped_containers
else
    printf "\n\n${GREEN}No stopped containers to remove.${RESET}\n"
fi

# Remove image layers that are not used in any images
dangling_images=$(docker images -f "dangling=true" -q)
if [ ! -z "$dangling_images" ];
then
    printf "\n\n${YELLOW}Removing dangling images...${RESET}\n"
    docker rmi $dangling_images
else
    printf "\n\n${GREEN}No dangling images to remove.${RESET}\n"
fi

# Remove volumes that are not used by any containers.
unused_volumes=$(docker volume ls -qf dangling=true)
if [ ! -z "$unused_volumes" ];
then
    printf "\n\n${YELLOW}Removing unused volumes...${RESET}\n"
    docker volume rm $unused_volumes
else
    printf "\n\n${GREEN}No unused volumes to remove.${RESET}\n"
fi

