#!/bin/bash

xcode-select --install || echo "xcode-select --install is alredy done."

# install brew for arm
if (type "/opt/homebrew/bin/brew" > /dev/null 2>&1); then
  echo "brew (for arm) already installed."
else
  mkdir -p /opt/homebrew
  chown -R $(whoami):staff /opt/homebrew
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /opt/homebrew
  /opt/homebrew/bin/brew bundle --file=./Brewfile
fi
