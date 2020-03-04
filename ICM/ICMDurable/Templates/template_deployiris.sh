#!/bin/sh
#
# This is just a shortcut to trigger the deployment of InterSystems IRIS on the provisioned infrastruture.
#
# You should run this AFTER running ./provision.sh
#
source ./env.sh
source /ICMDurable/utils.sh

if [ "$CONTAINERLESS" == "true" ];
then
    icm scp --role DM -localPath $IRIS_KIT_LOCAL_PATH -remotePath $IRIS_KIT_REMOTE_PATH
    icm install --role DM
    exit_if_error "Installing Containerless IRIS failed."
else
    # icm ssh --role DM -command "echo vm.nr_hugepages=$NR_HUGE_PAGES | sudo tee -a /etc/sysctl.conf" 
    # exit_if_error "Huge pages configuration failed"

    # icm ssh --role DM -command "sudo reboot"
    # exit_if_error "Rebooting servers after huge page configuration failed."

    icm run -options "--cap-add IPC_LOCK"
    exit_if_error "Deploying container based IRIS failed."
fi

printf "\n\n${YELLOW}You can run ./deployspeedtest.sh to deploy the Speed Test to the provisioned infrastructure now.\n\n${RESET}"

VPC_ID=$(cat ./state/$ICM_LABEL-IRISSpeedTest/terraform.tfstate | grep vpc_id | head -1 | awk -F\" '{print $4}')

printf "\n\n${YELLOW}If you are planning on deploying SAP HANA, AWS Aurora or any other AWS database, deploy them on the VPC_ID $VPC_ID.${RESET}\n\n"
