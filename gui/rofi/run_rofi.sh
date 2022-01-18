#!/bin/bash
rofi -modi 'run,window,ssh' -run-list-command ". ~/.config/rofi/alias.sh" -run-command "/bin/bash -i -c '{cmd}'" -dpi 192-dpi 192  -show run
