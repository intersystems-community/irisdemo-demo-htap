#!/bin/bash
#
# Use this script to START IRIS on this server using a Docker container
#

# COLOR CONSTANTS
PURPLE='\033[0;35m'
NOCOLOR='\033[0m'

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting IRIS...' 
echo '********************************************************************************'
printf "${NOCOLOR}\n"

docker run --init -d --rm --name iris_htap -p 51773:51773 -p 52773:52773 intersystemsdc/irisdemo-base-irisdb-community:version-1.2 

printf "${PURPLE}\n"
echo '********************************************************************************'
echo "IRIS Started "
echo '********************************************************************************'
printf "${NOCOLOR}\n"

