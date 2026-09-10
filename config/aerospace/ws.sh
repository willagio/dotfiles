#!/usr/bin/env bash
# Per-monitor workspace switching (komorebi-style).
# Workspaces 1-8 are pinned to the main monitor, 1r-8r to the secondary one.
# usage: ws.sh <1-8> [move]
set -uo pipefail
AERO=/opt/homebrew/bin/aerospace
n="$1"
action="${2:-switch}"

count="$("$AERO" list-monitors --count 2>/dev/null)"
if [[ "$count" =~ ^[0-9]+$ ]] && (( count > 1 )); then
    # NSScreen id 1 is always the main display.
    focused="$("$AERO" list-monitors --focused --format '%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)"
    if [[ "$focused" =~ ^[0-9]+$ ]] && (( focused != 1 )); then
        ws="${n}r"
    else
        ws="$n"
    fi
else
    ws="$n"
    # Single monitor: the secondary set is unreachable by key, so fold any
    # windows stranded in <n>r (left over from a dock session) into <n>.
    for id in $("$AERO" list-windows --workspace "${n}r" --format '%{window-id}' 2>/dev/null); do
        "$AERO" move-node-to-workspace --window-id "$id" "$n"
    done
fi

case "$action" in
    switch) "$AERO" workspace "$ws" ;;
    move)   "$AERO" move-node-to-workspace --focus-follows-window "$ws" ;;
    *) echo "unknown action: $action" >&2; exit 1 ;;
esac
