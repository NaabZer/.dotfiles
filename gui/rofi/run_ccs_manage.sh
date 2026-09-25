#!/bin/bash
alacritty --class ccs-manage,ccs-manage -T ccs-manage \
    -e "$HOME/.claude/session-manager/.venv/bin/ccs" manage
