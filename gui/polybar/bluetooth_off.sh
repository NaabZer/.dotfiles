#!/bin/sh

if [ "$(bluetoothctl show | grep Powered | grep no)" = "" ]; then
    exit 1
fi
echo "bluetooth off"
