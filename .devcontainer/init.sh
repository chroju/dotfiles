#!/usr/bin/env bash
set -euo pipefail

echo "GH_TOKEN=$(gh auth token)" > .devcontainer/.env.devcontainer

# CLAUDE_CODE_OAUTH_TOKEN must be set manually via `claude setup-token`
# and stored in .devcontainer/.env.devcontainer.local (gitignored)
if [ -f .devcontainer/.env.devcontainer.local ]; then
    cat .devcontainer/.env.devcontainer.local >> .devcontainer/.env.devcontainer
fi

mkdir -p "$HOME/.claude/projects-devcontainer"
mkdir -p "$HOME/.claude/todos-devcontainer"
touch "$HOME/.claude/.credentials-devcontainer.json"
