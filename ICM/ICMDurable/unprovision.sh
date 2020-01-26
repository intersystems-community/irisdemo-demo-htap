#!/bin/sh
source /ICMDurable/env.sh
icm unprovision -stateDir /ICMDurable/State -cleanUp

rm -f ./.provisionHasBeenRun
rm -f ./.CNcount