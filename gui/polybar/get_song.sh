#!/bin/bash
status=$(playerctl status 2> /dev/null)
spotify=$(playerctl -l | grep spotify)
youtube=$(playerctl -l | grep youtube)
chrome=$(playerctl -l | grep chromium)

if [ ! "$status" = "" ] && [ ! "$spotify" == "" ]; then
    title=`exec playerctl -p "$spotify" metadata xesam:title`
    artist=`exec playerctl -p "$spotify" metadata xesam:artist`
    full="$title - $artist"

    echo "$full"
elif [ ! "$status" = "" ] && ( [ ! "$youtube" == "" ] || [ ! "$chrome" == "" ] ); then
    title=`exec playerctl -p "$youtube" metadata xesam:title`
    full="$title"

    echo "$full"
else
    echo ""
fi
