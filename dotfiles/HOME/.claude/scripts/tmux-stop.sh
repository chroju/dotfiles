#!/bin/bash
# Set a done marker on the tmux window when Claude Code stops
[ -z "$TMUX" ] && exit 0

WINDOW_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 0

tmux set-window-option -t "$WINDOW_ID" @claude_working 0

# Skip setting done marker if this window is currently active
ACTIVE_WINDOW_ID=$(tmux display-message -p '#{window_id}' 2>/dev/null)
[ "$WINDOW_ID" = "$ACTIVE_WINDOW_ID" ] && exit 0

tmux set-window-option -t "$WINDOW_ID" @claude_done 1
