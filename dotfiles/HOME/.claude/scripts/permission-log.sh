#!/bin/bash

INPUT=$(cat)
LOG_FILE="$HOME/.claude/permission-log.jsonl"

echo "$INPUT" | jq -c '{
  timestamp: (now | todate),
  tool: .tool_name,
  command: (.tool_input.command // .tool_input // null),
  session_id: .session_id,
  cwd: .cwd
}' >> "$LOG_FILE"

exit 0
