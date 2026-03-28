#!/bin/bash
# Send bell to tmux via DCS passthrough when running inside tmux
[ -z "$TMUX" ] && exit 0

INPUT=$(jq -c '.' 2>/dev/null || echo '{}')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // ""')
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  MESSAGE=$(grep '"type":"assistant"' "$TRANSCRIPT" | jq -r 'select(.message.content[] | .type == "text") | .message.content[] | select(.type=="text") | .text | .[0:50]' 2>/dev/null | tail -1)
fi
MESSAGE="${MESSAGE:-$(echo "$INPUT" | jq -r '.message // "入力待ち"')}"
WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}' 2>/dev/null)
WTITLE=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)
SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}' 2>/dev/null)
TITLE="Claude Code [${SESSION}:${WINDOW} ${WTITLE}]"

printf '\033Ptmux;\033\033]9;Claude Code\007\033\\' > /dev/tty
osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
