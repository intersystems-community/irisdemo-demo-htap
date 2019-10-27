#!/bin/bash

source .env

build_java_project() {
	[[ -z "${1}" ]] && echo "Environment variable $1 not set. Need name of the java project to build." && exit 1

	docker ps -a | grep $1 > /dev/null
	if [ $? -eq 0 ]; then
		# This will reuse the mavenc container that we used previously to compile the project
		# This way, we avoid redownloading all the depedencies!
		docker start -i $1
	else
		# First tiem trying to compile a project, let's create the mavenc container
		# It will download all the dependencies of the project
		docker run -it \
			-v ${PWD}/$1/projects:/usr/projects \
			--name $1 intersystemsdc/irisdemo-base-mavenc:latest
	fi
}

docker-compose stop 
docker-compose rm -f 

build_java_project "image-master"
docker build -t ${IMAGE_MASTER_NAME} ./image-master

build_java_project "image-iris-jdbc-ingest-worker"
docker build -t ${IMAGE_IRIS_JDBC_INGEST_WORKER_NAME} ./image-iris-jdbc-ingest-worker

# docker build -t ${IMAGE_UI_NAME} ./image-ui