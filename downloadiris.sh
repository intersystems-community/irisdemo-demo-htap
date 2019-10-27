#!/bin/bash
#
# I am using this script to download IRIS from our internal docker-registry and push
# it to a private Docker Repo so I ICM can pull it when deploying to AWS
#
# Wew also need the compatible version of ICM for this IRIS version. So this script 
# will download it for us as well.
#
# Only IRIS will be pushed to the private repo. ICM image will be dowloaded to our
# machine and just stay there, available for us.

#
# Change the file .env to configure IRIS_STANDARD_TAG to the IRIS version you want. 
# Also, change IRIS_STANDARD_PRIVATE_REPO to your private repo name.
#
source ./.env

#
# No need to touch anything bellow this comment. Just run the script now.
#

printf "\n\nLoggin into docker.iscinternal.com (VPN Required!) to download newer images...\n"
docker login docker.iscinternal.com

printf "\n\nPulling images...\n"
docker pull $IRIS_STANDARD_IMAGE
if [ $? -eq 0 ]; then
    printf "\nPull of $IRIS_STANDARD_IMAGE succesful. \n"
else
    printf "\nPull of $IRIS_STANDARD_IMAGE failed. \n"
    exit 0
fi

(cd /image-iris && ./build.sh)

docker pull $ICM_IMAGE
if [ $? -eq 0 ]; then
    printf "\nPull of $ICM_IMAGE succesful. \n"
else
    printf "\nPull of $ICM_IMAGE failed. \n"
    exit 0
fi

# printf "\n\Tagging images...\n"
# docker tag $IRIS_STANDARD_IMAGE $IRIS_CUSTOM_IMAGE
# if [ $? -eq 0 ]; then
#     printf "\Tagging of $IRIS_STANDARD_IMAGE as $IRIS_CUSTOM_IMAGE successful\n"
# else
#     printf "\Tagging of $IRIS_STANDARD_IMAGE as $IRIS_CUSTOM_IMAGE failed\n"
#     exit 0
# fi

# Don't need to retag ICM. We will be running this from our machine anyway

printf "\n\nEnter with your credentials on docker hub so we can upload the images:\n"
docker login

printf "\n\Uploading images...\n"
docker push $IRIS_CUSTOM_IMAGE
if [ $? -eq 0 ]; then
    printf "\Pushing of $IRIS_CUSTOM_IMAGE successful.\n"
else
    printf "\Pushing of $IRIS_CUSTOM_IMAGE failed.\n"
    exit 0
fi

# Don't need to push ICM to our private repo. We will be running ICM from our machine.