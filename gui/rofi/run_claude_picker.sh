#!/bin/bash
# Claude Code Picker Launcher — starts at the top row; tiers order the list.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICKER_SCRIPT="$SCRIPT_DIR/claude_picker.sh"
# -kb-move-front is cleared because rofi errors on a duplicate keybinding
# when Control+a is also already bound to it; kb-custom-1 is used by
# claude_picker.sh to archive the selected (non-open) session in place.
rofi -show claude -modi "claude:$PICKER_SCRIPT" -matching fuzzy -selected-row 0 -dpi 82 \
    -kb-custom-1 "Control+a" -kb-move-front ""
