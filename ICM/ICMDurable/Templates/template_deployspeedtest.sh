#!/bin/sh

source ./env.sh
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
printf "\n\n\t ${YELLOW}aurora${RESET}  - AWS Aurora"
printf "\n\n\t ${YELLOW}sqlserver${RESET}  - AWS RDS SQL Server"

printf "\n\n${RESET}"

read SPEED_TEST_TO_DEPLOY
case $SPEED_TEST_TO_DEPLOY in
    iris)
        printf "\n\n${GREEN}Deploying HTAP demo for InterSystems IRIS...${RESET}\n\n"

        deploy "iris" "SpeedTest | InterSystems IRIS"

        VPC_ID=$(cat ./state/$ICM_LABEL-IRISSpeedTest/terraform.tfstate | grep vpc_id | head -1 | awk -F\" '{print $4}')

        printf "\n\n${YELLOW}If you are planning on deploying SAP HANA, AWS Aurora or any other AWS database, deploy them on the VPC_ID $VPC_ID.${RESET}\n\n"

        break
        ;;
    hana)
        DB_TITLE="SAP HANA Express"
        read_endpoint_and_credentials "$DB_TITLE" "SYSTEM"
        exit_if_error "We need all the information to proceed."

        INGESTION_JDBC_URL="jdbc:sap://$DB_HOSTNAME:39013"
        CONSUMER_JDBC_URL="jdbc:sap://$DB_HOSTNAME:39013"

        deploy "hana" "SpeedTest | $DB_TITLE" "$INGESTION_JDBC_URL" "$CONSUMER_JDBC_URL" "$DB_JDBC_USERNAME" "$DB_JDBC_PASSWORD"
        break
        ;;
    aurora)
        DB_TITLE="AWS Aurora"
        read_endpoint_and_credentials "$DB_TITLE" "admin"
        exit_if_error "We need all the information to proceed."

        INGESTION_JDBC_URL="jdbc:mysql://$DB_HOSTNAME:3306/SpeedTest"
        CONSUMER_JDBC_URL="jdbc:mysql://$DB_HOSTNAME:3306/SpeedTest"

        deploy "mysql" "SpeedTest | $DB_TITLE" "$INGESTION_JDBC_URL" "$CONSUMER_JDBC_URL" "$DB_JDBC_USERNAME" "$DB_JDBC_PASSWORD"
        break
        ;;
    sqlserver)
        DB_TITLE="AWS RDS SQL Server Enterprise 2017"
        read_endpoint_and_credentials "$DB_TITLE" "sa"
        exit_if_error "We need all the information to proceed."

        INGESTION_JDBC_URL="jdbc:sqlserver://$DB_HOSTNAME:1433;DatabaseName=model"
        CONSUMER_JDBC_URL="jdbc:sqlserver://$DB_HOSTNAME:1433;DatabaseName=model"

        deploy "sqlserver" "SpeedTest | $DB_TITLE" "$INGESTION_JDBC_URL" "$CONSUMER_JDBC_URL" "$JDBC_USERNAME" "$JDBC_PASSWORD"
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



