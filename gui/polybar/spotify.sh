#!/bin/bash
scriptpath=$(dirname $0)
scriptpath+="/get_song.sh"

(zscroll -u t -n t -d 0.2 -l 20 -M "playerctl status 2> /dev/null" -m "Paused" "-s f -b ' '"\
    -m "Playing" "-s t -b ' '" "bash  $scriptpath") &
wait
