#!/bin/bash

######################################################################
# You can change these three variables to use a different IRIS image
######################################################################

export IRIS_PRIVATE_REPO=$(cat /ICMDurable/CONF_IRIS_PRIVATE_REPO)
export IRIS_PRIVATE_REPO_TAG=$(cat /ICMDurable/CONF_IRIS_PRIVATE_REPO_TAG) 

# This one is what is used to replace <IRISDockerImage> on defaults.json template files:
# The "iris" prefix in front of the IRIS_TAG will allow us to add more than one IRIS image to the same 
# Docker Hub private repository. 
export IRIS_DOCKER_IMAGE=$IRIS_PRIVATE_REPO:$IRIS_PRIVATE_REPO_TAG

######################################################################
# Do not change anything bellow this comment
######################################################################
export IRIS_PORT=1972
export IRIS_ECP_PORT=1972

# this is going to be automatically update every time we bump a version on git
export HTAP_DEMO_VERSION=version-2.7.0
