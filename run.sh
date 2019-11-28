#!/bin/bash
#
# This script is meant to support running the speedtest with docker-compose
#
docker-compose stop
docker-compose rm -f
docker-compose up
