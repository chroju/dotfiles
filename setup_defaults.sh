#!/bin/bash

# Theme
defaults write 'Apple Global Domain' AppleInterfaceStyle Dark

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 1

# Dock
defaults write com.apple.dock autohide 1
defaults write com.apple.dock largesize 128
defaults write com.apple.dock minimize-to-application 1

# https://github.com/VSCodeVim/Vim#mac
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false

# disable spotlight index
mdutil -a -i off
