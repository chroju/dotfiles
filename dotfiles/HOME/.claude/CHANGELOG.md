# Claude Code Settings Changelog

このファイルは Claude Code のバージョンアップ時に設定を見直した記録を管理する。
`scripts/check-version.sh` が `claude-code-version:` 行を読み取り、バージョン乖離を検出する。

<!-- claude-code-version: 2.1.62 -->

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
