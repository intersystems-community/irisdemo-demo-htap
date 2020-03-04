#!/bin/sh
source ./env.sh

icm unprovision -cleanUp

rm -f ./.provisionHasBeenRun
rm -f ./.CNcount
echo 0 >> .CNcount