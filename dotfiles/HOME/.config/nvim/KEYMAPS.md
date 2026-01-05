# Neovim キーマップリファレンス

このドキュメントは、Neovim設定で定義されているカスタムキーマップの一覧です。

## 基本操作

### ファイル操作

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `,,` | ノーマル | ファイルを保存（変更がある場合のみ） | [keymaps.lua:7](lua/config/keymaps.lua) |
| `<Space>,,` | ノーマル | sudo権限でファイルを保存 | [keymaps.lua:33](lua/config/keymaps.lua) |
| `<Space><Space>` | ノーマル | init.luaを開く | [keymaps.lua:27](lua/config/keymaps.lua) |
| `F5` | ノーマル | 設定をリロード | [keymaps.lua:30](lua/config/keymaps.lua) |

### カーソル移動

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `<Space>l` | ノーマル/ビジュアル | 行末に移動 | [keymaps.lua:10](lua/config/keymaps.lua) |
| `<Space>h` | ノーマル/ビジュアル | 行頭（非空白文字）に移動 | [keymaps.lua:11](lua/config/keymaps.lua) |
| `j` | ノーマル/ビジュアル | 表示行で下に移動 | [keymaps.lua:17](lua/config/keymaps.lua) |
| `k` | ノーマル/ビジュアル | 表示行で上に移動 | [keymaps.lua:18](lua/config/keymaps.lua) |
| `gj` | ノーマル/ビジュアル | 実際の行で下に移動 | [keymaps.lua:19](lua/config/keymaps.lua) |
| `gk` | ノーマル/ビジュアル | 実際の行で上に移動 | [keymaps.lua:20](lua/config/keymaps.lua) |

### 編集

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `Y` | ノーマル | 行末までヤンク | [keymaps.lua:14](lua/config/keymaps.lua) |

### タブ操作

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `tc` | ノーマル | 新しいタブを作成 | [keymaps.lua:23](lua/config/keymaps.lua) |
| `tx` | ノーマル | タブを閉じる | [keymaps.lua:24](lua/config/keymaps.lua) |

### その他

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `,d` | ノーマル | カレントディレクトリを編集中ファイルのディレクトリに変更 | [keymaps.lua:36](lua/config/keymaps.lua) |

## プラグイン関連

### Telescope（ファジーファインダー）

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `bb` | ノーマル | バッファ一覧を表示 | [editor.lua:27](lua/plugins/editor.lua) |

**Telescope内の操作**:
- `Ctrl-j` - 次の候補に移動
- `Ctrl-k` - 前の候補に移動
- `Enter` - 選択
- `Esc` - キャンセル

### nvim-tree（ファイルエクスプローラー）

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `,f` | ノーマル | ファイルツリーの開閉 | [editor.lua:101](lua/plugins/editor.lua) |

**ファイルツリー内の操作**:
- `Enter` - ファイルを新しいタブで開く / ディレクトリを展開
- `o` - ファイルを現在のウィンドウで開く
- `a` - 新規ファイル/ディレクトリ作成
- `d` - 削除
- `r` - リネーム
- `y` - ファイル名をコピー
- `x` - カット
- `p` - ペースト
- `R` - リフレッシュ
- `q` - 閉じる

### LSP（言語サーバー）

LSPが有効なバッファで自動的に設定されるキーマップ:

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `gd` | ノーマル | 定義にジャンプ | [lsp.lua:12](lua/plugins/lsp.lua) |
| `gD` | ノーマル | 宣言にジャンプ | [lsp.lua:13](lua/plugins/lsp.lua) |
| `gi` | ノーマル | 実装にジャンプ | [lsp.lua:14](lua/plugins/lsp.lua) |
| `gr` | ノーマル | 参照箇所を表示 | [lsp.lua:15](lua/plugins/lsp.lua) |
| `K` | ノーマル | ホバーでドキュメントを表示 | [lsp.lua:16](lua/plugins/lsp.lua) |
| `Ctrl-k` | ノーマル | 関数シグネチャヘルプを表示 | [lsp.lua:17](lua/plugins/lsp.lua) |
| `<Space>rn` | ノーマル | シンボルをリネーム | [lsp.lua:18](lua/plugins/lsp.lua) |
| `<Space>ca` | ノーマル | コードアクションを実行 | [lsp.lua:19](lua/plugins/lsp.lua) |
| `<Space>f` | ノーマル | コードをフォーマット | [lsp.lua:20-22](lua/plugins/lsp.lua) |

