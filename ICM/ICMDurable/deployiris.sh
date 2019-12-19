#!/bin/sh
#
# This is just a shortcut to trigger the deployment of InterSystems IRIS on the provisioned infrastruture.
#
# You should run this AFTER running ./provision.sh
#
source /ICMDurable/env.sh
source /ICMDurable/utils.sh

icm run -stateDir /ICMDurable/State
exit_if_error "Deploying IRIS failed."

printf "\n\n${YELLOW}You can run ./deployspeedtest.sh to deploy the Speed Test to the provisioned infrastructure now.\n\n${RESET}"