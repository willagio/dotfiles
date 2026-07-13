# dotfiles

Personal bootstrap installer for setting up a fresh Linux or macOS machine.

## Quick Start

```bash
git clone https://github.com/willysk73/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

## What It Does

| Script | Description |
|--------|-------------|
| `tools.sh` | Base packages — curl, git, ripgrep, lua, luarocks, tmux, python3, codespell |
| `ssh.sh` | Generates SSH key, adds to GitHub, tests connectivity |
| `git.sh` | Sets name, email, sensible defaults |
| `zsh.sh` | Installs zsh, oh-my-zsh, autosuggestions, syntax highlighting |
| `neovim.sh` | Installs neovim, clones [init.lua](https://github.com/willysk73/init.lua) config, symlinks to `~/.config/nvim` |
| `agents.sh` | Installs Claude and Codex CLIs, symlinks shared skills and instructions |
| `update.sh` | Updates everything — system packages, plugins, repos, oh-my-zsh |

## Usage

```bash
# Full install (first time)
~/dotfiles/install.sh

# Keep everything up to date
update
```

## Structure

```
dotfiles/
├── install.sh              # Main orchestrator
├── config/
│   ├── .zshrc              # Managed zsh config
│   └── claude/
│       └── skills/         # Shared Claude Code and Codex skills
└── scripts/
    ├── tools.sh            # Base apt/brew packages
    ├── ssh.sh              # SSH key setup
    ├── git.sh              # Git config
    ├── zsh.sh              # Zsh + oh-my-zsh + plugins
    ├── neovim.sh           # Neovim + config symlink
    ├── agents.sh           # Claude + Codex CLIs and shared configuration
    └── update.sh           # Update everything
```

## Cross-Platform

All scripts detect the OS and use the appropriate package manager:
- **Linux** — apt
- **macOS** — Homebrew (installed automatically if missing)

## Login Check

On every new shell, a lightweight check runs to verify all tools are present and pull the latest dotfiles. If something is missing, it tells you to re-run `install.sh`.
