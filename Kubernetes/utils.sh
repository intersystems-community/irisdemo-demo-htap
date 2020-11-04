#using part of the util script in ICMDurable

RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

exit_if_empty() {
    if [ -z "$1" ];
    then
        printf "\n\n${PURPLE}Exiting.${RESET}"
        exit 0
    fi
}

exit_if_error() {

	if [ $? -ne 0 ];
	then
		printf "\n\n${RED}"
		echo "ERROR: $1"
		printf "\n\n${RESET}"
		exit 1
	fi
}


wait_pod_ready() {
	echo 1
}