#!/bin/bash

# Claude Code Picker Launcher
# Captures focused window ID before rofi steals focus, passes to picker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICKER_SCRIPT="$SCRIPT_DIR/claude_picker.sh"

# Capture the focused Claude window's container ID BEFORE rofi steals focus
# Also calculate its index for -selected-row
read -r focused_con_id focused_index < <(i3-msg -t get_tree | jq -r '
    def find_windows($ws_num):
        if .window_properties?.class == "Alacritty" or .app_id == "Alacritty" then
            if .name | test("\\[cc\\]"; "i") then
                "\($ws_num)|\(.id)|\(.focused)"
            else
                empty
            end
        else
            (.nodes[]?, .floating_nodes[]?) | find_windows($ws_num)
        end;
    .. | objects | select(.type == "workspace" and .num != null) |
    .num as $ws_num |
    (.nodes[]?, .floating_nodes[]?) | find_windows($ws_num)
' | sort -t'|' -k1 -n | awk -F'|' '
    BEGIN { idx = 0; focused_id = ""; focused_idx = 0 }
    $3 == "true" { focused_id = $2; focused_idx = idx }
    { idx++ }
    END { print focused_id, focused_idx }
')

# Export the focused container ID and index for the picker script to use
export CLAUDE_PICKER_FOCUSED_ID="${focused_con_id:-}"
export CLAUDE_PICKER_FOCUSED_INDEX="${focused_index:--1}"

# Launch rofi with pre-selected row
rofi -show claude -modi "claude:$PICKER_SCRIPT" -selected-row "${focused_index:-0}" -dpi 82
