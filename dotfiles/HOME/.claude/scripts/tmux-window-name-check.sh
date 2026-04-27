#!/bin/bash

# Check if running inside tmux and window name is the default "claude"
if [ -z "$TMUX" ]; then
  exit 0
fi

WINDOW_NAME=$(tmux display-message -p '#W' 2>/dev/null)
if [ "$WINDOW_NAME" != "claude" ]; then
  exit 0
fi

# Output additionalContext to ask Claude to prompt the user for a window name
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "tmuxのwindow名が「claude」（デフォルト）のままです。会話の最初に `AskUserQuestion` ツールを使ってユーザーへwindow名を何にするか聞き、`tmux rename-window '<name>'` コマンドで設定してください。AskUserQuestionがdeferred toolの場合は先に `ToolSearch` で `select:AskUserQuestion` を呼んでスキーマをロードしてください。"
  }
}
EOF
