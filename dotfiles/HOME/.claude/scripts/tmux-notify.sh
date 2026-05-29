#!/bin/bash
# Notify on Claude Code Notification hook:
#   1) ring tmux bell on the originating pane so window_bell_flag lights up
#   2) post a macOS desktop notification
#
# Requires tmux's `set -g monitor-bell on` + `set -g bell-action any`
# (already in .tmux.conf). macOS notifications need Script Editor's
# notification permission to be enabled in System Settings > Notifications.

[ -z "$TMUX" ] && exit 0

INPUT=$(jq -c '.' 2>/dev/null) || INPUT='{}'

TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""')
HOOK_MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // ""')
NOTIFICATION_TYPE=$(printf '%s' "$INPUT" | jq -r '.notification_type // ""')

MESSAGE=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  MESSAGE=$(
    jq -r '
      select(.type == "assistant")
      | (.message.content // [])
      | map(select(.type == "text") | .text)
      | .[]
    ' "$TRANSCRIPT" 2>/dev/null \
    | tail -1 \
    | tr '\n\r\t' '   ' \
    | cut -c1-80
  )
fi
MESSAGE="${MESSAGE:-${HOOK_MESSAGE:-入力待ち}}"

WINDOW_INDEX=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}' 2>/dev/null)
WINDOW_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)
SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}' 2>/dev/null)

TITLE="CC [${SESSION}:${WINDOW_INDEX} ${WINDOW_NAME}]"
[ -n "$NOTIFICATION_TYPE" ] && TITLE="${TITLE} (${NOTIFICATION_TYPE})"

# Ring the tmux bell by writing BEL directly to the pane's pty.
# send-keys 'C-g' sends a Ctrl+G keystroke (which opens Claude Code's
# external editor), not a BEL character. Use send-keys with a literal
# BEL byte instead.
tmux send-keys -t "$TMUX_PANE" $'\a' 2>/dev/null &

# Desktop notification. Pass strings via argv so embedded quotes /
# backslashes / newlines cannot break the AppleScript.
osascript \
  -e 'on run argv' \
  -e '  display notification (item 2 of argv) with title (item 1 of argv)' \
  -e 'end run' \
  -- "$TITLE" "$MESSAGE" >/dev/null 2>&1 &

exit 0
