#!/bin/bash
status=$(playerctl status 2> /dev/null)
youtube=$(playerctl -l | grep youtube)
spotify=$(playerctl -l | grep spotify)

if [ "$status" = "Playing" ] && [ ! "$spotify" == "" ]; then
    echo "sp"
elif [ "$status" = "Playing" ] && [ ! "$youtube" == "" ]; then
    echo "yt"
elif [ "$status" = "Playing" ]; then
    echo "pl"
elif [ "$status" = "Paused" ]; then
    echo "pa"
elif [ "$status" = "Stopped" ]; then
    echo "st"
else
    echo ""
fi
