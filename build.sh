#!/bin/bash
VERSION=`cat ./VERSION`

exit_if_error() {
	if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
		echo ""
		echo "ERROR: $1"
		echo ""
		exit 1
	fi
}

build_java_project() {

	PROJECTS_FOLDER=${PWD}/$1/projects

	echo ""
	echo "---------------------------------------------------------------------------"
	echo "BEGIN building $1..."
	echo "---------------------------------------------------------------------------"
	echo ""

	[[ -z "${1}" ]] && echo "Environment variable $1 not set. Need name of the java project to build." && exit 1

	# Removing existing app.jar. A new one should be produced bellow. That is what is going to be
	# cooked inside the IMAGE_NAME
	rm -f $PROJECTS_FOLDER/app.jar

	echo "Starting container $1 to recompile jar..."
	docker ps -a | grep $1 > /dev/null

	if [ $? -eq 0 ]; then
		# This will reuse the mavenc container that we used previously to compile the project
		# This way, we avoid redownloading all the depedencies!

		docker start -i $1
		exit_if_error "Could not start container $1"
	else
		# First tiem trying to compile a project, let's create the mavenc container
		# It will download all the dependencies of the project
		docker run -it \
			-v ${PROJECTS_FOLDER}:/usr/projects \
			--name $1 intersystemsdc/irisdemo-base-mavenc:latest
		exit_if_error "Could not create and run container $1"
	fi

	# There should be one or more jar files available for us to build images with
	# Let's build an image for each file:	
	for JAR_FILE_WITH_PATH in $PROJECTS_FOLDER/*.jar; do 
		echo "" 
		echo "Building image $IMAGE_NAME..."; 
		echo ""

		JAR_FILE=${JAR_FILE_WITH_PATH##*[/]}
		IMAGE_NAME=${JAR_FILE%*.jar}-version-${VERSION}

		# We must copy the file to app.jar because that is how
		# the Dockerfile expects it to be called to add it to the image
		cp -f $JAR_FILE_WITH_PATH $PROJECTS_FOLDER/app.jar
		
		docker build --build-arg VERSION=version-${VERSION} -t intersystemsdc/irisdemo-demo-htap:${IMAGE_NAME} ./$1
		exit_if_error "build of ${IMAGE_NAME} failed."

		rm $PROJECTS_FOLDER/app.jar
	done

	echo ""
	echo "---------------------------------------------------------------------------"
	echo "END building image ${IMAGE_NAME}..."
	echo "---------------------------------------------------------------------------"
	echo ""
}

docker-compose stop
docker-compose rm -f 

build_java_project "image-master"

build_java_project "image-ingest-worker"

build_java_project "image-query-worker"

docker build -t intersystemsdc/irisdemo-demo-htap:ui-version-${VERSION} ./image-ui

#(cd ./image-ui && npm install)

