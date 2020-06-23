#!/bin/bash

######################################################################
# You can change these three variables to use a different IRIS image
######################################################################

# These two are used on the script putirisondockerhub.sh 
export IRIS_TAG=$(cat /ICMDurable/CONF_IRISVERSION) 
export IRIS_PRIVATE_REPO=$(cat /ICMDurable/CONF_DOCKERHUB_REPOSITORY)

# This one is what is used to replace <IRISDockerImage> on defaults.json template files:
# The "iris" prefix in front of the IRIS_TAG will allow us to add more than one IRIS image to the same 
# Docker Hub private repository. 
export IRIS_DOCKER_IMAGE=$IRIS_PRIVATE_REPO:iris.$IRIS_TAG

######################################################################
# Do not change anything bellow this comment
######################################################################
export IRIS_PORT=51773
export IRIS_ECP_PORT=51773

# this is going to be automatically update every time we bump a version on git
export HTAP_DEMO_VERSION=version-2.4.21
