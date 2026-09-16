#!/usr/bin/env bash
set -euo pipefail

# <xbar.title>AeroSpace Stack</xbar.title>
# <xbar.desc>Current workspace and stack; select a window to focus it.</xbar.desc>
# <swiftbar.runInBash>false</swiftbar.runInBash>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
unset AEROSPACE_WINDOW_ID AEROSPACE_WORKSPACE
exec osascript -l JavaScript "$HOME/dotfiles/config/aerospace/menu.js"
