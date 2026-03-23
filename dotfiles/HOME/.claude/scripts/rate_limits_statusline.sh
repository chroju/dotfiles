#!/bin/bash
input=$(cat)

echo "$input" | jq -r '
  [
    (.rate_limits.five_hour.used_percentage | if . != null then (. | floor | tostring) + "%(5h)" else null end),
    (.rate_limits.seven_day.used_percentage | if . != null then (. | floor | tostring) + "%(7d)" else null end)
  ] | map(select(. != null)) as $parts |
  if ($parts | length) > 0 then
    "Rate limit: " + ($parts | join(" "))
  else
    "Rate limit: N/A"
  end
'
