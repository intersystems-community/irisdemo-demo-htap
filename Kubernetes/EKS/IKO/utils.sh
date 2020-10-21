#!/bin/bash

exit_if_error() {
	if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
		echo ""
		echo "ERROR: $1"
		echo ""
		exit 1
	fi
}