#!/bin/bash
#
# Use this script to START ALL the services (on a single machine) to run the speedtest without containers against InterSystems IRIS
#
# You can either use this script directly by clonning this repository and running it or use it as a basis to build your own.
#
# This script is DIFFERENT from the start_master_and_ui.sh, start_ingestion_worker.sh and start_query_worker.sh scripts
# because it starts everything altogether on a single server. The other scripts are meant to start each service
# on a different server.
#
# As a starting point, this script is starting IRIS as a container and relies on Docker for doing this. You are
# free to change this part of the script to not start that container and just configure the environment
# variables to point to an existing IRIS cluster.
#

source ./start_all_config.sh

# Configure function cleanup() to be executed on CTRL+C
function cleanup()
{
    # Restore normal CTRL+C behaviour
    trap - INT

    # Do the cleanup
    source ./stop_containers.sh
}
trap cleanup INT

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting Master'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

export LOG_FILENAME=master.log
../../image-master/projects/master.jar start --server.port=8080
echo 'Waiting 5 seconds for master to finish starting...'
sleep 5

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting IRIS JDBC Ingestion Worker'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

export LOG_FILENAME=ingestion_worker.log
../../image-ingest-worker/projects/iris-jdbc-ingest-worker.jar start --server.port=8181

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting IRIS JDBC Query Worker'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

export LOG_FILENAME=query_worker.log
../../image-query-worker/projects/iris-jdbc-query-worker.jar start --server.port=8282

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting IRIS Container for testing'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

# This image has a fixed password and is ready to receive a connection. 
# You can commend this command bellow if you plan on connecting to an IRIS instance that is
# running on your PC (not on a container)
# But if you decide to use containers and change the image bellow, make sure to pick an image with
# a password already defined.
docker run --init -d --rm --name iris_htap -p 51773:51773 -p 52773:52773 intersystemsdc/irisdemo-base-irisdb-community:version-1.2 

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Starting the UI! It may take a while. When done, you should be able to open it'
echo "at http://${MASTER_HOSTNAME}:4200"
echo " "
echo "When you are done with the speed test, you can CTRL+C here so we will stop all "
echo "the services for you."
echo '********************************************************************************'
printf "${NOCOLOR}\n"

(cd ../../image-ui && npm run standalone)