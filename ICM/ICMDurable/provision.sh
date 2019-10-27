#!/bin/sh
source /ICMDurable/env.sh

if [ ! -d ./State ]; then
    mkdir ./State
fi

icm provision -stateDir /ICMDurable/State