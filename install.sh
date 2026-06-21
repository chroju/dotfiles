#!/bin/bash
# Devcontainer dotfiles install script.
# Automatically executed by the devcontainer "dotfiles.repository" feature.

cd "$(dirname "$0")"

function make_symlinks() {
    for f in $(ls -A $1); do
        src="$1/$f"
        dst="$2/$f"
        if [ -f $src ]; then
            if [ ! -e "$dst" ]; then
                echo "make symlink $dst => $src ..."
                ln -fs $PWD/$src "$dst"
            fi
        elif [ -d $src ]; then
            if [ ! -e "$dst" ]; then
                echo "make directory $dst ..."
                mkdir "$dst"
            fi
            make_symlinks $src $2/$f
        fi
    done
}

make_symlinks dotfiles/HOME $HOME

sudo chmod 1777 /tmp
sudo chown chroju:chroju "$HOME/.claude"
ln -sf ~/.ssh-agent.sock ~/.bitwarden-ssh-agent.sock

npm i -g @anthropic-ai/claude-code

if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
fi
