#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Today Scrapbox Diary
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📔

# Documentation:
# @raycast.author chroju
# @raycast.authorURL https://github.com/chroju

datestr=$(date +%Y年%m月%d日（%a）)
open "https://scrapbox.io/chrolog/${datestr}"

