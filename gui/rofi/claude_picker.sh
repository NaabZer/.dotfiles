#!/bin/bash

# Claude Code Terminal Picker for Rofi
# Shows Alacritty terminals with [cc] in title, colors [running] green and [waiting] amber
# Uses i3-msg for i3 window manager compatibility

if [ -z "$1" ]; then
    # First call - list Claude Code terminals with pango markup
    echo -en "\x00markup-rows\x1ftrue\n"

    # Get windows from i3, filter for Alacritty with [cc] in name
    # Output format: con_id|window_title
    i3-msg -t get_tree | jq -r '
        recurse(.nodes[]?, .floating_nodes[]?) |
        select(.window_properties?.class == "Alacritty" or .app_id == "Alacritty") |
        select(.name | test("\\[cc\\]"; "i")) |
        "\(.id)|\(.name)"
    ' | while IFS='|' read -r con_id window_title; do
        # Color the status indicators
        if [[ "$window_title" == *"[running]"* ]]; then
            # Green for running - #5dbd70
            colored_title=$(echo "$window_title" | sed "s/\[running\]/<span color='#5dbd70'>[running]<\/span>/g")
        elif [[ "$window_title" == *"[waiting]"* ]]; then
            # Amber for waiting - #e09448
            colored_title=$(echo "$window_title" | sed "s/\[waiting\]/<span color='#e09448'>[waiting]<\/span>/g")
        else
            colored_title="$window_title"
        fi

        # Output the colored title with container ID as metadata
        echo -en "${colored_title}\x00info\x1f${con_id}\n"
    done
else
    # Selection made - focus the window using i3-msg
    i3-msg "[con_id=${ROFI_INFO}] focus" > /dev/null 2>&1
fi
