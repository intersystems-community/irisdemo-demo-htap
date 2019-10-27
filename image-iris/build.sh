source ../.env

docker build --build-arg IRIS_STANDARD_IMAGE=${IRIS_STANDARD_IMAGE} -t ${IRIS_CUSTOM_IMAGE} .