#!/bin/bash
status=$(playerctl status 2> /dev/null)
youtube=$(playerctl -l | grep youtube)
spotify=$(playerctl -l | grep spotify)
chrome=$(playerctl -l | grep chromium)

# Use different statuses, to have a display order (eg. stopped spotify and playing yt)
if [ ! "$spotify" == "" ]; then
    spotstatus=$(playerctl -p "$spotify" status 2> /dev/null)
fi

if [ ! "$youtube" == "" ]; then
    ytstatus=$(playerctl -p "$youtube" status 2> /dev/null)
fi

if [ ! "$chrome" == "" ]; then
    chstatus=$(playerctl -p "$chrome" status 2> /dev/null)
fi



# TODO: Fix several players
if [ ! "$spotify" == "" ] && [ "$spotstatus" = "Playing" ]; then
    echo "sp"
elif [ ! "$youtube" == "" ] && [ "$ytstatus" = "Playing" ]; then
    echo "yt"
elif [ ! "$chrome" == "" ] && [ "$chstatus" = "Playing" ]; then
    echo "ch"
elif [ "$status" = "Playing" ]; then
    echo "pl"
elif [ "$status" = "Paused" ]; then
    echo "pa"
elif [ "$status" = "Stopped" ]; then
    echo "st"
else
    echo ""
fi
