#!/bin/bash
# Claude Code Picker Launcher — starts at the top row on the "all" tab;
# tiers order each tab's list, and sidebar tabs filter by tier (see below).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICKER_SCRIPT="$SCRIPT_DIR/claude_picker.sh"
# -kb-move-front is cleared because rofi errors on a duplicate keybinding
# when Control+a is also already bound to it; kb-custom-1 is used by
# claude_picker.sh to archive the selected (non-open) session in place.
# -eh 3 matches listing.py's 3-pango-line row layout (title, project/branch,
# note); window width and listview lines are the knobs to tweak if rows
# still feel cramped or the list runs too tall/short for the screen — set
# them in claude_picker.rasi (a dedicated theme that overrides the shared
# theme.rasi), since -theme-str can't win a specificity fight against it.
# -sort -sorting-method fzf is needed because plain -matching fuzzy only
# filters and keeps the script's emission (tier) order, so a scattered-letter
# match like "ccs" ranked equal to an exact substring; fzf scoring re-ranks
# typed filters by match quality while an empty filter still shows the tiers
# untouched.
#
# One rofi mode per tier, switched via -sidebar-mode; each mode is
# `$PICKER_SCRIPT <tier>` (claude_picker.sh's now-required first argv slot --
# see its header comment). The mode display names double as fuzzy-filter
# token reminders (rofi has no jump-to-tab binding, so "(~o)"/"(~r)"/"(~p)"/
# "(~s)" echo listing.py's per-row meta token so a user can still type the
# token instead of switching tabs); the mode-switcher element itself is
# already styled in claude_picker.rasi, so -sidebar-mode just lights it up,
# and Ctrl+h/l plus Shift+Left/Right already switch modes via the user's
# kb-mode-next/kb-mode-previous config.
rofi -show all -sidebar-mode -modi \
    "all:$PICKER_SCRIPT all,open (~o):$PICKER_SCRIPT open,review (~r):$PICKER_SCRIPT review,parked (~p):$PICKER_SCRIPT parked,snoozed (~s):$PICKER_SCRIPT snoozed" \
    -matching fuzzy -sort -sorting-method fzf \
    -selected-row 0 -dpi 82 \
    -kb-custom-1 "Control+a" -kb-move-front "" -eh 3 \
    -theme "$SCRIPT_DIR/claude_picker.rasi"
