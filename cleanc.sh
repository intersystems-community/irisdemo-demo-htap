#!/bin/bash

VERSION=`cat ./VERSION`

rm -f ./image-master/projects/app.jar
docker-compose stop
docker-compose rm -f
docker rm mavenc

docker rmi intersystemsdc/irisdemo-demo-htap:master-version-${VERSION} 
docker rmi intersystemsdc/irisdemo-demo-htap:iris-jdbc-ingest-worker-version-${VERSION} 
docker rmi intersystemsdc/irisdemo-demo-htap:iris-jdbc-query-worker-version-${VERSION} 
docker rmi intersystemsdc/irisdemo-demo-htap:ui-version-${VERSION}
