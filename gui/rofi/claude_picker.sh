#!/bin/bash

# Claude Code session picker for rofi -- backed by `ccs list --rofi`.
# All tiering, glyphs, and meta tokens live in ccs; this script only speaks
# the rofi mode-script protocol and dispatches on selection.
#
# rofi invokes a script-mode command as `<command> [selection]`, so the tier
# is passed as a required first argv slot baked into the `-modi` spec (see
# run_claude_picker.sh's sidebar tabs, one `$PICKER_SCRIPT <tier>` per tab);
# the selection, if any, is $2.
#
# -matching fuzzy is set on the rofi command side (see run_claude_picker.sh /
# the i3 $mod+c keybind), not here.

CCS="$HOME/.claude/session-manager/.venv/bin/ccs"

TIER="$1"
SELECTION="$2"

if [ -z "$SELECTION" ]; then
    # Initial call: rofi has not yet made a selection (ROFI_RETV=0).
    exec "$CCS" list --rofi --tier "$TIER"
fi

IFS='|' read -r sid con_id <<< "$ROFI_INFO"

# rofi mode-script contract: ROFI_RETV=10 means the custom keybinding
# (Control+a, see run_claude_picker.sh's -kb-custom-1) fired on the
# currently selected row; ROFI_RETV=1 is a normal Enter selection.
if [ "$ROFI_RETV" = "10" ]; then
    if [ "$sid" = "manage" ] || [ -z "$sid" ]; then
        exec "$CCS" list --rofi --tier "$TIER"
    fi

    if [ -n "$con_id" ] && [ "$con_id" != "-" ]; then
        dunstify "ccs" "won't archive an open session"
    else
        out=$("$CCS" state "$sid" archived 2>&1) || dunstify "ccs archive" "$out"
    fi

    # Re-exec so rofi refreshes the listing in place after the archive.
    exec "$CCS" list --rofi --tier "$TIER"
fi

# ROFI_RETV=11 is -kb-custom-2 (Control+o, see run_claude_picker.sh): open
# the selected row's linked PR without closing or refreshing the list.
if [ "$ROFI_RETV" = "11" ]; then
    [ -n "$sid" ] && [ "$sid" != "manage" ] || exit 0
    out=$("$CCS" open-pr "$sid" 2>&1) || dunstify "ccs open-pr" "$out"
    exit 0
fi

if [ "$sid" = "manage" ]; then
    setsid -f "$HOME/.config/rofi/run_ccs_manage.sh" >/dev/null 2>&1
    exit 0
fi

if [ -n "$con_id" ] && [ "$con_id" != "-" ]; then
    i3-msg "[con_id=$con_id] focus" >/dev/null 2>&1
else
    out=$("$CCS" resume "$sid" --spawn 2>&1) || dunstify "ccs resume" "$out"
fi
