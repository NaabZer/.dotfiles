#!/bin/bash

# Claude Code Picker Launcher
# Calculates focused window index and launches rofi with pre-selection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICKER_SCRIPT="$SCRIPT_DIR/claude_picker.sh"

# Find the focused window's index by running jq query
# Returns the index (0-based) of the focused [cc] window in workspace-sorted order
focused_index=$(i3-msg -t get_tree | jq -r '
    # Recursive function to find windows with their workspace
    def find_windows($ws_num):
        if .window_properties?.class == "Alacritty" or .app_id == "Alacritty" then
            if .name | test("\\[cc\\]"; "i") then
                {ws: $ws_num, focused: .focused}
            else
                empty
            end
        else
            (.nodes[]?, .floating_nodes[]?) | find_windows($ws_num)
        end;

    # Collect all matching windows with their workspace
    [.. | objects | select(.type == "workspace" and .num != null) |
     .num as $ws_num |
     (.nodes[]?, .floating_nodes[]?) | find_windows($ws_num)]
    # Sort by workspace number
    | sort_by(.ws)
    # Find index of focused window
    | to_entries
    | map(select(.value.focused == true))
    | .[0].key // 0
')

# Launch rofi with pre-selected row
rofi -show claude -modi "claude:$PICKER_SCRIPT" -selected-row "${focused_index:-0}" -dpi 82
