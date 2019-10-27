#!/bin/bash
source .env

rm -f ./image-master/projects/app.jar
docker-compose stop
docker-compose rm -f
docker rm mavenc
docker rmi ${IMAGE_MASTER_NAME}
docker rmi ${IMAGE_IRIS_JDBC_INGEST_WORKER_NAME}
