#!/bin/bash

xcode-select --install || echo "xcode-select --install is alredy done."

if (type "/usr/local/bin/brew" > /dev/null 2>&1); then
  echo "brew (for Rosetta) already installed."
else
  arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# install brew for arm
if (type "/opt/homebrew/bin/brew" > /dev/null 2>&1); then
  echo "brew (for arm) already installed."
else
  mkdir -p /opt/homebrew
  chown -R $(whoami):staff /opt/homebrew
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /opt/homebrew
  /opt/homebrew/bin/brew bundle --file=./Brewfile
fi
