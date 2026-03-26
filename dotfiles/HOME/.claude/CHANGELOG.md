# Claude Code Settings Changelog

このファイルは Claude Code のバージョンアップ時に設定を見直した記録を管理する。
`scripts/check-version.sh` が `claude-code-version:` 行を読み取り、バージョン乖離を検出する。

<!-- claude-code-version: 2.1.84 -->

## 2.1.84 (2026-03-26)

### 新機能

- **PowerShell tool (Windows opt-in preview)**: Windows環境向け。macOSでは不要
- **モデル機能検出の環境変数オーバーライド**: `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_SUPPORTS`、`_MODEL_NAME`、`_DESCRIPTION` で3pプロバイダー（Bedrock, Vertex, Foundry）のモデルラベル・機能をカスタマイズ
- **`CLAUDE_STREAM_IDLE_TIMEOUT_MS` 環境変数**: ストリーミングアイドル監視タイムアウト設定（デフォルト90秒）
- **`TaskCreated` hook**: `TaskCreate` でタスク作成時に発火
- **`WorktreeCreate` hook の `type: "http"` サポート**: `hookSpecificOutput.worktreePath` でworktreeパスを返却可能
- **`allowedChannelPlugins` managed setting**: チーム/Enterprise向けプラグイン許可リスト
- **`x-client-request-id` APIリクエストヘッダー**: タイムアウトデバッグ用
- **75分アイドル後の `/clear` 推奨プロンプト**: トークン再キャッシュ削減
- **Deep link (`claude-cli://`) が優先ターミナルで開く**
- **Rules/skills `paths:` がYAMLリスト形式のglobを受け付け**: `.claude/rules/` で複数パターン指定可能に

### 改善

- MCP tool description / server instructions を2KBに制限（コンテキスト肥大化防止）
- MCP サーバー重複排除（ローカル設定が claude.ai コネクタに優先）
- トークンカウント ≥1M を "1.5m" 形式で表示
- `ToolSearch` 有効時のグローバルシステムプロンプトキャッシュ対応
- ~30ms 起動改善（並列 `setup()` 実行）
- Issue/PR参照が `owner/repo#123` 形式のみクリック可能に（裸の `#123` は自動リンクされない）
- 利用不可スラッシュコマンド (`/voice`, `/mobile` 等) が非表示に

### バグ修正

- Voice push-to-talk のテキスト入力リーク
- `Ctrl+U`（行頭まで削除）の複数行入力での動作
- chord binding の null アンバインド
- ワークフローサブエージェントの `--json-schema` 使用時 400 エラー
- IME (CJK入力) のインライン描画・カーソル追跡（日本語入力の改善）
- MCP tool/resource キャッシュリーク（再接続時）
- Partial clone リポジトリ (Scalar/GVFS) の起動パフォーマンス
- macOS keychain の一時的読み取り失敗
- Deferred tools のコールドスタート競合（Edit/Write失敗防止）
- 大ファイル添付スニペット生成ハング

### 設定変更

- `settings.json`: 変更なし
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

## 2.1.83 (2026-03-25)

2.1.82〜2.1.83 の更新。

### 新機能

- **`managed-settings.d/` ドロップインディレクトリ**: 複数チーム向けポリシー断片をアルファベット順マージ
- **`CwdChanged` / `FileChanged` hook イベント**: direnv 等の環境管理向け
- **`sandbox.failIfUnavailable` 設定**: サンドボックス起動失敗時にエラー終了（サイレント無効化を防止）
- **`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` 環境変数**: サブプロセスから Anthropic / クラウドプロバイダー認証情報を除去
- **トランスクリプト検索**: `Ctrl+O` → `/` で検索、`n`/`N` でステップ移動
- **`Ctrl+X Ctrl+E`**: 外部エディタ起動のエイリアス（`Ctrl+G` と同等）
- **貼り付け画像 `[Image #N]` チップ**: 画像を位置参照可能に
- **Agent `initialPrompt` frontmatter**: エージェント起動時の初回ターンを自動送信
- **`chat:killAgents` / `chat:fastMode` キーバインド**: `~/.claude/keybindings.json` でカスタマイズ可能に
- **プラグイン `manifest.userConfig`**: プラグイン有効化時にユーザー設定を要求可能（`sensitive: true` は Keychain 保存）

### 改善

- `Ctrl+F` → `Ctrl+X Ctrl+K` に変更（バックグラウンドエージェント全停止。readline forward-char との衝突回避）
- `TaskOutput` ツール非推奨化（`Read` で代替）
- `Ctrl+L` で画面クリア＋再描画、`Ctrl+U` / double-Esc で入力クリア
- `Ctrl+B` はアイドル時の readline backward-char を妨害しなくなった
- MEMORY.md 上限: 200行 + 25KB
- `--bare -p` が約14%高速化
- Bedrock SDK コールドスタートレイテンシ改善
- `--resume` メモリ使用量・起動レイテンシ改善
- non-streaming fallback トークン上限 21k → 64k、タイムアウト 120s → 300s
- `/status` がレスポンス中にも動作可能に
- WebFetch UA を `Claude-User` に変更（robots.txt でのアクセス制御対応）
- `--channels` アクティブ時に `AskUserQuestion` / プランモードツール無効化

### バグ修正

