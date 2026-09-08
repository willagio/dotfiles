#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }
header() { echo -e "\n${BOLD}${CYAN}▸ $1${NC}"; echo -e "${DIM}  ─────────────────────────────${NC}"; }


echo ""
echo -e "${BOLD}${MAGENTA}  ╔══════════════════════════════════╗${NC}"
echo -e "${BOLD}${MAGENTA}  ║   ${CYAN}Dotfiles Bootstrap Installer${MAGENTA}   ║${NC}"
echo -e "${BOLD}${MAGENTA}  ╚══════════════════════════════════╝${NC}"

label() {
    case "$1" in
        tools.sh)    echo "Base Packages" ;;
        ssh.sh)      echo "SSH Keys" ;;
        git.sh)      echo "Git Config" ;;
        zsh.sh)      echo "Zsh Shell" ;;
        neovim.sh)   echo "Neovim" ;;
        obsidian.sh) echo "Obsidian Vault" ;;
        agents.sh)   echo "Claude + Codex" ;;
        tmux.sh)     echo "Tmux" ;;
        ghostty.sh)  echo "Ghostty" ;;
        aerospace.sh) echo "AeroSpace" ;;
        karabiner.sh) echo "Karabiner-Elements" ;;
        secrets.sh)  echo "Secrets" ;;
    esac
}

for script in tools.sh ssh.sh git.sh zsh.sh neovim.sh obsidian.sh agents.sh tmux.sh ghostty.sh aerospace.sh karabiner.sh secrets.sh; do
    if [[ -f "$SCRIPTS_DIR/$script" ]]; then
        header "$(label "$script")"
        bash "$SCRIPTS_DIR/$script"
    fi
done

echo ""
echo -e "${BOLD}${GREEN}  ╔══════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}  ║         All done! 🎉             ║${NC}"
echo -e "${BOLD}${GREEN}  ╚══════════════════════════════════╝${NC}"
echo -e "  Restart your shell or run: ${BOLD}exec zsh${NC}"
echo ""
