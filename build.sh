#!/bin/bash
VERSION=`cat ./VERSION`
DOCKER_TAG="version-${VERSION}"

source ./buildtools.sh

# funtion build_java_project will add a line with the full image name of each image built
# But we need to start with an empty file:
# rm -f ./images_built

# build_java_project "image-master"

build_java_project "image-ingest-worker"

# build_java_project "image-query-worker"

# UI_IMAGE_NAME=intersystemsdc/irisdemo-demo-htap:ui-${DOCKER_TAG}
# docker build -t $UI_IMAGE_NAME ./image-ui
# echo $UI_IMAGE_NAME >> ./images_built
# This last image was not built with the function build_java_project(). So we will
# add the full image name ourselves.

# It is necessary to build the application this way as well so it can be run standalone, without dockers.
# (cd ./image-ui && npm install)

