#!/bin/bash

# Claude Code Terminal Picker for Rofi
# Shows Alacritty terminals with [cc] in title, colors [running] green and [waiting] amber
# Sorted by workspace, highlights focused window and windows with open notifications
# Uses i3-msg for i3 window manager compatibility

STATE_DIR="$HOME/.claude/notification-state"

if [ -z "$1" ]; then
    # First call - list Claude Code terminals with pango markup

    # Get windows from i3 with workspace info and focus state
    # Output format: workspace_num|con_id|x11_window_id|focused|window_title
    # Sorted by workspace number
    windows=$(i3-msg -t get_tree | jq -r '
        # Recursive function to find windows with their workspace
        def find_windows($ws_num):
            if .window_properties?.class == "Alacritty" or .app_id == "Alacritty" then
                if .name | test("\\[cc\\]"; "i") then
                    "\($ws_num)|\(.id)|\(.window)|\(.focused)|\(.name)"
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
    ' | sort -t'|' -k1 -n)

    # Build entries
    entries=()
    con_ids=()
    index=0

    while IFS='|' read -r ws_num con_id x11_id focused window_title; do
        [ -z "$ws_num" ] && continue

        # Build the display title with workspace prefix
        prefix="[${ws_num}]"

        # Check if this window has an open notification
        has_notification=false
        if [ -n "$x11_id" ] && [ "$x11_id" != "null" ]; then
            x11_hex=$(printf "0x%x" "$x11_id")
            # Find session key by matching X11 window ID in state files
            session_file=$(grep -l "^${x11_hex}$" "$STATE_DIR"/window_id.* 2>/dev/null | head -1)
            if [ -n "$session_file" ]; then
                session_key="${session_file##*.}"
                if [ -f "$STATE_DIR/notification_id.$session_key" ]; then
                    has_notification=true
                fi
            fi
        fi

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

        # Check if this is the pre-captured focused window (from wrapper env var)
        # or fall back to i3 focus state if wrapper wasn't used
        is_focused=false
        if [[ -n "$CLAUDE_PICKER_FOCUSED_ID" ]]; then
            # Wrapper passed the focused ID - use that
            [[ "$con_id" == "$CLAUDE_PICKER_FOCUSED_ID" ]] && is_focused=true
        else
            # No wrapper - use i3 focus state (may be stale if rofi stole focus)
            [[ "$focused" == "true" ]] && is_focused=true
        fi

        # Build display with focus marker and notification indicator
        if [[ "$is_focused" == "true" ]]; then
            if [[ "$has_notification" == "true" ]]; then
                display="<b>» ${prefix} 🔔; ${colored_title}</b>"
            else
                display="<b>» ${prefix} ${colored_title}</b>"
            fi
        else
            if [[ "$has_notification" == "true" ]]; then
                display="  ${prefix} 🔔; ${colored_title}"
            else
                display="  ${prefix} ${colored_title}"
            fi
        fi

        entries+=("$display")
        con_ids+=("$con_id")
        ((index++))
    done <<< "$windows"

    # Output header with markup and active row styling
    # Use index from wrapper env var to ensure it matches -selected-row
    if [[ -n "$CLAUDE_PICKER_FOCUSED_INDEX" && "$CLAUDE_PICKER_FOCUSED_INDEX" != "-1" ]]; then
        echo -en "\x00markup-rows\x1ftrue\n\x00active\x1f${CLAUDE_PICKER_FOCUSED_INDEX}\n"
    else
        echo -en "\x00markup-rows\x1ftrue\n"
    fi

    # Output all entries
    for i in "${!entries[@]}"; do
        echo -en "${entries[$i]}\x00info\x1f${con_ids[$i]}\n"
    done
else
    # Selection made - focus the window using i3-msg
    i3-msg "[con_id=${ROFI_INFO}] focus" > /dev/null 2>&1
fi
