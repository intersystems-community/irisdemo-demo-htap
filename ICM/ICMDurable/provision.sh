#!/bin/sh
source /ICMDurable/env.sh
source /ICMDurable/utils.sh

if [ ! -f ./defaults.json ];
then
    printf "\n\n${RED}You must run setup.sh first.\n\n${RESET}"
    exit 1
fi


if [ ! -d ./State ]; then
    mkdir ./State
fi

icm provision -stateDir /ICMDurable/State
exit_if_terraform_error "Provisioning the infrastructure failed."

touch ./.provisionHasBeenRun

printf "\n\n${YELLOW}You can run ./deployiris.sh to deploy InterSystems IRIS to the provisioned infrastructure.\n\n${RESET}"