- `caffeinate` プロセスが終了せず Mac スリープを阻害する問題
- macOS 終了時ハング
- 大ファイル diff のハング（5秒タイムアウト追加）
- Voice 入力の音声モジュール遅延読み込みによる1-8秒 UI フリーズ
- claude.ai MCP 設定フェッチによる起動3秒遅延
- `--mcp-config` が managed policy を迂回する問題
- claude.ai MCP コネクタが `--print` モードで使えない問題
- バックグラウンドエージェントがコンパクション後に不可視になる問題
- ツール結果ファイルの `cleanupPeriodDays` 未適用
- マウストラッキングエスケープシーケンスのリーク
- 多数の UI / スクロール / Remote Control 修正

### 設定変更

- `settings.json`: `env` に `"CLAUDE_CODE_SUBPROCESS_ENV_SCRUB": "1"` を追加（サブプロセスから認証情報を除去する防御的セキュリティ設定）
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

## 2.1.81 (2026-03-20)

### 新機能

- **`--bare` フラグ**: スクリプト向け `-p` 呼び出しで hooks/LSP/plugin 同期をスキップ（API キー必須）
- **`--channels` permission relay**: チャンネルサーバーがツール承認プロンプトを電話へ転送
- **Remote Control**: セッション再開時のワークツリー切り替え改善
- **行単位レスポンスストリーミング**（Windows/WSL では無効）
- **MCP OAuth**: Client ID Metadata Document（CIMD / SEP-991）サポート

### バグ修正

- 複数セッションで OAuth 再認証が繰り返し要求される問題
- Voice mode retry 失敗と WebSocket ドロップ
- プラグインディレクトリ削除時にプラグイン hook がプロンプト送信をブロックする問題
- バックグラウンドエージェントタスク出力のレースコンディション
- Node.js 18 互換性クラッシュ
- ダッシュ付き Bash コマンドへの不要なパーミッションプロンプト

### 設定変更

なし

## 2.1.80 (2026-03-19)

### 新機能

- **statusline `rate_limits` フィールド**: Claude.ai レート制限使用量を statusline に表示可能
- **`source: 'settings'` プラグインマーケットプレイス**: `settings.json` 内にインラインでマーケットプレイス定義を記述できる（別リポジトリ不要。各プラグイン本体は GitHub 等を参照）
- **CLI ツール使用検出によるプラグインヒント**
- **`effort` frontmatter**: スキル/スラッシュコマンドで thinking effort を指定可能
- **`--channels` research preview**: MCP サーバーがセッションへメッセージをプッシュ

### バグ修正

- `--resume` でパラレルツール結果が欠落する問題
- Cloudflare ボット検出による Voice mode WebSocket 失敗
- API プロキシ経由のファインゲインドツールストリーミングで 400 エラー
- キャッシュ済み設定でのマネージド設定が起動時に未適用になる問題
- 大規模リポジトリでのファイル自動補完レスポンス改善
- 起動時のメモリ使用量 ~80MB 削減

### 設定変更

なし（プラグイン未使用のため `source: 'settings'` は不要）

## 2.1.79

5バージョン分の更新（2.1.75〜2.1.79）。

### 主要な新機能

- **Opus 4.6 1Mコンテキスト**: Max/Team/Enterprise でデフォルト有効 (2.1.75)
- **Opus 4.6 出力トークン上限引き上げ**: デフォルト64k、上限128k (2.1.77)
- **MCP elicitation**: MCPサーバーがタスク中に構造化入力を要求可能 (2.1.76)
- **`StopFailure` フック**: APIエラー（レート制限、認証失敗等）でターンが終了した時に発火 (2.1.78)
- **`PostCompact` フック**: コンパクション完了時に発火 (2.1.76)
- **`Elicitation` / `ElicitationResult` フック**: MCP elicitation の割り込み・オーバーライド (2.1.76)
- **`worktree.sparsePaths` 設定**: 大規模モノレポで必要なディレクトリだけチェックアウト (2.1.76)
- **`allowRead` サンドボックス設定**: denyRead 内で再許可 (2.1.77)
- **レスポンスの行単位ストリーミング** (2.1.78)
- **tmux passthrough でターミナル通知**: `set -g allow-passthrough on` で tmux 越しに通知到達 (2.1.78)
- **`ANTHROPIC_CUSTOM_MODEL_OPTION` 環境変数**: /model ピッカーにカスタムエントリ追加 (2.1.78)
- **`/color` コマンド**: セッションごとのプロンプトバー色設定 (2.1.75)
- **`/effort` スラッシュコマンド** (2.1.76)
- **`/fork` → `/branch` にリネーム** (2.1.77)
- **`--console` フラグ**: `claude auth login` で Anthropic Console 認証 (2.1.79)
- **`/config` に「Show turn duration」トグル** (2.1.79)

### 主なバグ修正

- トークン推定の過大カウント修正（早期コンパクション防止）(2.1.75)
- deferred tools がコンパクション後にスキーマ消失する問題修正 (2.1.76)
- "Always Allow" で compound bash コマンドが1ルールになる問題修正 (2.1.77)
- deny 権限ルールが MCP サーバーツールに効かない問題修正 (2.1.78)
- サンドボックス依存関係不足時のサイレント無効化→警告表示 (2.1.78)
- 起動メモリ使用量 ~18MB 改善 (2.1.79)

### 設定への影響

- `settings.json`: `StopFailure` フック追加（APIエラー終了時の macOS 通知）、`ENABLE_CLAUDEAI_MCP_SERVERS` を `"true"` に変更
- `CLAUDE.md`: 変更なし
- `commands/`: 変更なし

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
