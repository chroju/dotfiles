#!/bin/bash
# Claude Code の PermissionRequest hook: 承認プロンプトが出る直前に発火し、
# macOS 通知のボタンで許可/拒否を返す。
#
# PreToolUse ではなく PermissionRequest を使う理由: PreToolUse は
# permissions.allow 済みのツールでも毎回発火するので、`ls` のたびに通知が飛ぶ。
# PermissionRequest は本当に承認が要るときだけ発火する。
#
# 前提: 通知のアクションボタンは通知スタイルが「通知パネル」のときだけ出る。
# 「バナー」だとボタンが表示されず、必ずタイムアウトする。
#
# タイムアウト・棄却時は JSON を返さずに終了し、ターミナル側の通常の承認
# プロンプトに委ねる。席を外していても作業が止まるだけで、勝手に許可も拒否も
# しない。

set -u

NTF="$HOME/bin/ntf"
HERDR="$HOME/.local/share/mise/installs/herdr/latest/herdr"
TERMINAL_BUNDLE_ID="com.mitchellh.ghostty"

# 通知を出して待つ秒数。hook 自体の timeout (settings.json 側) はこれより
# 長くしておくこと。短いと hook が先に殺され、押しても反映されない。
WAIT_SEC=240

BODY_MAX_CHARS=200

INPUT=$(jq -c '.' 2>/dev/null) || INPUT='{}'

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""')
SESSION_ID="${SESSION_ID:-unknown}"
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')

# 何を承認しようとしているのか。ツール名と、Bash ならコマンド本体を出す。
# 中身が分からないまま許可を押せてしまうのは危ないので、ここは丁寧に組む。
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')

# 「許可/拒否」で答えられないツールは通知を出さずに通常フローへ委ねる。
# AskUserQuestion は選択肢を選ぶもので、許可しても質問は消えないので無意味。
# matcher に否定は書けないため、ここで弾く。
case "$TOOL" in
  AskUserQuestion) exit 0 ;;
esac
DETAIL=$(
  printf '%s' "$INPUT" | jq -r '
    (.tool_input // {})
    | (.command // .file_path // .path // .url // .pattern // "")
    | tostring
  ' 2>/dev/null
)

if [ -n "$TOOL" ] && [ -n "$DETAIL" ]; then
  BODY="${TOOL}: ${DETAIL}"
elif [ -n "$TOOL" ]; then
  BODY="$TOOL"
else
  BODY="承認が必要です"
fi

# 切り詰めは jq で行う: hook 環境に LANG がないので cut -c はバイト単位になり
# 日本語が壊れる。
BODY=$(
  printf '%s' "$BODY" \
  | jq -Rrs --argjson max "$BODY_MAX_CHARS" '
    gsub("[\r\n\t]"; " ")
    | if (length > $max) then .[:$max] + "…" else . end
  '
)

# subtitle は「プロジェクト名 / 会話の話題」。並列セッションのどれが訊いて
# いるのか、通知だけで分かるようにする。
PROJECT=$(basename "${CWD:-$PWD}")
PANE_ID="${HERDR_PANE_ID:-}"
PANE_TITLE=""
if [ -n "$PANE_ID" ]; then
  PANE_TITLE=$(
    "$HERDR" pane get "$PANE_ID" 2>/dev/null \
    | jq -r '
      (.result.pane.terminal_title_stripped // "")
      | if (length > 50) then .[:50] + "…" else . end
    '
  )
fi
if [ -n "$PANE_TITLE" ]; then
  SUBTITLE="${PROJECT} / ${PANE_TITLE}"
else
  SUBTITLE="$PROJECT"
fi

# 通知を出してボタン押下を待つ。ntf が無い・壊れている場合もここで落ちるが、
# その場合は JSON を返さずに通常フローへ委ねたいので、失敗は握りつぶす。
RESULT=$("$NTF" send \
  --title "承認しますか？" \
  --subtitle "$SUBTITLE" \
  --body "$BODY" \
  --id "claude-approve-${SESSION_ID}" \
  --sound \
  --buttons "許可,拒否" \
  --wait \
  --wait-timeout "$WAIT_SEC" 2>/dev/null) || RESULT=""

ACTION=$(printf '%s' "$RESULT" | jq -r '.action // ""' 2>/dev/null) || ACTION=""
INDEX=$(printf '%s' "$RESULT" | jq -r '.index // -1' 2>/dev/null) || INDEX=-1

# ボタン以外 (タイムアウト・棄却・本体クリック・ntf 不在) は決定を返さない。
# JSON を出さずに exit 0 すると Claude Code は通常の承認フローに進む。
if [ "$ACTION" != "button" ]; then
  # 通知に気づかず放置した場合はターミナルに戻る必要があるので、pane だけ
  # 教えておく。stderr はユーザーに表示される。
  [ "$ACTION" = "timeout" ] && echo "通知の承認がタイムアウトしました (${PANE_ID:-pane不明})" >&2
  exit 0
fi

if [ "$INDEX" = "0" ]; then
  BEHAVIOR="allow"
else
  BEHAVIOR="deny"
fi

jq -nc --arg behavior "$BEHAVIOR" '
  {
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: (
        if $behavior == "allow" then
          { behavior: "allow" }
        else
          { behavior: "deny", message: "通知から拒否されました" }
        end
      )
    }
  }
'
exit 0
