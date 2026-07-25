#!/bin/bash
# Install gh extensions vendored under dotfiles/gh-extensions/ as local
# (symlinked) extensions. Idempotent: already-installed extensions are
# skipped, so this is safe to re-run.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v gh >/dev/null 2>&1 || { echo "error: required command not found: gh" >&2; exit 1; }

for dir in dotfiles/gh-extensions/gh-*/; do
  dir="${dir%/}"
  name="$(basename "$dir")"
  # gh installs local extensions as symlinks under its data dir; the
  # symlink's existence is the reliable "already installed" signal.
  if [[ -e "${XDG_DATA_HOME:-$HOME/.local/share}/gh/extensions/$name" ]]; then
    echo "$name already installed."
  else
    # Local install only works as "gh extension install ." from inside
    # the extension directory; a path argument is not accepted.
    (cd "$dir" && gh extension install .)
  fi
done
