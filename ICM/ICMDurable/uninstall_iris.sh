#!/bin/sh
#
source /ICMDurable/env.sh
source /ICMDurable/utils.sh

printf "\n\n${RED}WARNING: This script was meant to uninstall a container-less IRIS installed by ICM."
printf "If this is a container-less IRIS installation, it will completely uninstall IRIS and delete the"
printf "\ndurable %SYS folder on the host machine."
printf "\n\nBut if this is not a container-less IRIS installation, it will ONLY delete the durable %SYS"
printf "\nof the container. Thay may be useful when a previous container based IRIS deployment failed"
printf "\nand you want to clean the half-installed durable %SYS that was created on the host machine"
printf "\nbefore trying to deploy the IRIS container again."

printf "\n\n${RESET}Do you want to continue? Type yes if you do: "
read answer

if [ "$answer" != 'yes' ];
then
    printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
    exit 0
fi

if [ "$CONTAINERLESS" == "true" ];
then
    icm uninstall
    exit_if_error "Uninstalling IRIS failed."

    icm ssh -command "sudo rm -rf /irissys/*/*"
    exit_if_error "Failed to remove Durable %SYS"

    #icm ssh -command "sudo rm -rf /irissys/*/*"
    #exit_if_error "Failed to remove old iris.key"

    printf "\n\n${GREEN}IRIS Uninstalled successfully.\n\n${RESET}"    
fi

icm ssh -command "sudo rm -rf /irissys/*/*"
exit_if_error "Failed to remove Durable %SYS"

printf "\n\n${GREEN}IRIS Durable %SYS removed from hosts.\n\n${RESET}"

