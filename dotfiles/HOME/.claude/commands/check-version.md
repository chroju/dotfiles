---
description: Claude Codeのバージョン変更を検出し、設定の更新を提案する
allowed-tools: Bash(claude --version), Read, WebFetch, WebSearch, Edit, Write
---

# コンテキスト（自動収集）

- 現在のClaude Codeバージョン: !`claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1`
- 記録されたバージョン: !`grep 'claude-code-version:' ~/.claude/CHANGELOG.md 2>/dev/null | sed 's/.*claude-code-version: \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/' | head -1`
- dotfilesリポジトリのパス: !`echo ~/dev/src/github.com/chroju/dotfiles`

# タスク

上記のバージョンを比較し：

- **同一の場合**: 「バージョンに変更はありません（vX.X.X）」と報告して終了
- **異なる場合**: 以下を実行

## 1. リリースノートの確認

以下の公式情報源をWebFetchで直接取得し、該当バージョンの変更点を調べる：

1. `https://github.com/anthropics/claude-code/releases` — GitHub Releases ページ
2. `https://code.claude.com/docs/en/changelog` — 公式ドキュメントの Changelog

WebFetch で十分な情報が得られない場合のみ、WebSearch をフォールバックとして使用する。

## 2. 設定の更新提案

変更点を分析し、以下のファイルへの更新が必要か提案する（編集対象は dotfiles リポジトリ内のファイル）：

- `<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/settings.json`
- `<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/CLAUDE.md`
- `<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/commands/`

## 3. CHANGELOG の更新

反映後、`<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/CHANGELOG.md` のバージョン番号（`claude-code-version:` コメント）と変更記録を更新する。
