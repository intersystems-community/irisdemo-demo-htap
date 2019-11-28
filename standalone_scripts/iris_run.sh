#!/bin/bash
#
# Use this script to START the services to run the speedtest without containers against InterSystems IRIS
#

export DISABLE_JOURNAL_FOR_DROP_TABLE=false
export DISABLE_JOURNAL_FOR_TRUNCATE=false
export INGESTION_THREADS_PER_WORKER=1
export INGESTION_BATCH_SIZE=1000
export INGESTION_JDBC_URL=jdbc:IRIS://localhost:51773/USER
export INGESTION_JDBC_USERNAME=SuperUser
export INGESTION_JDBC_PASSWORD=sys
export CONSUMER_JDBC_URL=jdbc:IRIS://localhost:51773/USER
export CONSUMER_JDBC_USERNAME=SuperUser
export CONSUMER_JDBC_PASSWORD=sys
export CONSUMER_THREADS_PER_WORKER=1
export CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS=0
export MASTER_HOSTNAME=localhost
export MASTER_PORT=8080
export HOSTNAME=localhost

# Spring boot mode. Service means it will run on the background
export MODE="service"
export PID_FOLDER=$PWD/pids
export LOG_FOLDER=$PWD/logs

rm ./logs/*.log

# Configure function cleanup() to be executed on CTRL+C
trap cleanup INT
function cleanup()
{
    # Restore normal CTRL+C behaviour
    trap - INT

    # Do the cleanup
    echo
    echo '********************************************************************************'
    echo 'Stopping Master'
    echo '********************************************************************************'
    echo

    ../image-master/projects/master.jar stop

    echo
    echo '********************************************************************************'
    echo 'Stopping IRIS JDBC Ingestion Worker'
    echo '********************************************************************************'
    echo

    ../image-ingest-worker/projects/iris-jdbc-ingest-worker.jar stop

    echo
    echo '********************************************************************************'
    echo 'Stopping IRIS JDBC Query Worker'
    echo '********************************************************************************'
    echo

    ../image-query-worker/projects/iris-jdbc-query-worker.jar stop

    echo
    echo '********************************************************************************'
    echo 'Stopping IRIS'
    echo '********************************************************************************'
    echo

    docker stop iris_htap
}

echo
echo '********************************************************************************'
echo 'Starting Master'
echo '********************************************************************************'
echo

export LOG_FILENAME=master.log
../image-master/projects/master.jar start --server.port=8080
echo 'Waiting 5 seconds for master to finish starting...'
sleep 5

echo
echo '********************************************************************************'
echo 'Starting IRIS JDBC Ingestion Worker'
echo '********************************************************************************'
echo

export LOG_FILENAME=ingest_worker.log
../image-ingest-worker/projects/iris-jdbc-ingest-worker.jar start --server.port=8181

echo
echo '********************************************************************************'
echo 'Starting IRIS JDBC Query Worker'
echo '********************************************************************************'
echo

export LOG_FILENAME=query_worker.log
../image-query-worker/projects/iris-jdbc-query-worker.jar start --server.port=8282

echo
echo '********************************************************************************'
echo 'Starting IRIS Container for testing'
echo '********************************************************************************'
echo

# This image has a fixed password and is ready to receive a connection. 
# You can commend this command bellow if you plan on connecting to an IRIS instance that is
# running on your PC (not on a container)
# But if you decide to use containers and change the image bellow, make sure to pick an image with
# a password already defined.
docker run --init -d --rm --name iris_htap -p 51773:51773 -p 52773:52773 intersystemsdc/irisdemo-base-irisdb-community:version-1.2 

echo
echo '********************************************************************************'
echo 'Starting the UI!'
echo '********************************************************************************'
echo


(cd ../image-ui && npm run standalone)
