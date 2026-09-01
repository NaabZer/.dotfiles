#!/bin/bash

# Claude Code session picker for rofi -- backed by `ccs list --rofi`.
# All tiering, glyphs, and meta tokens live in ccs; this script only speaks
# the rofi mode-script protocol and dispatches on selection.
#
# -matching fuzzy is set on the rofi command side (see run_claude_picker.sh /
# the i3 $mod+c keybind), not here.

CCS="$HOME/.claude/session-manager/.venv/bin/ccs"

if [ -z "$1" ]; then
    exec "$CCS" list --rofi
fi

if [ "$ROFI_INFO" = "manage" ]; then
    dunstify "ccs" "fzf manage mode arrives in phase 2"
    exit 0
fi

IFS='|' read -r sid con_id <<< "$ROFI_INFO"

if [ -n "$con_id" ] && [ "$con_id" != "-" ]; then
    i3-msg "[con_id=$con_id] focus" >/dev/null 2>&1
else
    out=$("$CCS" resume "$sid" --spawn 2>&1) || dunstify "ccs resume" "$out"
fi
