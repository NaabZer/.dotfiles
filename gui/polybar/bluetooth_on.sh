#!/bin/sh

if [ "$(bluetoothctl show | grep Powered | grep yes)" = "" ]; then
    exit 1
fi
echo "bluetooth on"
