#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

# macOS only
if [[ "$(uname)" != "Darwin" ]]; then
    warn "AeroSpace is macOS only, skipping"
    exit 0
fi

if ! command -v brew &>/dev/null; then
    warn "Homebrew not found, skipping AeroSpace"
    exit 0
fi

if brew list --cask aerospace &>/dev/null; then
    log "AeroSpace already installed"
else
    echo "Installing AeroSpace..."
    brew install --cask nikitabobko/tap/aerospace
    log "AeroSpace installed"
fi

# JankyBorders: focused window highlight (own launchd service, see below)
if brew list --formula borders &>/dev/null; then
    log "borders already installed"
else
    echo "Installing borders..."
    brew install FelixKratz/formulae/borders
    log "borders installed"
fi

# Symlink aerospace config
CONFIG_SRC="$DOTFILES_DIR/config/aerospace/aerospace.toml"
CONFIG_DST="$HOME/.aerospace.toml"

if [[ -L "$CONFIG_DST" ]] && [[ "$(readlink "$CONFIG_DST")" == "$CONFIG_SRC" ]]; then
    log "AeroSpace config already symlinked"
else
    [[ -e "$CONFIG_DST" ]] && mv "$CONFIG_DST" "$CONFIG_DST.backup.$(date +%s)"
    ln -sf "$CONFIG_SRC" "$CONFIG_DST"
    log "AeroSpace config symlinked: $CONFIG_DST → $CONFIG_SRC"
fi

# borders config: sourced by `borders` only when it is launched with no
# arguments, which is how the brew service starts it.
BORDERS_SRC="$DOTFILES_DIR/config/borders/bordersrc"
BORDERS_DST="$HOME/.config/borders/bordersrc"

mkdir -p "$(dirname "$BORDERS_DST")"
if [[ -L "$BORDERS_DST" ]] && [[ "$(readlink "$BORDERS_DST")" == "$BORDERS_SRC" ]]; then
    log "borders config already symlinked"
else
    [[ -e "$BORDERS_DST" ]] && mv "$BORDERS_DST" "$BORDERS_DST.backup.$(date +%s)"
    ln -sf "$BORDERS_SRC" "$BORDERS_DST"
    log "borders config symlinked: $BORDERS_DST → $BORDERS_SRC"
fi

# launchd keeps borders alive independently of AeroSpace, whose
# after-startup-command only fires on app launch.
# `brew services start` only bootstraps the job (and fails if it is already
# loaded); on macOS 26 launchd does not spawn it until kickstarted.
BORDERS_JOB="gui/$(id -u)/sh.brew.borders"
launchctl print "$BORDERS_JOB" &>/dev/null || brew services start borders >/dev/null
launchctl kickstart -k "$BORDERS_JOB"
log "borders service (re)started"
