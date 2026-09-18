#!/bin/bash
# PreToolUse(Agent): 汎用エージェントを model 未指定で起動させない。
# model の妥当性は判定せず「指定されているか」だけを見る。
# 妥当性まで判定すると Claude が何を指定しても弾かれ続ける可能性があるため。
set -u

INPUT=$(cat)

SUBAGENT_TYPE=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // ""')
MODEL=$(printf '%s' "$INPUT" | jq -r '.tool_input.model // ""')

# 用途が固定された専用エージェントは定義側の model 指定を尊重して見送る
case "$SUBAGENT_TYPE" in
  ""|claude|general-purpose|fork|Explore|Plan) ;;
  *) exit 0 ;;
esac

[ -n "$MODEL" ] && exit 0

cat >&2 <<'EOF'
Agent 呼び出しに model が指定されていません。タスクに要求される推論の深さで選び直してください。

- haiku: 機械的な検索・列挙。grep 相当、ファイル位置の特定、定型の一覧化
- sonnet: 通常の調査・実装。コードを読んで理解する、既知の方針を実装する
- opus: 設計判断、レビュー、成果物の検証ゲート、原因の切り分け

迷ったら opus を選んでください。
EOF
exit 2
