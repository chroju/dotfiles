#!/usr/bin/env bash
set -euo pipefail

sudo chmod 1777 /tmp
sudo chown chroju:chroju /home/chroju/.claude
ln -sf ~/.ssh-agent.sock ~/.bitwarden-ssh-agent.sock

npm i -g @anthropic-ai/claude-code

if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
fi
