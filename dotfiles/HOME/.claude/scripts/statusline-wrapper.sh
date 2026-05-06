#!/bin/bash
# statusLine wrapper: cache rate limits and display statusline.
# Reads stdin once, pipes to rate_limits_cache.sh in background,
# then pipes to statusline.sh for output.

input=$(cat)
echo "$input" | ~/.claude/scripts/rate_limits_cache.sh &
echo "$input" | ~/.claude/scripts/statusline.sh
