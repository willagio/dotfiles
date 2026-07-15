#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

# Fonts referenced by ghostty config (macOS only — brew casks)
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
    FONTS=(font-jetbrains-mono-nerd-font font-d2coding)
    missing_fonts=()
    for font in "${FONTS[@]}"; do
        brew list --cask "$font" &>/dev/null || missing_fonts+=("$font")
    done
    if [[ ${#missing_fonts[@]} -gt 0 ]]; then
        echo "Installing fonts: ${missing_fonts[*]}"
        # --force: overwrite font files that were installed manually into
        # ~/Library/Fonts (brew aborts on pre-existing files otherwise)
        brew install --cask --force "${missing_fonts[@]}"
        log "Fonts installed"
    else
        log "Fonts already installed"
    fi
fi

# Symlink ghostty config
CONFIG_SRC="$DOTFILES_DIR/config/ghostty/config"
CONFIG_DST="$HOME/.config/ghostty/config"

if [[ -L "$CONFIG_DST" ]] && [[ "$(readlink "$CONFIG_DST")" == "$CONFIG_SRC" ]]; then
    log "Ghostty config already symlinked"
else
    mkdir -p "$HOME/.config/ghostty"
    [[ -e "$CONFIG_DST" ]] && mv "$CONFIG_DST" "$CONFIG_DST.backup.$(date +%s)"
    ln -sf "$CONFIG_SRC" "$CONFIG_DST"
    log "Ghostty config symlinked: $CONFIG_DST → $CONFIG_SRC"
fi
