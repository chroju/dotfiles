#!/bin/bash
# PreToolUse(Agent): 汎用エージェントのモデル選択を2段で守る。
#
# 1. model 未指定 → 差し戻す(従来どおり)。
# 2. model 指定あり → jev(TypeSafe System One)にタスクが要求する推論の深さを
#    Score で判定させ、指定モデルの層がそれに足りないときだけ差し戻す。
#    選択基準そのもの(haiku / sonnet / opus の使い分け)は CLAUDE.md と同じ。
#
# jev が使えないとき(TYPESAFE_API_KEY 未設定・ネットワーク不調・429 など)は
# 2 段目を飛ばし、従来どおり「指定があれば通す」に退避する。判定と退避の記録は
# $XDG_STATE_HOME/claude/agent-model-guard.jsonl に1行ずつ残す(しきい値の調整用)。
#
# 差し戻しが無限に続かない理由: 最上位(opus / fable)を指定した呼び出しは jev に
# 問い合わせず必ず通す。Claude は最終的に opus を選べば必ず前に進める。
#
# 環境変数:
#   TYPESAFE_API_KEY             jev の API キー(未設定なら 2 段目なし)
#   TYPESAFE_API_URL             既定 https://api.typesafe.ai/v1/systemone
#   AGENT_MODEL_GUARD_THRESHOLD  「指定より上の層が必要」の確率がこれ以上なら差し戻す(既定 0.7)
set -u

INPUT=$(cat)

# settings.json の matcher が Agent に絞っているが、スクリプト単体でも他ツールの入力は見送る
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')
if [ -n "$TOOL_NAME" ] && [ "$TOOL_NAME" != Agent ]; then
  exit 0
fi

SUBAGENT_TYPE=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // ""')
MODEL=$(printf '%s' "$INPUT" | jq -r '.tool_input.model // "" | ascii_downcase')

# 用途が固定された専用エージェントは定義側の model 指定を尊重して見送る
case "$SUBAGENT_TYPE" in
  ""|claude|general-purpose|fork|Explore|Plan) ;;
  *) exit 0 ;;
esac

# ---- 1 段目: 指定の有無 --------------------------------------------------

if [ -z "$MODEL" ]; then
  cat >&2 <<'EOF'
Agent 呼び出しに model が指定されていません。タスクに要求される推論の深さで選び直してください。

- haiku: 機械的な検索・列挙。grep 相当、ファイル位置の特定、定型の一覧化
- sonnet: 通常の調査・実装。コードを読んで理解する、既知の方針を実装する
- opus: 設計判断、レビュー、成果物の検証ゲート、原因の切り分け

迷ったら opus を選んでください。
EOF
  exit 2
fi

# ---- 2 段目: 指定モデルの層がタスクに足りているか(jev) ---------------------

# fork は親のモデルで動き、model 指定は無視されるので層の判定はしない
[ "$SUBAGENT_TYPE" = fork ] && exit 0

# 指定モデルの層。0 = haiku, 1 = sonnet, 2 = opus / fable
case "$MODEL" in
  *haiku*) GIVEN=0 ;;
  *sonnet*) GIVEN=1 ;;
  *opus*|*fable*) exit 0 ;; # 最上位。これより上はないので必ず通す
  *) exit 0 ;;              # 未知のモデル名は判定しない
esac

API_KEY="${TYPESAFE_API_KEY:-}"
API_URL="${TYPESAFE_API_URL:-https://api.typesafe.ai/v1/systemone}"
THRESHOLD="${AGENT_MODEL_GUARD_THRESHOLD:-0.7}"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
LOG_FILE="$LOG_DIR/agent-model-guard.jsonl"

