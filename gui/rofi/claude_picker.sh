#!/bin/bash

# Claude Code session picker for rofi -- backed by `ccs list --rofi`.
# All tiering, glyphs, and meta tokens live in ccs; this script only speaks
# the rofi mode-script protocol and dispatches on selection.
#
# -matching fuzzy is set on the rofi command side (see run_claude_picker.sh /
# the i3 $mod+c keybind), not here.
#
# CLAUDE_PICKER_FOCUSED_ID / CLAUDE_PICKER_FOCUSED_INDEX may still be
# exported by run_claude_picker.sh; they are harmless no-ops here now that
# `ccs list --rofi` owns row ordering, so nothing reads them any more.

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
