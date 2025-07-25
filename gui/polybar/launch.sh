#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2

if type "xrandr"; then
  #for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
  for m in $(xrandr --listactivemonitors | tail +2 | cut -d" " -f3 | grep -oP '\w*-[\d-]*$'); do
    MONITOR=$m polybar --reload bar &
  done
else
  polybar --reload bar &
fi

echo "Bars launched..."