# 1 行の JSON を記録する。失敗しても hook の結果には影響させない。
log() {
  mkdir -p "$LOG_DIR" 2>/dev/null || return 0
  printf '%s' "$INPUT" | jq -c \
    --arg decision "$1" --arg reason "$2" --argjson jev "${3:-null}" '
    {
      ts: (now | todate),
      session_id: (.session_id // ""),
      subagent_type: (.tool_input.subagent_type // ""),
      model: (.tool_input.model // ""),
      description: (.tool_input.description // ""),
      decision: $decision,
      reason: $reason,
      jev: $jev
    }' >> "$LOG_FILE" 2>/dev/null
  return 0
}

if [ -z "$API_KEY" ]; then
  log pass no_api_key
  exit 0
fi

REQUEST=$(printf '%s' "$INPUT" | jq -c '
  {
    model: "jev-latest",
    state: {
      subagent_type: (.tool_input.subagent_type // ""),
      model: (.tool_input.model // ""),
      description: (.tool_input.description // ""),
      prompt: ((.tool_input.prompt // "") | .[:12000])
    },
    questions: {
      depth: {
        type: "score",
        instructions: "How much reasoning depth does the delegated task in `prompt` require of the subagent? Judge the task itself, not the model named in `model`.",
        criteria: [
          {
            what: "Mechanical search or enumeration: grep-like lookups, locating files or symbols, listing things in a fixed format",
            examples: ["find every call site of a function", "list the files that import a module", "collect the names of all environment variables used"]
          },
          {
            what: "Ordinary investigation or implementation: read code to understand how it works, implement an approach that has already been decided",
            examples: ["implement the endpoint as designed", "explain how module X is wired", "write tests for the agreed behaviour"]
          },
          {
            what: "Design judgment, review, a verification gate on a deliverable, or isolating the cause of a failure",
            examples: ["decide between two approaches", "review this diff for correctness", "verify the acceptance criteria against the running system", "isolate why a test is flaky"]
          }
        ]
      }
    }
  }') || { log pass request_build_failed; exit 0; }

RESPONSE=$(curl -sS --max-time 8 -w '\n%{http_code}' "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H 'Content-Type: application/json' \
  --data "$REQUEST" 2>/dev/null)
CURL_RC=$?
HTTP_CODE=${RESPONSE##*$'\n'}
BODY=${RESPONSE%$'\n'*}

if [ "$CURL_RC" -ne 0 ]; then
  log pass "curl_failed:$CURL_RC"
  exit 0
fi
if [ "$HTTP_CODE" != 200 ]; then
  log pass "http_$HTTP_CODE"
  exit 0
fi

# 指定より上の層に載っている確率の合計、最尤の層、score / confidence
VERDICT=$(printf '%s' "$BODY" | jq -c --argjson given "$GIVEN" '
  .answers.depth as $d
  | ($d.probabilities // {}) as $p
  | {
      p_over: ([$p | to_entries[] | select((.key | tonumber) > $given) | .value] | add // 0),
      likely: (($p | to_entries | max_by(.value) | .key // "0") | tonumber),
      score: ($d.score // null),
      confidence: ($d.confidence // null)
    }' 2>/dev/null)

if [ -z "$VERDICT" ] || [ "$VERDICT" = null ]; then
  log pass unparsable_response
  exit 0
fi

P_OVER=$(printf '%s' "$VERDICT" | jq -r '.p_over')
LIKELY=$(printf '%s' "$VERDICT" | jq -r '.likely')

if ! awk -v p="$P_OVER" -v t="$THRESHOLD" 'BEGIN { exit !(p + 0 >= t + 0) }'; then
  log pass under_threshold "$VERDICT"
  exit 0
fi

log block over_threshold "$VERDICT"

case "$LIKELY" in
  2) NEEDED="opus(設計判断・レビュー・検証ゲート・原因の切り分け)" ;;
  1) NEEDED="sonnet(通常の調査・実装)" ;;
  *) NEEDED="より上の層" ;;
esac
P_PCT=$(awk -v p="$P_OVER" 'BEGIN { printf "%d", p * 100 }')

cat >&2 <<EOF
Agent 呼び出しの model(${MODEL})はタスクに対して軽すぎます。jev の判定では、このタスクに必要なのは ${NEEDED} で、指定より上の層が要る確率は ${P_PCT}% です。

- haiku: 機械的な検索・列挙。grep 相当、ファイル位置の特定、定型の一覧化
- sonnet: 通常の調査・実装。コードを読んで理解する、既知の方針を実装する
- opus: 設計判断、レビュー、成果物の検証ゲート、原因の切り分け

迷ったら opus を選んでください。opus を指定した呼び出しは止まりません。
EOF
exit 2
