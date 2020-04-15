#!/bin/bash

source ./start_all_config.sh

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Stopping Master'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

../../image-master/projects/master.jar stop

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Stopping IRIS JDBC Ingestion Worker'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

../../image-ingest-worker/projects/iris-jdbc-ingest-worker.jar stop

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Stopping IRIS JDBC Query Worker'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

../../image-query-worker/projects/iris-jdbc-query-worker.jar stop

printf "${PURPLE}\n"
echo '********************************************************************************'
echo 'Stopping IRIS'
echo '********************************************************************************'
printf "${NOCOLOR}\n"

docker stop iris_htap