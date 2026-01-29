#!/usr/bin/env bash
set -euo pipefail

# Force screen to wake/refresh before i3lock captures it
xset dpms force on
sleep 0.1  # Brief moment to ensure screen is active
i3lock -B 10 -k -e --pass-media --pass-power --pass-screen