### nvim-cmp（補完）

補完ポップアップが表示されているときの操作:

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `Tab` | 挿入/選択 | 次の候補を選択 / スニペット展開 | [completion.lua:30-37](lua/plugins/completion.lua) |
| `Shift-Tab` | 挿入/選択 | 前の候補を選択 / スニペット戻る | [completion.lua:39-46](lua/plugins/completion.lua) |
| `Enter` | 挿入 | 補完を確定 | [completion.lua:29](lua/plugins/completion.lua) |
| `Ctrl-e` | 挿入 | 補完をキャンセル | [completion.lua:28](lua/plugins/completion.lua) |
| `Ctrl-Space` | 挿入 | 補完を手動起動 | [completion.lua:27](lua/plugins/completion.lua) |
| `Ctrl-b` | 挿入 | ドキュメントを上にスクロール | [completion.lua:25](lua/plugins/completion.lua) |
| `Ctrl-f` | 挿入 | ドキュメントを下にスクロール | [completion.lua:26](lua/plugins/completion.lua) |

### switch.vim（値の切り替え）

| キー | モード | 機能 | 定義場所 |
|------|--------|------|----------|
| `!` | ノーマル | true/false、yes/noなどを切り替え | [editor.lua:143](lua/plugins/editor.lua) |

### Comment.nvim（コメント）

デフォルトのキーマップ:

| キー | モード | 機能 |
|------|--------|------|
| `gcc` | ノーマル | 現在行をコメント化/解除 |
| `gc` + モーション | ノーマル | 範囲をコメント化（例: `gcap` で段落） |
| `gc` | ビジュアル | 選択範囲をコメント化/解除 |

### vim-surround（囲み文字操作）

主なコマンド:

| コマンド | 機能 | 例 |
|----------|------|-----|
| `ysiw"` | 単語を囲む | `word` → `"word"` |
| `cs"'` | 囲み文字を変更 | `"word"` → `'word'` |
| `ds"` | 囲み文字を削除 | `"word"` → `word` |
| `yss)` | 行全体を囲む | `word` → `(word)` |
| `S"` (ビジュアル) | 選択範囲を囲む | 選択 → `"選択"` |

## エディタ設定

### オプション

主要な設定（詳細は [options.lua](lua/config/options.lua) を参照）:

- **行番号表示**: `number = true`
- **インデント**: 2スペース（`tabstop = 2`, `shiftwidth = 2`）
- **検索**: インクリメンタルサーチ、ハイライト、大文字小文字の賢い判別
- **クリップボード**: OSのクリップボードと連携
- **バックアップ**: 無効（`backup = false`, `swapfile = false`）

## カテゴリ別キーマップ

### よく使うキーマップ

| 操作 | キー |
|------|------|
| **保存** | `,,` |
| **ファイルツリー** | `,f` |
| **バッファ一覧** | `bb` |
| **設定を開く** | `<Space><Space>` |
| **設定をリロード** | `F5` |

### LSP開発でよく使うキーマップ

| 操作 | キー |
|------|------|
| **定義ジャンプ** | `gd` |
| **参照検索** | `gr` |
| **ドキュメント表示** | `K` |
| **リネーム** | `<Space>rn` |
| **コードアクション** | `<Space>ca` |
| **フォーマット** | `<Space>f` |

### 編集でよく使うキーマップ

| 操作 | キー |
|------|------|
| **行末ヤンク** | `Y` |
| **行末移動** | `<Space>l` |
| **行頭移動** | `<Space>h` |
| **コメント化** | `gcc` |
| **値の切り替え** | `!` |

## 参考

詳しい使い方は [TUTORIAL.md](TUTORIAL.md) を参照してください。
