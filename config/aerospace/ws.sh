#!/usr/bin/env bash
# Per-monitor workspace switching (komorebi-style).
# Workspaces 1-8 are pinned to the main monitor, 1r-8r to the secondary one.
# usage: ws.sh <1-8> [move]
set -euo pipefail
AERO=/opt/homebrew/bin/aerospace
n="$1"
action="${2:-switch}"

# NSScreen id 1 is always the main display; the secondary set is only used
# when the focused monitor is not main (single-monitor -> always 1-8).
if [[ "$("$AERO" list-monitors --focused --format '%{monitor-appkit-nsscreen-screens-id}')" == "1" ]]; then
    ws="$n"
else
    ws="${n}r"
fi

case "$action" in
    switch) "$AERO" workspace "$ws" ;;
    move)   "$AERO" move-node-to-workspace --focus-follows-window "$ws" ;;
    *) echo "unknown action: $action" >&2; exit 1 ;;
esac
