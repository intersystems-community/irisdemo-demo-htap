#!/bin/bash

source .env

docker push ${IMAGE_MASTER_NAME}
docker push ${IMAGE_IRIS_JDBC_INGEST_WORKER_NAME} 
docker push ${IMAGE_UI_NAME}

