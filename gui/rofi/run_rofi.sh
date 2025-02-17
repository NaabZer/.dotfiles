#!/bin/bash
#rofi -modi 'run,window,ssh' -run-list-command ". ~/.config/rofi/alias.sh" -run-command "/bin/bash -i -c '{cmd}'" -dpi 192-dpi 192  -show run
rofi -modi 'drun,window,ssh,run' -run-list-command ". ~/.config/rofi/alias.sh" -run-command "/bin/bash -i -c '{cmd}'" -dpi 82  -show drun
