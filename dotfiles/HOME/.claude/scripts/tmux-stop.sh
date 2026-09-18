#!/bin/bash
# Set a done marker on the tmux window when Claude Code stops
[ -z "$TMUX" ] && exit 0

WINDOW_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 0

tmux set-window-option -t "$WINDOW_ID" @claude_working 0
tmux set-window-option -t "$WINDOW_ID" @claude_since "$(date +%s)"

# Skip setting done marker if this window is currently active
ACTIVE_WINDOW_ID=$(tmux display-message -p '#{window_id}' 2>/dev/null)
if [ "$WINDOW_ID" != "$ACTIVE_WINDOW_ID" ]; then
  tmux set-window-option -t "$WINDOW_ID" @claude_done 1
fi

# Redraw every client's status bar now instead of waiting for status-interval
tmux list-clients -F '#{client_name}' 2>/dev/null | while read -r c; do
  tmux refresh-client -S -t "$c"
done
