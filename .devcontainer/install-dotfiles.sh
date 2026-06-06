#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="${HOME}"

symlink() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "symlink $dst => $src"
}

# git
symlink "$REPO_DIR/dotfiles/HOME/.gitconfig" "$HOME_DIR/.gitconfig"
symlink "$REPO_DIR/dotfiles/HOME/.gitmessage" "$HOME_DIR/.gitmessage"
symlink "$REPO_DIR/dotfiles/HOME/.config/git/ignore" "$HOME_DIR/.config/git/ignore"
symlink "$REPO_DIR/dotfiles/HOME/.githooks" "$HOME_DIR/.githooks"

# gh
symlink "$REPO_DIR/dotfiles/HOME/.config/gh/config.yml" "$HOME_DIR/.config/gh/config.yml"

# claude
for f in $(find "$REPO_DIR/dotfiles/HOME/.claude" -not -type d); do
    rel="${f#$REPO_DIR/dotfiles/HOME/}"
    symlink "$f" "$HOME_DIR/$rel"
done
