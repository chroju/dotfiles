# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for macOS development environment setup. It manages configuration files, shell scripts, and system preferences for a development workstation.

## Setup Commands

### Initial Setup
```bash
# Must be run with sudo
sudo ./setup_defaults.sh      # Configure macOS system defaults
./setup_symlinks.sh           # Create symlinks from dotfiles/HOME to ~
./setup_homebrew.sh           # Install Homebrew and packages from Brewfile
```

### Updating Symlinks
```bash
./setup_symlinks.sh -f        # Force mode - overwrites existing symlinks
```

### Package Management
```bash
brew bundle --file=./Brewfile          # Install/update all packages
brew bundle dump --file=./Brewfile     # Update Brewfile with current packages
```

## Architecture

### Directory Structure

- `dotfiles/HOME/` - Configuration files that symlink to `$HOME`
  - `.zshrc`, `.zshenv` - Zsh shell configuration
  - `.gitconfig` - Git configuration with custom aliases and delta pager
  - `.config/` - Application config files (starship, gh, git, tridactyl, alacritty, ghostty)
  - `.vim/` - Vim configuration
  - `.tmux.conf` - Tmux configuration
  - `.ssh/`, `.gnupg/` - SSH and GPG configurations

- `dotfiles/bin/` - Custom shell scripts that symlink to `/usr/local/bin`
  - `git-*` - Custom git commands (invoked as `git <command>`)
  - `tfallupdate` - Terraform update utility

- `dotfiles/raycast-scripts/` - Raycast extension scripts
- `dotfiles/xbar-plugins/` - xbar plugin scripts (GitHub, Pomodoro)
- `Brewfile` - Homebrew package definitions

### Symlink System

The `setup_symlinks.sh` script recursively creates symlinks:
- Files in `dotfiles/HOME/` → `$HOME/`
- Files in `dotfiles/bin/` → `/usr/local/bin/`
- Files in `dotfiles/xbar-plugins/` → `~/Library/Application Support/xbar/plugins/`

### Git Configuration

Git is configured with:
- SSH signing (not GPG) - `commit.gpgsign = true`, `gpg.format = ssh`
- Delta as the pager with side-by-side diff view
- Custom aliases defined in `.gitconfig:62-95`
- Work-specific config inclusion via `includeIf` for `globis-org` repos
- GitHub CLI as credential helper
- Custom git commands in `dotfiles/bin/git-*`:
  - `git-change` - Check if working tree has changes (used by starship prompt)
  - `git-commit-hash` - Fuzzy find commit hash with fzf
  - `git-copy-hash` - Copy commit hash to clipboard
  - `git-create` - Create new GitHub repo via gh CLI
  - `git-default` - Switch to default branch
  - `git-frebase` - Interactive rebase with fzf commit selection
  - `git-ppush` - Push current branch to origin
  - `git-pppush` - Force push with lease

### Shell Configuration

Zsh configuration includes:
- Starship prompt (configured in `.config/starship.toml`)
- Custom prompt shows git info, kubernetes context, AWS vault
- History with timestamps (100k entries)
- Extensive completion setup with caching
- Auto-loading of tools: fzf, gh, mise (replaces asdf)
- Custom functions:
  - `gcr` - Create new GitHub repo locally
  - `gpr` - Push branch and create PR with gh
  - `git-root` - cd to git repository root
  - `notice` - Terminal notifications
- tenv auto-installs Terraform versions on command execution via TENV_AUTO_INSTALL=true

### Version Management

Uses `mise` (migrated from asdf) for managing tool versions:
- Configured in `.tool-versions`
- Auto-activated in `.zshrc:269`

## Important Notes

### System Defaults
When modifying macOS defaults in `setup_defaults.sh`, test changes manually first with `defaults write` before adding to the script.

### Brewfile Management
- Keep Brewfile alphabetically sorted within each section (brew/cask)
- Use `brew bundle cleanup` to identify packages not in Brewfile

### Git Workflow Specifics
- Default branch is `main` (configured in `.gitconfig:17`)
- Commits must be signed with SSH key
- Pull uses `ff = only` (no merge commits on pull)
- Merge uses `ff = false` (always create merge commit)
- Rebase uses `autostash = true`
- Conflict style is `zdiff3`

### ghq Integration
- Repositories are cloned to `~/dev/src` (configured in `.gitconfig:98`)
- Path structure: `~/dev/src/github.com/<user>/<repo>`
