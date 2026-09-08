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
    warn "Karabiner-Elements is macOS only, skipping"
    exit 0
fi

if ! command -v brew &>/dev/null; then
    warn "Homebrew not found, skipping Karabiner-Elements"
    exit 0
fi

# Installed either via brew cask or the pkg installer from the website
if [[ -d "/Applications/Karabiner-Elements.app" ]] || brew list --cask karabiner-elements &>/dev/null; then
    log "Karabiner-Elements already installed"
else
    echo "Installing Karabiner-Elements..."
    brew install --cask karabiner-elements
    log "Karabiner-Elements installed"
fi

# Symlink the whole ~/.config/karabiner directory (not just karabiner.json):
# Karabiner watches the parent directory with FSEvents, so a file-level
# symlink into dotfiles never triggers a reload.
CONFIG_SRC="$DOTFILES_DIR/config/karabiner"
CONFIG_DST="$HOME/.config/karabiner"

if [[ -L "$CONFIG_DST" ]] && [[ "$(readlink "$CONFIG_DST")" == "$CONFIG_SRC" ]]; then
    log "Karabiner config dir already symlinked"
else
    mkdir -p "$HOME/.config"
    [[ -e "$CONFIG_DST" ]] && mv "$CONFIG_DST" "$CONFIG_DST.backup.$(date +%s)"
    ln -s "$CONFIG_SRC" "$CONFIG_DST"
    log "Karabiner config dir symlinked: $CONFIG_DST → $CONFIG_SRC"
    # Karabiner keeps watching the old directory until restarted
    launchctl kickstart -k "gui/$(id -u)/org.pqrs.service.agent.Karabiner-Console-User-Server" 2>/dev/null || true
fi

# Korean/English toggle: karabiner.json turns right_command into a 20ms F13 tap;
# bind F13 (keycode 105) to "Select the previous input source" (symbolic hotkey 60).
# Notes from testing on macOS 26:
#  - hotkey 61 ("Select next source in Input menu") does not react to F13 at all.
#  - hotkey 60 fires on key-up and ignores presses held longer than ~350ms,
#    which is why karabiner.json sends a short tap instead of a plain remap.
#  - values must be written as real integers/booleans (XML plist form);
#    the old-style '{ enabled = 1; ... }' syntax stores strings, which macOS
#    silently ignores at the next login.
F13_ON='<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>105</integer><integer>8388608</integer></array><key>type</key><string>standard</string></dict></dict>'
F13_OFF='<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>105</integer><integer>8388608</integer></array><key>type</key><string>standard</string></dict></dict>'
PLIST="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
current_60="$(plutil -p "$PLIST" 2>/dev/null | awk '/"60" =>/,/"type"/' | tr -d ' \n')"
if [[ "$current_60" == *'"enabled"=>true'* && "$current_60" == *'0=>65535'* && "$current_60" == *'1=>105'* ]]; then
    log "F13 already bound to 'Select the previous input source'"
else
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "$F13_ON"
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "$F13_OFF"
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    log "F13 bound to 'Select the previous input source' (hotkey 60)"
fi
