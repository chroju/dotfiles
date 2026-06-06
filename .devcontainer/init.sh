#!/usr/bin/env bash
set -euo pipefail

echo "GH_TOKEN=$(gh auth token)" > .devcontainer/.env.devcontainer

mkdir -p "$HOME/.claude/projects-devcontainer"
mkdir -p "$HOME/.claude/todos-devcontainer"
