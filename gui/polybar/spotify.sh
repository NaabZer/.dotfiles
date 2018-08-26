#!/bin/bash
status=`exec playerctl status 2> /dev/null`
if [ "$status" = "Playing" ]; then
  title=`exec playerctl metadata xesam:title`
  artist=`exec playerctl metadata xesam:artist`
  echo " $title - $artist"
elif [ "$status" = "Paused" ]; then
  echo ""
fi
