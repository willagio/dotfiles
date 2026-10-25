#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

if [[ "$(uname)" != "Darwin" ]]; then
    warn "gksdud is macOS only, skipping"
    exit 0
fi

if ! command -v brew &>/dev/null; then
    warn "Homebrew not found, skipping gksdud"
    exit 0
fi

if brew list --cask gksdud &>/dev/null; then
    log "gksdud already installed"
else
    brew install --cask --adopt codingnoye/tap/gksdud
    log "gksdud installed"
fi

echo "Open gksdud, grant Accessibility access, and enable Right Command for Korean/English switching."
echo "Enable 'Launch at login' in gksdud to keep it running after restart."
