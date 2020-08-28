#!/bin/sh
source ./env.sh
source /ICMDurable/utils.sh

rm -f /ICMDurable/license/.DS_Store
rm -f /ICMDurable/license/replace_this_file_with_your_iris_key

provisionWorkarounds

if [ ! -f ./defaults.json ];
then
    printf "\n\n${RED}You must run setup.sh first.\n\n${RESET}"
    exit 1
fi


# 
# Verify if our ports are configured before provisioning.
# 
terraform_aws_open_ports

#
# Now we can provision
#
icm provision
exit_if_terraform_error "Provisioning the infrastructure failed."

printf "\n\n${GREEN}Installing docker on the VM nodes...${RESET}"
printf "\n\n${GREEN}Running preInstallDocker.sh...\n${RESET}"
icm ssh --role VM --command "./ICM/preInstallDocker.sh"
exit_if_error "preInstallDocker.sh failed on VM machines"

sleep 5

printf "\n\n${GREEN}Running installDockerCE.sh...\n${RESET}"
icm ssh --role VM --command "export DOCKER_STORAGE_DRIVER=devicemapper && ./ICM/installDockerCE.sh"
exit_if_error "installDockerCE.sh failed on VM machines"

touch ./.provisionHasBeenRun

getVPC

printf "\n\n${YELLOW}If you are planning on deploying SAP HANA, AWS Aurora or any other AWS database, deploy them on the VPC_ID $VPC_ID.${RESET}\n\n"

printf "\n\n${YELLOW}You can run ./deployiris.sh to deploy InterSystems IRIS to the provisioned infrastructure.\n\n${RESET}"

