#!/bin/bash
# Claude Code Picker Launcher — starts at the top row; tiers order the list.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICKER_SCRIPT="$SCRIPT_DIR/claude_picker.sh"
rofi -show claude -modi "claude:$PICKER_SCRIPT" -matching fuzzy -selected-row 0 -dpi 82
