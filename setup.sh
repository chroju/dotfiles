#!/bin/bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew bundle
ansible-playbook playbook.yml -K

# https://qiita.com/mottox2/items/581869563ce5f427b5f6
cat ./files/vscode/extensions | while read line
do
  code --install-extension $line
done
