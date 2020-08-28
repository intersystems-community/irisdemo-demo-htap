#!/bin/sh
#
# This script will remove all speed test containers (htapmaster, htapui, htapIngestionWorker and htapQueryWorker)
# fromm all CN roles deployed and rest .CNcount to 0 so you can start over with a new speed test deployment.
#
# I used this script to fiddle with env.sh configurations such as HTAP_MASTERS, HTAP_INGESTION_WORKERS, HTAP_QUERY_WORKERS
# and MAX_CN to deploy the speed test more than once with a different number of ingestion workers and query workers
#
# Althought it is normal to get some "SSH operation failed" some times, if you are getting this from ALL machines 
# you should check to see if your AWS token is still valid. You may get it some times when we try to remove a container
# such as htapmaster from a machine where we had an ingestion worker. htapmaster will not exist there and we will just move on.
#

source ./env.sh
source /ICMDurable/utils.sh

remove_all_containers

