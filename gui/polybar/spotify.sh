#!/bin/bash
scriptpath=$(dirname $0)
scriptpath+="/get_song.sh"

typepath=$(dirname $0)
typepath+="/get_playtype.sh"

(zscroll -u t -n t -d 0.2 -l 30 -M "bash $typepath" -m "pa" "-s f -b ' '"\
    -m "sp" "-s t -b ' '" -m "yt" "-s t -b ' '" -m "ch" "-s t -b ' '" -m "pl" "-s t -b ' '" \
    -m "st" "-s t -b ' '" "bash  $scriptpath") &
wait
