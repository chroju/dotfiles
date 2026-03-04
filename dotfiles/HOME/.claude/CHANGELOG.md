# Claude Code Settings Changelog

このファイルは Claude Code のバージョンアップ時に設定を見直した記録を管理する。
`scripts/check-version.sh` が `claude-code-version:` 行を読み取り、バージョン乖離を検出する。

<!-- claude-code-version: 2.1.66 -->

## 2.1.66

4バージョン分の更新（2.1.63〜2.1.66）。

### 主要な新機能

- **`/simplify` スラッシュコマンド追加**: 変更されたコードの再利用性、品質、効率をレビューし修正
- **`/batch` スラッシュコマンド追加**: バッチ処理向けコマンド
- **HTTP hooks**: `type: "http"` でURLにJSON POSTし、JSONレスポンスを受け取る新しいhookタイプ
- **Worktree間で設定・auto memoryを共有**: worktree間の設定同期
- **`ENABLE_CLAUDEAI_MCP_SERVERS=false` 環境変数**: claude.ai側のMCPサーバー（Notion, Figma等）の暗黙的な有効化を無効化
- `/model` コマンドで現在のアクティブモデルを表示
- `/copy` に「Always copy full response」オプション追加
- `/clear` でキャッシュされたスキルがリセットされない問題を修正
- 多数のメモリリーク修正（長時間セッションの安定性向上）
- VSCode: セッションのリネーム・削除アクション追加
- スプリアスなエラーログの削減（2.1.66）

### 設定への影響

- `settings.json`: `env` に `"ENABLE_CLAUDEAI_MCP_SERVERS": "false"` を追加。claude.ai側で設定したMCPサーバーが暗黙的に利用可能になるのを防ぐ
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

## 2.1.62

13バージョン分の更新（2.1.50〜2.1.62）。設定変更なし。

### 主要な新機能

- **自動メモリ**: セッション横断でコンテキストを自動保存。`/memory` コマンドで管理
- **Remote Control**: ローカルセッションをスマホ・タブレット・ブラウザから操作可能（`/remote-control` or `/rc`）
- **Claude Opus 4.6**: 新モデルサポート（1Mコンテキスト対応）
- **Worktree isolation**: エージェントで `isolation: worktree` が使用可能に
- **`/copy` コマンド**: コードブロックのインタラクティブ選択
- **`/rename` コマンド**: 引数なしで会話コンテキストからセッション名を自動生成
- **Ctrl+F**: バックグラウンドエージェントのキル（2回押し確認）
- **Ctrl+B**: フォアグラウンドタスクをバックグラウンドに移行
- **`claude agents` CLI**: 設定済みエージェント一覧表示
- **`claude auth` CLI**: login/status/logout サブコマンド

### 新しいHookイベント

- `WorktreeCreate` / `WorktreeRemove`: worktree作成・削除時
- `ConfigChange`: セッション中の設定ファイル変更時
- `TeammateIdle` / `TaskCompleted`: マルチエージェントワークフロー用
- Stop / SubagentStop hookに `last_assistant_message` フィールド追加

### 新しい設定（オプショナル）

- `spinnerTipsOverride`: スピナーチップのカスタマイズ
- `showTurnDuration`: ターン時間表示の切替
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`: バックグラウンドタスク無効化

### セキュリティ修正

- `statusLine` と `fileSuggestion` フックコマンドがワークスペース信頼なしで実行できた問題を修正（Claude Code側で対応済み）

### 設定への影響

- `settings.json`: 変更なし
- `CLAUDE.md`: 変更なし
- `commands/check-version.md`: 変更なし

## 2.1.49

バグ修正とパフォーマンス改善のみ。設定変更なし。

- Ctrl+C / ESC のバックグラウンドエージェント停止問題を修正
- プロンプトキャッシュのリグレッション修正
- スタートアップパフォーマンス向上

## 2.1.40

初回記録。
