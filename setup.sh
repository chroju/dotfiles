#!/bin/bash
if !(type "brew" > /dev/null 2>&1); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew bundle
ansible-playbook playbook.yml -K

# https://qiita.com/mottox2/items/581869563ce5f427b5f6
cat ./files/vscode/extensions | while read line
do
  code --install-extension $line
done
