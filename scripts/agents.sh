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

if command -v claude &>/dev/null; then
    log "Claude CLI already installed"
else
    echo "Installing Claude CLI (native installer)..."
    curl -fsSL https://claude.ai/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    log "Claude CLI installed"
fi

# Make fnm-managed node/npm available (tools.sh installs fnm but PATH doesn't persist across scripts)
if [[ -d "$HOME/.local/share/fnm" ]]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env 2>/dev/null)" || true
fi

if command -v codex &>/dev/null; then
    log "Codex CLI already installed"
else
    echo "Installing Codex CLI..."
    if command -v npm &>/dev/null; then
        npm install -g @openai/codex
    elif command -v bun &>/dev/null; then
        bun install -g @openai/codex
    else
        echo "Neither npm nor bun found — install Node.js first, then re-run"
        exit 1
    fi
    log "Codex CLI installed"
fi

if codex login status &>/dev/null; then
    log "Codex already logged in"
else
    echo "Logging in to Codex (device auth)..."
    codex login --device-auth
    log "Codex login complete"
fi

# Symlink skills
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$DOTFILES_DIR/config/claude/skills"
SKILLS_DST="$HOME/.claude/skills"

if [[ -L "$SKILLS_DST" ]] && [[ "$(readlink "$SKILLS_DST")" == "$SKILLS_SRC" ]]; then
    log "Claude skills already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$SKILLS_DST" ]] && mv "$SKILLS_DST" "$SKILLS_DST.backup.$(date +%s)"
    ln -sf "$SKILLS_SRC" "$SKILLS_DST"
    log "Claude skills symlinked: $SKILLS_DST → $SKILLS_SRC"
fi

CODEX_SKILLS_DST="$HOME/.codex/skills"
mkdir -p "$CODEX_SKILLS_DST"

for skill_src in "$SKILLS_SRC"/*; do
    [[ -d "$skill_src" ]] || continue
    skill_name="$(basename "$skill_src")"
    skill_dst="$CODEX_SKILLS_DST/$skill_name"

    if [[ -L "$skill_dst" ]] && [[ "$(readlink "$skill_dst")" == "$skill_src" ]]; then
        log "Codex skill already symlinked: $skill_name"
    else
        [[ -e "$skill_dst" ]] && mv "$skill_dst" "$skill_dst.backup.$(date +%s)"
        ln -sf "$skill_src" "$skill_dst"
        log "Codex skill symlinked: $skill_dst → $skill_src"
    fi
done

# Symlink agents
AGENTS_SRC="$DOTFILES_DIR/config/claude/agents"
AGENTS_DST="$HOME/.claude/agents"

if [[ -L "$AGENTS_DST" ]] && [[ "$(readlink "$AGENTS_DST")" == "$AGENTS_SRC" ]]; then
    log "Claude agents already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$AGENTS_DST" ]] && mv "$AGENTS_DST" "$AGENTS_DST.backup.$(date +%s)"
    ln -sf "$AGENTS_SRC" "$AGENTS_DST"
    log "Claude agents symlinked: $AGENTS_DST → $AGENTS_SRC"
fi

# Symlink settings.json
SETTINGS_SRC="$DOTFILES_DIR/config/claude/settings.json"
SETTINGS_DST="$HOME/.claude/settings.json"

if [[ -L "$SETTINGS_DST" ]] && [[ "$(readlink "$SETTINGS_DST")" == "$SETTINGS_SRC" ]]; then
    log "Claude settings already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$SETTINGS_DST" ]] && mv "$SETTINGS_DST" "$SETTINGS_DST.backup.$(date +%s)"
    ln -sf "$SETTINGS_SRC" "$SETTINGS_DST"
    log "Claude settings symlinked: $SETTINGS_DST → $SETTINGS_SRC"
fi

# Symlink CLAUDE.md (global instructions)
CLAUDEMD_SRC="$DOTFILES_DIR/config/claude/CLAUDE.md"
CLAUDEMD_DST="$HOME/.claude/CLAUDE.md"

if [[ -L "$CLAUDEMD_DST" ]] && [[ "$(readlink "$CLAUDEMD_DST")" == "$CLAUDEMD_SRC" ]]; then
    log "Claude CLAUDE.md already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$CLAUDEMD_DST" ]] && mv "$CLAUDEMD_DST" "$CLAUDEMD_DST.backup.$(date +%s)"
    ln -sf "$CLAUDEMD_SRC" "$CLAUDEMD_DST"
    log "Claude CLAUDE.md symlinked: $CLAUDEMD_DST → $CLAUDEMD_SRC"
fi

# Symlink lang/ (per-language conventions referenced by CLAUDE.md)
LANG_SRC="$DOTFILES_DIR/config/claude/lang"
LANG_DST="$HOME/.claude/lang"

if [[ -L "$LANG_DST" ]] && [[ "$(readlink "$LANG_DST")" == "$LANG_SRC" ]]; then
    log "Claude lang/ already symlinked"
else
    mkdir -p "$HOME/.claude"
    [[ -e "$LANG_DST" ]] && mv "$LANG_DST" "$LANG_DST.backup.$(date +%s)"
    ln -sf "$LANG_SRC" "$LANG_DST"
    log "Claude lang/ symlinked: $LANG_DST → $LANG_SRC"
fi

# Symlink CLAUDE.md to ~/.codex/AGENTS.md (codex/aider/cursor compat)
CODEX_AGENTS_DST="$HOME/.codex/AGENTS.md"

if [[ -L "$CODEX_AGENTS_DST" ]] && [[ "$(readlink "$CODEX_AGENTS_DST")" == "$CLAUDEMD_SRC" ]]; then
    log "Codex AGENTS.md already symlinked"
else
    mkdir -p "$HOME/.codex"
    [[ -e "$CODEX_AGENTS_DST" ]] && mv "$CODEX_AGENTS_DST" "$CODEX_AGENTS_DST.backup.$(date +%s)"
    ln -sf "$CLAUDEMD_SRC" "$CODEX_AGENTS_DST"
    log "Codex AGENTS.md symlinked: $CODEX_AGENTS_DST → $CLAUDEMD_SRC"
fi

# Install Context7 MCP server (real-time library docs — combats LLM hallucination
# of stale APIs in fast-moving AI/ML SDKs). User scope = all sessions on this machine.
if claude mcp list 2>/dev/null | grep -q "^context7:"; then
    log "Context7 MCP already configured"
else
    if command -v npx &>/dev/null; then
        claude mcp add -s user context7 -- npx -y @upstash/context7-mcp
        log "Context7 MCP added (user scope)"
    else
        warn "npx not found — skipping Context7 MCP install"
    fi
fi
