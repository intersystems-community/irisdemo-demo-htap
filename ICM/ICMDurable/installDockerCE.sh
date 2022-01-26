#!/bin/bash

# general log file for this script
LOG_FILE=$(basename "$0")
LOG_FILE="${LOG_FILE%.*}".log

printf "%s Scriptname running: $0\n" $(date '+%Y%m%d-%H:%M:%S:%N') | tee -a $LOG_FILE

#__checks_____________

if [ -z "$SUDO_USER" ]; then
    export ICM_HOME=$HOME/ICM
else
    export ICM_HOME=$(eval echo ~$SUDO_USER)/ICM
fi
if [ ! -f $ICM_HOME/daemon.json ]; then
    printf "%s Error: File $ICM_HOME/daemon.json not found" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi
if [ ! -f $ICM_HOME/tls/ca.pem ]; then
    printf "%s Error: File $ICM_HOME/tls/ca.pem not found" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi
if [ ! -f $ICM_HOME/tls/server-cert.pem ]; then
    printf "%s Error: File $ICM_HOME/tls/server-cert.pem not found" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi
if [ ! -f $ICM_HOME/tls/server-key.pem ]; then
    printf "%s Error: File $ICM_HOME/tls/server-key.pem not found" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi
if [ -z "$DOCKER_STORAGE_DRIVER" ]; then
    printf "%s Error: DOCKER_STORAGE_DRIVER is null; exiting\n" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi
if [ -f "$ICM_HOME/install_docker.done" ]; then
    printf "%s Skipping: Install Docker\n" $(date '+%Y%m%d-%H:%M:%S:%N') | tee -a $LOG_FILE
    exit 0
fi
printf "%s Installing Docker...\n" $(date '+%Y%m%d-%H:%M:%S:%N') | tee -a $LOG_FILE

#__functions___________________________________________________

function error_exit
{
    if [ $((`echo "${PIPESTATUS[@]}" | tr -s ' ' +`)) -ne 0 ]; then
        printf "%s Error: $1\n" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
        exit 1
    fi
}

# Translate devices for AWS (see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html)
#
# $1      device name
# $result alt device name
function translate_device
{
    for i in {0..99}; do
        devicein=nvme${i}n1
        if [ -e "/dev/$devicein" ]; then
            deviceout=$(sudo /usr/sbin/nvme id-ctrl -v /dev/$devicein | grep -Po '^0000: .*"\K[/,A-Z,a-z,0-9]+')
            if [ "$deviceout" == "$device" ]; then
                eval "$1=$devicein"
                break
            fi
        fi
    done
}

#__the work___________________________________________________

export OS_ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | cut -d\" -f2)
export OS_VER=$(grep ^VERSION= /etc/os-release | cut -d= -f2 | cut -d\" -f2)
if [ "$OS_ID" != "ubuntu" ]; then
    printf "%s Error: Unrecognized OS '$OS_ID'; Docker not installed\n" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi

export DOCKER_CONF_DIR=/etc/systemd/system/docker.service.d
export DOCKER_CONF_FILE=$DOCKER_CONF_DIR/docker.conf
export DOCKER_DAEMON_DIR=/etc/docker
if [ -n "$DOCKER_VER" ]; then
    DOCKER_VER==$DOCKER_VER
fi
DOCKER_REPO=https://download.docker.com/linux/ubuntu
DOCKER_GPG=https://download.docker.com/linux/ubuntu/gpg
LSB_RELEASE=$(lsb_release -cs)

if [ -x "$(command -v docker)" ]; then
    sudo apt-get remove -y docker docker-engine docker.io |& tee -a $LOG_FILE
    error_exit "uninstall docker"
fi

sudo mkdir -p $DOCKER_CONF_DIR |& tee -a $LOG_FILE
error_exit "make directory $DOCKER_CONF_DIR"

sudo tee $DOCKER_CONF_FILE <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=$ICM_HOME/tls/ca.pem --tlscert=$ICM_HOME/tls/server-cert.pem --tlskey=$ICM_HOME/tls/server-key.pem --storage-driver $DOCKER_STORAGE_DRIVER
EOF

sudo mkdir -p $DOCKER_DAEMON_DIR |& tee -a $LOG_FILE
error_exit "make directory $DOCKER_DAEMON_DIR"
sudo cp $ICM_HOME/daemon.json $DOCKER_DAEMON_DIR
error_exit "cp $ICM_HOME/daemon.json $DOCKER_DAEMON_DIR"

# workaround for https://github.com/docker/docker.github.io/pull/3702
maxtries=12
for i in $(seq 1 "$maxtries"); do
    sh -c "sudo apt-get install -y apt-transport-https \
                                   ca-certificates \
                                   gnupg-agent \
                                   software-properties-common \
        && curl -fsSL $DOCKER_GPG | sudo apt-key add - \
        && sudo add-apt-repository \"deb [arch=$(dpkg --print-architecture)] $DOCKER_REPO $LSB_RELEASE stable\" \
        && sudo apt-get update \
        && sudo apt-get install -y docker-ce$DOCKER_VER \
                                   docker-ce-cli$DOCKER_VER \
                                   containerd.io" |& tee -a $LOG_FILE
    if [ $((`echo "${PIPESTATUS[@]}" | tr -s ' ' +`)) -eq 0 ]; then
        break
    fi
    if [ "$i" -le "$maxtries" ]; then
	printf "%s Attempt %d of %d failed\n" $(date '+%Y%m%d-%H:%M:%S:%N') $i $maxtries |& tee -a $LOG_FILE
	sleep 5
    else
        printf "%s Error: Exceeded retry limit; Docker not installed\n" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
        exit 1
    fi
done

sudo systemctl daemon-reload |& tee -a $LOG_FILE
error_exit "reload daemons"
sudo systemctl enable docker |& tee -a $LOG_FILE
error_exit "enable docker"
sudo systemctl start docker |& tee -a $LOG_FILE
error_exit "start docker"
if [ "`docker version`" ]; then
    printf "%s ...installed Docker\n" $(date '+%Y%m%d-%H:%M:%S:%N') | tee -a $LOG_FILE
    touch $ICM_HOME/install_docker.done
else
    printf "%s Error: Docker not installed\n" $(date '+%Y%m%d-%H:%M:%S:%N') |& tee -a $LOG_FILE 1>&2
    exit 1
fi

# set up cron job to restart stuck containers after reboot
(crontab -l 2>/dev/null; echo "* * * * * $ICM_HOME/restartContainers.sh") | crontab -
error_exit "create cron job"

printf "%s Script complete\n" $(date '+%Y%m%d-%H:%M:%S:%N') | tee -a $LOG_FILE

exit 0
