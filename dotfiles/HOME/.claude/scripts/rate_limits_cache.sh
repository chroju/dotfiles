#!/bin/bash
set -eu

cache_dir="${TMPDIR:-/tmp}"
cache_file="$cache_dir/claude-rate-limits.json"
tmp_file=$(mktemp "$cache_dir/claude-rate-limits.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT

input=$(cat)

if ! echo "$input" | jq -e '.rate_limits' >/dev/null 2>&1; then
  exit 0
fi

echo "$input" | jq '{
  five_hour: .rate_limits.five_hour.used_percentage,
  five_hour_resets_at: .rate_limits.five_hour.resets_at,
  seven_day: .rate_limits.seven_day.used_percentage,
  seven_day_resets_at: .rate_limits.seven_day.resets_at,
  updated_at: now
}' >"$tmp_file" 2>/dev/null || exit 0

mv "$tmp_file" "$cache_file"
