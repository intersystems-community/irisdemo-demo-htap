#!/bin/sh

source /ICMDurable/env.sh

rm -rf ${SSH_DIR}
rm -rf ${TLS_DIR}

printf "\n\nGenerating SSH keys on $SSH_DIR:\n"
/ICM/bin/keygenSSH.sh $SSH_DIR

printf "\n\nGenerating TLS keys on $TLS_DIR:\n"
/ICM/bin/keygenTLS.sh $TLS_DIR

printf "\n\nPut your AWS credentials on file credentials.ADFS-PowerUsers"
touch ./credentials.ADFS-PowerUsers