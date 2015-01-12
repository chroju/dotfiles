#!/bin/bash

DOT_FILES=(.vimrc .vimperatorrc .tmux.conf .zshrc)
dir=$(cd $(dirname $0);pwd)

for file in ${DOT_FILES[@]}
do
  if [ ! -a $HOME/$file ]; then
    ln -s $dir/$file $HOME/$file
    echo "$file : setup done!"
  fi
done

[ ! -d ~/.vim/bundle ] && mkdir -p ~/.vim/bundle && git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
[ ! -d ~/.vimperator/vimperator-plugins ] && git clone git://github.com/vimpr/vimperator-plugins ~/.vimperator/vimperator-plugins
if [ ! -d ~/.vimperator/plugin ]; then
  mkdir ~/.vimperator/plugin
  ln -s ~/.vimperator/vimperator-plugins/plugin_loader.js ~/.vimperator/plugin/plugin_loader.js
  echo "plugin_loader.js : setup done!"
fi
