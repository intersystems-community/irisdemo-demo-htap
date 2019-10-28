#!/bin/sh

source ./env.sh

case $1 in
    iris)
        icm ssh -interactive -command "bash" --machine ${ICM_LABEL}-DM-IRISSpeedTest-0001
        ;;
    irisbackup)
        icm ssh -interactive -command "bash" --machine ${ICM_LABEL}-DM-IRISSpeedTest-0002
        ;;
    ui)
        icm ssh -interactive -command "bash" --machine ${ICM_LABEL}-CN-IRISSpeedTest-0001
        ;;
    master)
        icm ssh -interactive -command "bash" --machine ${ICM_LABEL}-CN-IRISSpeedTest-0002
        ;;
    worker1)
        icm ssh -interactive -command "bash" --machine ${ICM_LABEL}-CN-IRISSpeedTest-0003
        ;;
    worker2)
        icm ssh -interactive -command "bash" --machine ${ICM_LABEL}-CN-IRISSpeedTest-0004
        ;;
    *)
        echo
        echo "Second parameter must be either: iris, irisbackup, ui, master, worker1 or worker2."
        echo
        ;;
esac