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

PANE_INFO=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}|#{window_index}|#{window_name}|#{pane_tty}' 2>/dev/null)
SESSION=${PANE_INFO%%|*}; REST=${PANE_INFO#*|}
WINDOW_INDEX=${REST%%|*}; REST=${REST#*|}
WINDOW_NAME=${REST%%|*}
PANE_TTY=${REST#*|}

TITLE="CC [${SESSION}:${WINDOW_INDEX} ${WINDOW_NAME}]"
[ -n "$NOTIFICATION_TYPE" ] && TITLE="${TITLE} (${NOTIFICATION_TYPE})"

# Ring the tmux bell by writing BEL directly to the pane's tty so tmux's
# monitor-bell sees it and sets window_bell_flag.
#   - `printf '\a' > /dev/tty` does NOT work from a hook because the hook
#     has no controlling terminal (Device not configured).
#   - `tmux send-keys $'\a'` also does NOT work: send-keys delivers the
#     BEL byte as keyboard input to the pane process. The process does not
#     echo it back to the tty, so monitor-bell never fires. (`C-g` has the
#     same problem and additionally triggers Claude Code's external editor.)
[ -n "$PANE_TTY" ] && [ -w "$PANE_TTY" ] && printf '\a' > "$PANE_TTY" 2>/dev/null &

# Desktop notification. Pass strings via argv so embedded quotes /
# backslashes / newlines cannot break the AppleScript.
osascript \
  -e 'on run argv' \
  -e '  display notification (item 2 of argv) with title (item 1 of argv)' \
  -e 'end run' \
  -- "$TITLE" "$MESSAGE" >/dev/null 2>&1 &

exit 0
