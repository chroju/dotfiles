#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub Review Requests
# @raycast.mode inline
# @raycast.refreshTime 1m

# Optional parameters:
# @raycast.icon https://i.gyazo.com/6bf4ca15e1cffdedcc22bccb74aa3194.png

# Documentation:
# @raycast.description Show the number of GitHub review requests
# @raycast.author chroju
# @raycast.authorURL https://github.com/chroju

count=$(/usr/local/bin/gh api -X GET search/issues -f q='is:pr is:open review-requested:@me' | jq .total_count)
color=""
if [[ ${count} -gt 1 ]]; then
  color="\\033[33m"
fi
echo -e "${color}You have ${count} review requests\\033[m"
