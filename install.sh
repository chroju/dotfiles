#!/bin/bash

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
