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

NVIM_CONFIG="$HOME/.config/nvim"
INIT_LUA_DIR="$HOME/repositories/init.lua"

# Install Neovim v0.13 dev (nightly). On macOS this is the --HEAD build;
# on Linux the neovim-ppa/unstable channel.
if command -v nvim &>/dev/null && nvim --version | head -1 | grep -q 'dev'; then
    log "Neovim dev already installed: $(nvim --version | head -1)"
else
    echo "Installing Neovim (v0.13 dev)..."
    if [[ "$(uname)" == "Darwin" ]]; then
        # --HEAD builds from source; `install --HEAD` errors if a stable keg
        # exists and `reinstall` has no --HEAD, so drop the stable build first.
        brew list neovim &>/dev/null && brew uninstall --ignore-dependencies neovim
        brew install --HEAD neovim
    else
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt-get update -qq
        sudo apt-get install -y -qq neovim
    fi
    log "Neovim installed: $(nvim --version | head -1)"
fi

# Clone init.lua repo if missing
if [[ -d "$INIT_LUA_DIR" ]]; then
    log "init.lua repo already present"
else
    echo "Cloning init.lua config..."
    mkdir -p "$HOME/repositories"
    git clone git@github.com:willysk73/init.lua.git "$INIT_LUA_DIR"
    log "init.lua repo cloned"
fi

# Symlink nvim config
if [[ -L "$NVIM_CONFIG" ]] && [[ "$(readlink "$NVIM_CONFIG")" == "$INIT_LUA_DIR" ]]; then
    log "Neovim config already symlinked"
else
    mkdir -p "$HOME/.config"
    [[ -e "$NVIM_CONFIG" ]] && mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup.$(date +%s)"
    ln -sf "$INIT_LUA_DIR" "$NVIM_CONFIG"
    log "Neovim config symlinked: $NVIM_CONFIG → $INIT_LUA_DIR"
fi

# macism — switches macOS input source from CLI.
# Used by an InsertLeave autocmd in set.lua to force ABC on normal-mode entry,
# avoiding Ghostty's "last composing Hangul char commits on ESC" issue.
if [[ "$(uname)" == "Darwin" ]]; then
    if command -v macism &>/dev/null; then
        log "macism already installed"
    else
        brew tap laishulu/homebrew 2>/dev/null || true
        brew install macism
        log "macism installed"
    fi
fi

# tree-sitter CLI (required by nvim-treesitter main branch)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
if command -v tree-sitter &>/dev/null && tree-sitter --version &>/dev/null 2>&1; then
    log "tree-sitter-cli already installed: $(tree-sitter --version)"
else
    installed=false
    # macOS: prefer Homebrew (no toolchain needed)
    if [[ "$installed" == false ]] && [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
        if brew install tree-sitter-cli 2>/dev/null; then
            if tree-sitter --version &>/dev/null 2>&1; then
                log "tree-sitter-cli installed via brew: $(tree-sitter --version)"
                installed=true
            fi
        fi
    fi

    # Prefer cargo (builds latest, needs libclang-dev)
    if [[ "$installed" == false ]] && command -v cargo &>/dev/null; then
        if cargo install tree-sitter-cli 2>/dev/null; then
            log "tree-sitter-cli installed via cargo: $(tree-sitter --version)"
            installed=true
        fi
    fi

    # Fall back to pre-built binary from GitHub releases
    if [[ "$installed" == false ]] && [[ "$(uname)" == "Linux" ]]; then
        arch=$(uname -m)
        case "$arch" in
            x86_64)  ts_arch="x64" ;;
            aarch64) ts_arch="arm64" ;;
            *)       ts_arch="" ;;
        esac
        if [[ -n "$ts_arch" ]]; then
            mkdir -p "$HOME/.local/bin"
            for ts_ver in "latest/download" "download/v0.25.10"; do
                ts_url="https://github.com/tree-sitter/tree-sitter/releases/${ts_ver}/tree-sitter-linux-${ts_arch}.gz"
                if curl -fsSL "$ts_url" | gunzip > "$HOME/.local/bin/tree-sitter" 2>/dev/null; then
                    chmod +x "$HOME/.local/bin/tree-sitter"
                    if "$HOME/.local/bin/tree-sitter" --version &>/dev/null; then
                        log "tree-sitter-cli installed from GitHub release: $("$HOME/.local/bin/tree-sitter" --version)"
                        installed=true
                        break
                    else
                        rm -f "$HOME/.local/bin/tree-sitter"
                    fi
                fi
            done
        fi
    fi

    # Last resort: npm (may fail on older GLIBC)
    if [[ "$installed" == false ]] && command -v npm &>/dev/null; then
        if npm install -g tree-sitter-cli 2>/dev/null; then
            if tree-sitter --version &>/dev/null 2>&1; then
                log "tree-sitter-cli installed via npm"
                installed=true
            fi
        fi
    fi
    if [[ "$installed" == false ]]; then
        warn "Could not install tree-sitter-cli — nvim-treesitter may not work"
    fi
fi

# redmine-core CLI — required by the redmine.nvim plugin. The lazy spec
# auto-clones the plugin from GitHub; this installs the sibling CLI it
# shells out to. Same install path the redmine.nvim README recommends.
export PATH="$HOME/.local/bin:$PATH"
if command -v redmine &>/dev/null; then
    log "redmine-core CLI already installed: $(redmine --version 2>&1 | head -1)"
else
    if command -v uv &>/dev/null; then
        uv tool install redmine-core
        log "redmine-core CLI installed: $(redmine --version 2>&1 | head -1)"
    else
        warn "uv not found — install redmine-core manually (pipx install redmine-core)"
    fi
fi
