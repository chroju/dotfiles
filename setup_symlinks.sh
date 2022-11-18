#!/bin/bash

function make_symlinks() {
    for f in $(ls -A $1); do
	      src="$1/$f"
        dst="$2/$f"
        if [ -f $src ]; then
            if [ -e "$dst" ] && [ "$3" = '-f' ]; then
                echo "### WARN: overwrite $dst ###"
                ln -fs $PWD/$src "$dst"
            elif [ ! -e "$dst" ]; then
                echo "make symlink $dst => $src ..."
                ln -fs $PWD/$src "$dst"
            fi
        elif [ -d $src ]; then
            if [ ! -e "$dst" ]; then
                echo "make directory "$dst" ..."
                mkdir "$dst"
            fi
            make_symlinks $src $2/$f $3
        fi
    done
}

if [ "$1" = '-f' ]; then
  echo '!!! force mode'
fi

make_symlinks dotfiles/HOME $HOME $1
make_symlinks dotfiles/bin /usr/local/bin $1
make_symlinks dotfiles/xbar-plugins "$HOME/Library/Application Support/xbar/plugins" $1

