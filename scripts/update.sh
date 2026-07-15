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
header() { echo -e "\n${BOLD}${CYAN}▸ $1${NC}"; echo -e "${DIM}  ─────────────────────────────${NC}"; }

header "System packages"
if [[ "$(uname)" == "Darwin" ]]; then
    brew update && brew upgrade
else
    sudo apt-get update -qq 2>/dev/null || warn "apt update had errors — some repos may be stale (check: apt-get update)"
    sudo apt-get upgrade -y -qq 2>/dev/null || warn "apt upgrade had errors — run: sudo apt --fix-broken install"
fi
log "System packages updated"

header "Dotfiles"
git -C "$HOME/dotfiles" pull --quiet
log "Dotfiles updated"

header "Neovim config"
git -C "$HOME/repositories/init.lua" pull --quiet
log "init.lua updated"

header "Obsidian vault"
git -C "$HOME/obsidian-vault" pull --quiet
log "Obsidian vault updated"

header "Neovim plugins"
nvim --headless -c 'Lazy sync' -c 'qa' 2>/dev/null
log "Neovim plugins updated"

header "Oh My Zsh"
ZSH="$HOME/.oh-my-zsh" command zsh -c 'source $ZSH/oh-my-zsh.sh && omz update --unattended' 2>/dev/null || true
log "Oh My Zsh updated"

header "Agent CLIs"
if command -v claude &>/dev/null; then
    if claude update; then
        log "Claude CLI updated"
    else
        warn "Claude CLI update failed"
    fi
else
    warn "Claude CLI not found, skipping"
fi

if command -v codex &>/dev/null; then
    if codex update; then
        log "Codex CLI updated"
    else
        warn "Codex CLI update failed"
    fi
else
    warn "Codex CLI not found, skipping"
fi

header "npm global packages"
if command -v npm &>/dev/null; then
    npm update -g --silent 2>/dev/null
    log "npm packages updated"
else
    warn "npm not found, skipping"
fi

echo ""
log "Everything up to date!"
