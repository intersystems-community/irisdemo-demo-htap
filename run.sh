#!/bin/bash
#
# This script is meant to support running the speedtest with docker-compose
#
# You can:
# - call it without any arguments to run the speed test using IRIS. 
# - call it with an argument to run the speed test using another datbase. The available options are: 
#   - mysql
#
# Each option will lead to using a diffent docker-compose.yml file.
#

if [ -z "$1" ];
then
    docker-compose stop
    docker-compose rm -f
    docker-compose up
else
    docker-compose -f $1-docker-compose.yml stop
    docker-compose -f $1-docker-compose.yml rm -f
    docker-compose -f $1-docker-compose.yml up
fi