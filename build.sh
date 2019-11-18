#!/bin/bash
# 
# This build.sh is different from buildc.sh because it builds the projet outside
# the containers so we can run the htap demo stand alone and point it to any
# IRIS installation (that may not necessarily be on a container).
#
# It will require Maven and NodeJS installed on your system.
#

set -e

STANDALONE=$PWD/standalone
rm -f $STANDALONE/*.jar

echo
echo '********************************************************************************'
echo 'Configuring IRIS Jdbc Driver on your local Maven'
echo '********************************************************************************'
echo
(
	cd ./standalone/maven-iris && \
	./configmaven.sh
)

echo
echo '********************************************************************************'
echo 'Building MASTER'
echo '********************************************************************************'
echo

(
	cd ./image-master/projects/master && \
	mvn package install && \
	cp ./target/*.jar $STANDALONE/master.jar
)

echo
echo '********************************************************************************'
echo 'Building IRIS JDBC Ingestion Worker'
echo '********************************************************************************'
echo
(
	cd ./image-iris-jdbc-ingest-worker/projects/iris-jdbc-ingest-worker && \
	mvn package install && \
	cp ./target/*.jar $STANDALONE/iris-jdbc-ingest-worker.jar
)

echo
echo '********************************************************************************'
echo 'Building IRIS JDBC Query Worker'
echo '********************************************************************************'
echo
(
	cd ./image-iris-jdbc-query-worker/projects/iris-jdbc-query-worker && \
	mvn package install && \
	cp ./target/*.jar $STANDALONE/iris-jdbc-query-worker.jar
)
