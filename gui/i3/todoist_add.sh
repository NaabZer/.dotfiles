#!/bin/bash
set -e

TODO=$(rofi -dmenu -yoffset -l 0 -300 -p "Todo:")

if [[ -n $TODO ]]; then
    tod t q -c "$TODO"
    notify-send -a Todoist "Saved Todo: $TODO"
fi
