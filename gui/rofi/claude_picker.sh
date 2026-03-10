#!/bin/bash

# Claude Code Terminal Picker for Rofi
# Shows Alacritty terminals with [cc] in title, colors [running] green and [waiting] amber
# Sorted by workspace, highlights focused window
# Uses i3-msg for i3 window manager compatibility

if [ -z "$1" ]; then
    # First call - list Claude Code terminals with pango markup
    echo -en "\x00markup-rows\x1ftrue\n"

    # Get windows from i3 with workspace info and focus state
    # Output format: workspace_num|con_id|focused|window_title
    # Sorted by workspace number
    i3-msg -t get_tree | jq -r '
        # Recursive function to find windows with their workspace
        def find_windows($ws_num):
            if .window_properties?.class == "Alacritty" or .app_id == "Alacritty" then
                if .name | test("\\[cc\\]"; "i") then
                    "\($ws_num)|\(.id)|\(.focused)|\(.name)"
                else
                    empty
                end
            else
                (.nodes[]?, .floating_nodes[]?) | find_windows($ws_num)
            end;

        # Find all workspaces and their windows
        .. | objects | select(.type == "workspace" and .num != null) |
        .num as $ws_num |
        (.nodes[]?, .floating_nodes[]?) | find_windows($ws_num)
    ' | sort -t'|' -k1 -n | while IFS='|' read -r ws_num con_id focused window_title; do
        # Build the display title with workspace prefix
        prefix="[${ws_num}]"

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

        # Highlight focused window with bold and a marker
        if [[ "$focused" == "true" ]]; then
            display="<b>» ${prefix} ${colored_title}</b>"
        else
            display="  ${prefix} ${colored_title}"
        fi

        # Output the colored title with container ID as metadata
        echo -en "${display}\x00info\x1f${con_id}\n"
    done
else
    # Selection made - focus the window using i3-msg
    i3-msg "[con_id=${ROFI_INFO}] focus" > /dev/null 2>&1
fi
