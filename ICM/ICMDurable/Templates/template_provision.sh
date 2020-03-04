#!/bin/sh
source ./env.sh
source /ICMDurable/utils.sh

if [ ! -f ./defaults.json ];
then
    printf "\n\n${RED}You must run setup.sh first.\n\n${RESET}"
    exit 1
fi

icm provision
exit_if_terraform_error "Provisioning the infrastructure failed."

if [ "$CONTAINERLESS" == "true" ];
then
    printf "\n\n${GREEN}Containerless installation require us to manually install docker on the CN nodes...${RESET}"
    printf "\n\n${GREEN}Running preInstallDocker.sh...\n${RESET}"
    icm ssh --role CN --command "./ICM/preInstallDocker.sh"
    exit_if_error "preInstallDocker.sh failed on CN machines"
    
    sleep 5

    printf "\n\n${GREEN}Running installDockerCE.sh...\n${RESET}"
    icm ssh --role CN --command "export DOCKER_STORAGE_DRIVER=devicemapper && ./ICM/installDockerCE.sh"
    exit_if_error "installDockerCE.sh failed on CN machines"
fi

touch ./.provisionHasBeenRun

printf "\n\n${YELLOW}You can run ./deployiris.sh to deploy InterSystems IRIS to the provisioned infrastructure.\n\n${RESET}"