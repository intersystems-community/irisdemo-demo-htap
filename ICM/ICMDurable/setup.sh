#!/bin/sh

source /ICMDurable/env.sh

printf "\n\nGenerating SSH keys on $SSH_DIR:\n"
/ICM/bin/keygenSSH.sh $SSH_DIR

printf "\n\nGenerating TLS keys on $TLS_DIR:\n"
/ICM/bin/keygenTLS.sh $TLS_DIR