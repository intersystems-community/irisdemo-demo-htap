#!/bin/sh

source /ICMDurable/env.sh
source /ICMDurable/base_env.sh
source /ICMDurable/utils.sh

export JAVA_XMX=2048Mb 

if [ ! -f ./.provisionHasBeenRun ];
then
    printf "\n\n${RED}You have not provisioned the infrastructure yet. Run 1) setup.sh, 2) provision.sh and 4) deployiris.sh before running this script.\n\n${RESET}"
    exit 1
fi

printf "\n\n${GREEN}Please, specify which speedtest you want to deploy. Available options are:"
printf "\n\n\t ${YELLOW}iris${RESET}  - InterSystems IRIS"
# printf "\n\n\t ${YELLOW}mysql${RESET} - MySQL/AWSAurora (not implemented)"
printf "\n\n\t ${YELLOW}hana${RESET}  - SAP HANA"
printf "\n\n${RESET}"

read SPEED_TEST_TO_DEPLOY
case $SPEED_TEST_TO_DEPLOY in
    iris)
        printf "\n\n${GREEN}Deploying HTAP demo for InterSystems IRIS...${RESET}\n\n"
        #deploy_for_iris

        deploy "iris" "SpeedTest | InterSystems IRIS"
        break
        ;;
    hana)
        printf "\n\n${GREEN}You must provision SAP HANA Express manually and get its Endpoint."
        printf "\nEnter with SAP HANA's end point:${RESET}\n"

        read HANA_HOSTNAME
        exit_if_empty $HANA_HOSTNAME

        INGESTION_JDBC_URL="jdbc:sap://$HANA_HOSTNAME:39013"
        CONSUMER_JDBC_URL="jdbc:sap://$HANA_HOSTNAME:39013"
        JDBC_USERNAME=SYSTEM
        JDBC_PASSWORD=SAPHANAPassword1

        deploy "hana" "SpeedTest | SAP HANA Express" "$INGESTION_JDBC_URL" "$CONSUMER_JDBC_URL" "$JDBC_USERNAME" "$JDBC_PASSWORD"
        break
        ;;
    mysql)
        break
        ;;
    *)
        printf "\n\n${PURPLE}Exiting.${RESET}\n\n"
        exit 0
        ;;
esac

printf "\n\n${GREEN}Done!${RESET}\n\n"



