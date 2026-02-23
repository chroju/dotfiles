#!/usr/bin/env bash

CHANGELOG="$HOME/.claude/CHANGELOG.md"
CURRENT_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
RECORDED_VERSION=$(grep 'claude-code-version:' "$CHANGELOG" 2>/dev/null | sed 's/.*claude-code-version: \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/' | head -1)

if [ -z "$CURRENT_VERSION" ] || [ -z "$RECORDED_VERSION" ]; then
  exit 0
fi

if [ "$CURRENT_VERSION" != "$RECORDED_VERSION" ]; then
  echo "{\"additionalContext\": \"Claude Code のバージョンが変わっています。記録: $RECORDED_VERSION → 現在: $CURRENT_VERSION。\\nWebSearch で Claude Code $CURRENT_VERSION のリリースノートや変更点を調べ、~/.claude/settings.json・CLAUDE.md・commands/ への更新提案を行い、反映後は ~/.claude/CHANGELOG.md のバージョン番号と変更記録を更新してください。\"}"
fi
