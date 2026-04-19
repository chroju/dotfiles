#!/bin/bash
# Mark the tmux window as actively working on a Claude Code task
[ -z "$TMUX" ] && exit 0

WINDOW_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 0

tmux set-window-option -t "$WINDOW_ID" @claude_working 1
tmux set-window-option -t "$WINDOW_ID" @claude_done 0
