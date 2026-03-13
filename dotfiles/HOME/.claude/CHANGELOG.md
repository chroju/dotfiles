# Claude Code Settings Changelog

このファイルは Claude Code のバージョンアップ時に設定を見直した記録を管理する。
`scripts/check-version.sh` が `claude-code-version:` 行を読み取り、バージョン乖離を検出する。

<!-- claude-code-version: 2.1.74 -->

## 2.1.74

### 主要な新機能

- **`/context` コマンド強化**: コンテキスト重いツール、メモリ肥大化、容量警告に最適化提案
- **`autoMemoryDirectory` 設定追加**: auto-memoryの保存先ディレクトリをカスタム指定可能
- **`SessionEnd` hooks タイムアウト設定**: `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` 環境変数で制御可能に（従来は1.5s固定）
- **`--plugin-dir` の優先順位変更**: ローカル開発コピーがマーケットプレイスプラグインより優先

### 主なバグ修正

- ストリーミングAPIレスポンスバッファのメモリリーク修正（RSS無限増加）
- managed policy `ask` ルールが user `allow` やskill `allowed-tools` でバイパスされる問題修正
- Agent frontmatter の `model:` フィールドでフルモデルID（`claude-opus-4-5`等）が無視される問題修正
- MCP OAuth認証のハング・リフレッシュ問題修正
- macOSネイティブバイナリの音声モードマイク権限修正

### 設定への影響

- `settings.json`: 変更なし（`autoMemoryDirectory` はデフォルトで問題なし、`SessionEnd` タイムアウトも現在の軽量hookでは不要）
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

## 2.1.73

### 主要な新機能

- **`modelOverrides` 設定追加**: モデルピッカーのエントリをカスタムプロバイダーのモデルIDにマッピング（Bedrock ARN等）
- **SSL証明書エラー時のガイダンス追加**: 企業プロキシ環境での `NODE_EXTRA_CA_CERTS` 設定案内

### 改善

- Up arrow でプロンプト復元+会話巻き戻しが一括動作に
- IDE検出速度向上、クリップボード画像貼り付けパフォーマンス改善（macOS）
- `/effort` がレスポンス中にも動作可能に
- Bedrock/Vertex/Foundry デフォルトモデルが Opus 4.6 に

### 主なバグ修正

- 複雑なbashコマンドの権限プロンプトで100% CPUループ・フリーズ
- 大量のskillファイル変更時のデッドロック
- サブエージェントの `model: opus/sonnet/haiku` がBedrock/Vertex/Foundryで旧バージョンにダウングレードされる問題
- `/loop` がBedrock/Vertex/Foundry・テレメトリ無効時に使えない問題

### 非推奨

- `/output-style` コマンド廃止 → `/config` に統合

### 設定への影響

- `settings.json`: 変更なし
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

## 2.1.72

### 主要な新機能

- **`/copy` に `w` キー追加**: フォーカス中の選択をファイルに直接書き出し（SSH環境で有用）
- **`/plan` に説明引数追加**: `/plan fix the auth bug` のようにプランモード開始と同時に指示可能
- **`ExitWorktree` ツール追加**: `EnterWorktree` セッションから離脱可能に
- **`CLAUDE_CODE_DISABLE_CRON` 環境変数**: cronジョブの即時停止
- **bash自動承認リスト拡張**: `lsof`, `pgrep`, `tput`, `ss`, `fd`, `fdfind` 追加
- **Agent ツールに `model` パラメータ復活**: エージェント呼び出し時のモデル指定
- **effort レベル簡素化**: low/medium/high（maxを削除）、新シンボル（○ ◐ ●）、`/effort auto` でデフォルトリセット
- **CLAUDE.md HTMLコメント非表示化**: auto-inject時に `<!-- ... -->` が非表示に（Readツールでは表示）

### 主なバグ修正

- 並列ツール呼び出しで Read/WebFetch/Glob 失敗時に兄弟をキャンセルしなくなった（Bashエラーのみカスケード）
- `/clear` がバックグラウンドタスクを kill しなくなった
- ワイルドカード権限ルールが heredoc・改行を含むコマンドにもマッチするよう修正
- プロンプトキャッシュ無効化修正（SDK `query()` で入力トークンコスト最大12倍削減）

### 設定への影響

- `settings.json`: 変更なし
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

## 2.1.71

5バージョン分の更新（2.1.67〜2.1.71）。

### 主要な新機能

- **`/loop` コマンド**: 定期実行（例: `/loop 5m check the deploy`）
- **cron スケジューリングツール**: セッション内での定期プロンプト実行
- **`/claude-api` スキル**: Claude API / Anthropic SDK でのアプリ構築支援
- **`/reload-plugins` コマンド**: プラグイン変更を再起動なしに反映
- **`voice:pushToTalk` キーバインド**: 音声モードのキー設定変更対応
- **`includeGitInstructions` 設定**: ビルトインの commit/PR ワークフロー指示を除去可能
- **`sandbox.enableWeakerNetworkIsolation` 設定**: macOS で `gh` 等がカスタムプロキシ経由で TLS 検証可能に
- **Opus 4.6 デフォルトeffort変更**: Max/Team で medium effort がデフォルトに
- **VSCode spark icon**: セッション一覧、プラン表示、MCP管理ダイアログ

### 新しいHookイベント

- `InstructionsLoaded`: CLAUDE.md やルールファイル読み込み時に発火

### 主なバグ修正

- stdin フリーズ修正
- heredoc コミットメッセージの false-positive permission prompt 修正
- クリップボードの非ASCII文字化け修正
- 大量メモリリーク修正（複数バージョンにわたる）
- `/fork` のプランファイル共有問題修正

### 設定への影響

- `settings.json`: 変更なし
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

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
