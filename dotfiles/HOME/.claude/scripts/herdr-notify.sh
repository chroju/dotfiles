#!/bin/bash
# Claude Code の Notification / Stop hook から macOS 通知を出す。
#
#   Notification (承認・入力待ち) … 音あり
#   Stop         (応答完了)       … 無音
#
# 通知をクリックすると発火元の herdr pane を focus してターミナルを前面化する
# ので、並列セッションでもどれが呼んでいるか探さずに戻れる。
#
# herdr 自身の通知 (config.toml の [ui.toast] delivery) は off にしてある。
# 二重通知になるため、こちらを使うなら off のままにすること。
#
# 使い方: herdr-notify.sh notification | herdr-notify.sh stop

set -u

KIND="${1:-notification}"

# hook の実行環境は PATH が最小限なので、どちらもフルパスで解決する。
NTF="$HOME/bin/ntf"
HERDR="$HOME/.local/share/mise/installs/herdr/latest/herdr"
TERMINAL_BUNDLE_ID="com.mitchellh.ghostty"

# 本文の最大文字数 (バイトではなく文字)。macOS の通知は本文を折り返して数行
# 表示するので、この程度なら省略されずに出る。
BODY_MAX_CHARS=200

INPUT=$(jq -c '.' 2>/dev/null) || INPUT='{}'

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""')
# --id を "claude-" だけにしないための保険。session_id は空文字で来ることも
# あるので、jq の // (null 限定) では拾いきれない。
SESSION_ID="${SESSION_ID:-unknown}"
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
HOOK_MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // ""')
NOTIFICATION_TYPE=$(printf '%s' "$INPUT" | jq -r '.notification_type // ""')
TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""')

# 本文。Notification hook の message は「承認が必要」等の定型文なのでそのまま
# 使い、Stop では最後の応答から「何が終わったか」を取り出す。
#
# 末尾ではなく冒頭を取る: 応答は結論から書くので要点は先頭にあり、末尾は
# 「次は〜します」という作業宣言や補足になりがちで、終了通知の文言として
# 噛み合わない。
#
# 切り詰めは cut ではなく jq で行う: hook の実行環境には LANG がないので
# `cut -c` がバイト単位になり、日本語の途中で切れて文字が壊れる。jq の
# .[:n] は常に文字単位で動くのでロケールに依存しない。
BODY=""
if [ "$KIND" = "stop" ] && [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  BODY=$(
    # 応答ごとに 1 個の JSON 文字列にしてから最後の 1 件を取る。
    # -c で 1 行 1 応答になるので tail -1 が「最後の応答」になる。
    jq -c '
      select(.type == "assistant")
      | (.message.content // [])
      | map(select(.type == "text") | .text)
      | select(length > 0)
      | join("\n")
      | select(. != "")
    ' "$TRANSCRIPT" 2>/dev/null \
    | tail -1 \
    | jq -r --argjson max "$BODY_MAX_CHARS" '
      split("\n")
      # コードブロックの中身は本文にならないので落とす。
      | reduce .[] as $l ({acc: [], code: false};
          if ($l | ltrimstr(" ") | startswith("```")) then
            .code = (.code | not)
          elif .code then .
          else .acc += [$l] end
        )
      | .acc
      | map(gsub("^\\s+|\\s+$"; ""))
      | map(select(length > 0))
      # 見出し・箇条書き・表・引用は結論の文ではないので落とし、地の文だけを
      # 冒頭から順に繋ぐ。1 行だけだと情報が足りないことが多いので、上限まで
      # 使い切る。
      | map(select(startswith("#") | not))
      | map(select(test("^[-*+>|]") | not))
      | map(select(test("^[0-9]+\\.") | not))
      | join(" ")
      # 強調とインラインコードの記号は通知では読みにくいだけなので外す。
      | gsub("\\*\\*"; "") | gsub("`"; "")
      | gsub("[\r\t]"; " ")
      | if (length > $max) then .[:$max] + "…" else . end
    '
  )
fi

if [ "$KIND" = "stop" ]; then
  BODY="${BODY:-完了}"
else
  # Notification の message も、ツール内容が入ると長くなることがあるので
  # 同じ基準で切り詰める。
  BODY=$(
    printf '%s' "${HOOK_MESSAGE:-入力待ち}" \
    | jq -Rrs --argjson max "$BODY_MAX_CHARS" '
      gsub("[\r\n\t]"; " ")
      | if (length > $max) then .[:$max] + "…" else . end
    '
  )
fi

# subtitle でどのセッションが呼んでいるかを示す。並列セッションが多いので
# 「プロジェクト名 / 会話の話題」の形にする: プロジェクト名だけだと同じリポジトリ
# の複数セッションを区別できず、話題だけだとどのリポジトリか分からない。
# 話題 (herdr の pane タイトル) が取れなければプロジェクト名だけになる。
PROJECT=$(basename "${CWD:-$PWD}")

PANE_ID="${HERDR_PANE_ID:-}"
PANE_TITLE=""
if [ -n "$PANE_ID" ]; then
  # ここも cut ではなく jq で切る (BODY と同じくロケール非依存にするため)。
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

[ "$KIND" != "stop" ] && [ -n "$NOTIFICATION_TYPE" ] &&
  SUBTITLE="${SUBTITLE} (${NOTIFICATION_TYPE})"

# クリック時の遷移先。pane が分かるときは focus してから前面化する。
# クリック時の環境は素の GUI セッションなので、フルパスかつ env は使わない。
#
# 引数は配列ではなく set -- で組み立てる: macOS 標準の bash 3.2 では set -u 下の
# "${arr[@]}" が空配列で unbound エラーになる。
if [ -n "$PANE_ID" ]; then
  set -- --execute "$HERDR agent focus $PANE_ID && open -b $TERMINAL_BUNDLE_ID"
else
  set -- --activate "$TERMINAL_BUNDLE_ID"
fi

# 承認待ちだけ音を鳴らす。応答完了は都度出るので無音にしないとうるさい。
[ "$KIND" != "stop" ] && set -- "$@" --sound

# --id はセッション単位。同じセッションの後続イベントが前のバナーを置き換える
# ので、承認待ち → 完了 と積み上がらない。
# ntf が壊れていても hook を妨げてはいけないので出力を捨てて必ず 0 で終わる。
"$NTF" send \
  --title "Claude Code" \
  --subtitle "$SUBTITLE" \
  --body "$BODY" \
  --id "claude-${SESSION_ID}" \
  "$@" >/dev/null 2>&1

exit 0
