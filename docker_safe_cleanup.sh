#!/bin/bash
#
#  Courtesy of Nicholai Mitchko:
# 

# Remove stopped containers 
docker rm $(docker ps -f status=exited -aq)

# Remove image layers that are not used in any images
docker rmi $(docker images -f "dangling=true" -q)

# Remove volumes that are not used by any containers.
docker volume rm $(docker volume ls -qf dangling=true)