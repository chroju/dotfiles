#!/bin/bash
set -eu

# ポップアップを開く前のアクティブpaneを記録（呼び出し元から環境変数で受け取る）
TARGET_PANE="${TARGET_PANE:-}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FILE_LIST=$(git ls-files --cached --others --exclude-standard 2>/dev/null)
else
  FILE_LIST=$(find . -type f -not -path "./.git/*" 2>/dev/null)
fi

SELECTED=$(printf '%s\n' "$FILE_LIST" \
  | fzf --multi --layout=reverse \
        --prompt='@file> ' \
        --header='TAB: 複数選択  ENTER: 確定  ESC: キャンセル' \
        --preview='bat --color=always --style=numbers {}' \
        --preview-window='right:50%:wrap' \
        --bind='ctrl-a:select-all,ctrl-d:deselect-all' \
  2>/dev/null) || true

if [ -n "$SELECTED" ]; then
  AT_FILES=$(printf '%s\n' "$SELECTED" | sed 's/^/@/' | tr '\n' ' ')
  if [ -n "$TARGET_PANE" ]; then
    tmux send-keys -t "$TARGET_PANE" "$AT_FILES"
  else
    tmux send-keys "$AT_FILES"
  fi
fi
