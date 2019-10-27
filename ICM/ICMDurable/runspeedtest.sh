#!/bin/sh
source /ICMDurable/env.sh
icm run -stateDir /ICMDurable/State \
    -machine asamary-CN-IRISSpeedTest-0001 \
    -container htapui \
    -image intersystemsdc/irisdemo-demo-htap:ui-version-1.0