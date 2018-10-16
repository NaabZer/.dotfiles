#!/bin/bash

if [ "$(bluetoothctl info)" != "Missing device address argument" ]; then
    bluetoothctl info | grep Name | cut -f2 | cut -d' ' -f2-
else
    echo "On"
fi
