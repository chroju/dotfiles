#!/usr/bin/env bash
set -euo pipefail

echo "GH_TOKEN=$(gh auth token)" > .devcontainer/.env.devcontainer
