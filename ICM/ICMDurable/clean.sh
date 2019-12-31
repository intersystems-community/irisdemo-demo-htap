#!/bin/sh

source /ICMDurable/utils.sh

printf "\n\n${RED}WARNING: If you continue, this script will clean your State dir, log files and instances.json file."
printf "\n${YELLOW}It will leave your SSH/TLS keys, definition.json and defaults.json files though. "
printf "\n${YELLOW}This script is useful if you just unprovisioned the infrastructure and you want to reprovision it again from scratch."
printf "\n\n${RESET}Do you want to continue? Type yes if you do: "
read answer

if [ "$answer" != 'yes' ];
then
    printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
    exit 0
fi

rm -f ./.provisionHasBeenRun
rm -rf /ICMDurable/State
mkdir /ICMDurable/State
rm -f /ICMDurable/*.log
rm -f /ICMDurable/instances.json
rm -rf /ICMDurable/.terraform
rm -f ./.CNcount