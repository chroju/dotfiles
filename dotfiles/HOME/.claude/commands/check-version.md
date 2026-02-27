---
description: Claude Codeのバージョン変更を検出し、設定の更新を提案する
allowed-tools: Bash(claude --version), Read, WebSearch, Edit, Write
---

# コンテキスト（自動収集）

- 現在のClaude Codeバージョン: !`claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1`
- 記録されたバージョン: !`grep 'claude-code-version:' ~/.claude/CHANGELOG.md 2>/dev/null | sed 's/.*claude-code-version: \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/' | head -1`

# タスク

上記のバージョンを比較し：

- **同一の場合**: 「バージョンに変更はありません（vX.X.X）」と報告して終了
- **異なる場合**: 以下を実行
  1. WebSearchで Claude Code の新バージョンのリリースノート・変更点を調べる
  2. `~/.claude/settings.json`、`~/.claude/CLAUDE.md`、`~/.claude/commands/` への更新が必要か提案する
  3. 反映後、`~/.claude/CHANGELOG.md` のバージョン番号（`claude-code-version:` コメント）と変更記録を更新する
