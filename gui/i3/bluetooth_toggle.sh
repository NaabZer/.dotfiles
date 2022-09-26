#!/bin/bash

if [ "$(bluetoothctl show | grep Powered | cut -d' ' -f2)" = "yes" ]; then
    bluetoothctl power off
else
    bluetoothctl power on
fi
