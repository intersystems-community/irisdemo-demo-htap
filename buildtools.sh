#!/bin/bash

exit_if_error() {
	if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
		echo ""
		echo "ERROR: $1"
		echo ""
		exit 1
	fi
}

build_java_project() {

	PROJECTS_FOLDER=$PWD/$1/projects

	echo ""
	echo "---------------------------------------------------------------------------"
	echo "BEGIN building $1..."
	echo "---------------------------------------------------------------------------"
	echo ""

	[[ -z "${1}" ]] && echo "Environment variable $1 not set. Need name of the java project to build." && exit 1

	# Removing existing app.jar. A new one should be produced bellow. That is what is going to be
	# cooked inside the IMAGE_NAME
	rm -f $PROJECTS_FOLDER/app.jar

	echo "#" 
	echo "# Starting container $1 to recompile jar..."
	echo "#" 
	docker ps -a | grep $1 > /dev/null

	if [ $? -eq 0 ]; then
		# This will reuse the mavenc container that we used previously to compile the project
		# This way, we avoid redownloading all the depedencies!

		docker start -i $1
		exit_if_error "Could not start container $1"
	else
		# First tiem trying to compile a project, let's create the mavenc container
		# It will download all the dependencies of the project
		docker run -i \
			-v ${PROJECTS_FOLDER}:/usr/projects \
			--name $1 intersystemsdc/irisdemo-base-mavenc:latest
		exit_if_error "Could not create and run container $1"
	fi

	# There should be one or more jar files available for us to build images with
	# Let's build an image for each file:	

	echo "#" 
	echo "# Now, let's build an image per each file found on $PROJECTS_FOLDER"; 
	echo "#"

	for JAR_FILE_WITH_PATH in $PROJECTS_FOLDER/*.jar; do 

		JAR_FILE=${JAR_FILE_WITH_PATH##*[/]}
		IMAGE_NAME=${JAR_FILE%*.jar}-${DOCKER_TAG}

		echo "#" 
		echo "# Found $JAR_FILE_WITH_PATH! Building image $IMAGE_NAME:"; 
		echo "#"

		# We must copy the file to app.jar because that is how
		# the Dockerfile expects it to be called to add it to the image
		echo "#" 
		echo "# Copying $JAR_FILE_WITH_PATH to $PROJECTS_FOLDER/app.jar so that the image can use it..."; 
		echo "#"

		cp -f $JAR_FILE_WITH_PATH $PROJECTS_FOLDER/app.jar
		exit_if_error "Could not copy file $JAR_FILE_WITH_PATH to $PROJECTS_FOLDER/app.jar"

        IMAGE_FULL_NAME=intersystemsdc/irisdemo-demo-htap:${IMAGE_NAME}
		docker build --build-arg VERSION=${DOCKER_TAG} -t ${IMAGE_FULL_NAME} ./$1
		exit_if_error "build of ${IMAGE_NAME} failed."

        echo ${IMAGE_FULL_NAME} >> ./images_built

		rm $PROJECTS_FOLDER/app.jar
	done

	echo ""
	echo "---------------------------------------------------------------------------"
	echo "END building image ${IMAGE_NAME}..."
	echo "---------------------------------------------------------------------------"
	echo ""
}


push_images() {
	cat ./images_built | while read FULL_IMAGE_NAME 
	do
		echo ""
		echo "---------------------------------------------------------------------------"
		echo "BEGIN pushing image ${FULL_IMAGE_NAME}..."
		echo "---------------------------------------------------------------------------"
		echo ""
		
		docker push $FULL_IMAGE_NAME
		exit_if_error "Could not push $FULL_IMAGE_NAME!"

		echo ""
		echo "---------------------------------------------------------------------------"
		echo "END pushing image ${FULL_IMAGE_NAME}..."
		echo "---------------------------------------------------------------------------"
		echo ""

	done
}
