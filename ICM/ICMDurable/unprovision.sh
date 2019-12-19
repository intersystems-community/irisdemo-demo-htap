#!/bin/sh
source /ICMDurable/env.sh
icm unprovision -stateDir /ICMDurable/State

rm -f ./.provisionHasBeenRun