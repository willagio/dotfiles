# Agents

Guidelines for AI agents working on this repository.

## Structure

- `install.sh` — Main orchestrator. Runs each script in `scripts/` in order.
- `scripts/*.sh` — Individual setup scripts. Each is idempotent and can run standalone.
- `config/.zshrc` — Managed zsh config, symlinked to `~/.zshrc`.
- `config/claude/skills/` — Shared Claude Code and Codex skills. The directory is symlinked to `~/.claude/skills/`; each skill is symlinked under `~/.codex/skills/`.

## Conventions

### Scripts

- Every script starts with `set -euo pipefail`.
- Every script defines the same color/log functions:
  ```bash
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'

  log()  { echo -e "  ${GREEN}✓${NC} $1"; }
  warn() { echo -e "  ${YELLOW}!${NC} $1"; }
  ```
- Scripts must be **idempotent** — check before acting, safe to re-run.
- Use `command -v` to check if a tool exists.
- Use `[[ "$(uname)" == "Darwin" ]]` for macOS, `else` for Linux.
- macOS uses `brew`, Linux uses `apt`.
- Use `sudo` only where required (package installs).
- `ssh -T git@github.com` always returns exit code 1 even on success — use `|| true` when capturing output.

### Adding a new script

1. Create `scripts/newscript.sh` with the standard color/log header.
2. Add it to the `for` loop in `install.sh`.
3. Add a label in the `labels` associative array in `install.sh`.

### Adding a new package

Add to the appropriate list in `scripts/tools.sh` — macOS and Linux have separate lists because package names differ.

### Adding a Claude skill

Create `config/claude/skills/<skill-name>/SKILL.md` with YAML frontmatter.

## Related repos

- [willysk73/init.lua](https://github.com/willysk73/init.lua) — Neovim config (LazyVim). Cloned to `~/repositories/init.lua` and symlinked to `~/.config/nvim`.
