#!/bin/bash
status=$(playerctl status 2> /dev/null)
youtube=$(playerctl -l | grep youtube)

if [ ! "$status" = "" ] && [ "$youtube" == "" ]; then
    title=`exec playerctl metadata xesam:title`
    artist=`exec playerctl metadata xesam:artist`
    full="$title - $artist"

    echo "$full"
elif [ ! "$youtube" == "" ]; then
    title=`exec playerctl -p "$youtube" metadata xesam:title`
    full="$title"

    echo "$full"
else
    echo ""
fi
