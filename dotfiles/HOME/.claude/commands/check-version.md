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

以下の公式情報源をWebFetchで直接取得し、記録バージョンから現在バージョンまでの全変更点を調べる：

1. `https://github.com/anthropics/claude-code/releases` — GitHub Releases ページ
2. `https://code.claude.com/docs/en/changelog` — 公式ドキュメントの Changelog

WebFetch で十分な情報が得られない場合のみ、WebSearch をフォールバックとして使用する。

## 2. 変更点の紹介

変更点を日本語でまとめ、各項目について以下の観点で分析する：

### ユーザープロファイル（分析の前提）

- 個人のdotfilesリポジトリで Claude Code を使用
- tmux 上で Claude Code を動作させている
- Ghostty ターミナルを使用
- MCP サーバーを活用している
- カスタムスラッシュコマンド（commands/）を使用
- PreToolUse / PostToolUse / Stop / Notification フックを設定済み
- 個人 Pro サブスクリプションと チーム/Enterprise 契約の両方を使用している
- AWS Bedrock は使用していない
- チーム/Enterprise 向け機能（ポリシー管理、監査、リモート管理等）も評価対象に含める

### 分析フォーマット

各変更項目について以下の形式で説明する：

```
#### <変更名>

**概要**: 何が変わったか（1〜2文）

**どんな場面で役立つか**: この機能が活きる具体的なシナリオ

**このユースケースでの評価**:
- 有用 / 不要 / 要確認 のいずれかを明示
- その理由を簡潔に説明
```

バグ修正については、自分の環境（tmux, Ghostty, MCP, フック）に影響するものを特記する。

## 3. 設定変更の提案

変更点の中で設定への反映が必要なものがあれば提案する（編集対象は dotfiles リポジトリ内のファイル）：

- `<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/settings.json`
- `<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/CLAUDE.md`
- `<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/commands/`

変更が不要な場合は「設定変更は不要」と明示する。

## 4. CHANGELOG の更新

`<dotfilesリポジトリのパス>/dotfiles/HOME/.claude/CHANGELOG.md` のバージョン番号（`claude-code-version:` コメント）を現在のバージョンに更新する。

**記録するのは設定変更のみ**（settings.json / CLAUDE.md / commands/ への実際の変更内容）。Claude Code 自体の新機能・バグ修正は記録しない。設定変更がなければ「設定変更なし」と1行記録する。

記録フォーマット：

```markdown
## <version> (<date>)

### 設定変更

- `<ファイル名>`: <変更内容>

または

- 設定変更なし
```
