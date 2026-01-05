# Neovim 入門チュートリアル

このチュートリアルは、Vimの基本操作ができる方を対象に、Neovim設定の理解とプラグイン活用方法を学べるガイドです。

## 目次

1. [Neovim設定の基礎](#part-1-neovim設定の基礎)
2. [プラグイン管理（lazy.nvim）](#part-2-プラグイン管理lazynvim)
3. [各プラグインの使い方](#part-3-各プラグインの使い方)
4. [カスタマイズガイド](#part-4-カスタマイズガイド)
5. [実践Tips](#part-5-実践tips)

---

## Part 1: Neovim設定の基礎

### 設定の全体構造

Neovimの設定は `~/.config/nvim/` 配下に配置されます。この設定は以下の構造になっています:

```
~/.config/nvim/
├── init.lua                    # エントリーポイント
├── lua/
│   ├── config/
│   │   ├── options.lua         # エディタ基本設定
│   │   ├── keymaps.lua         # キーマップ設定
│   │   └── autocmds.lua        # 自動コマンド設定
│   └── plugins/
│       ├── init.lua            # プラグインマネージャー設定
│       ├── ui.lua              # UI関連プラグイン
│       ├── editor.lua          # エディタ拡張プラグイン
│       ├── lsp.lua             # LSP設定
│       └── completion.lua      # 補完設定
├── TUTORIAL.md                 # このファイル
└── KEYMAPS.md                  # キーマップリファレンス
```

### VimとNeovimの設定の違い

#### 設定言語
- **Vim**: vimscript (`.vimrc`)
- **Neovim**: Lua (`.config/nvim/init.lua`)

Luaを使うことで、より高速で読みやすい設定が可能になります。

#### 設定例の比較

**Vimの場合 (vimscript)**:
```vim
set number
set tabstop=2
nnoremap ,, :update<CR>
```

**Neovimの場合 (Lua)**:
```lua
vim.opt.number = true
vim.opt.tabstop = 2
vim.keymap.set('n', ',,', '<Cmd>update<CR>')
```

### 設定ファイルの読み込み順序

1. `init.lua` が最初に読み込まれる
2. `require('config.options')` で基本設定を読み込み
3. `require('config.keymaps')` でキーマップを読み込み
4. `require('config.autocmds')` で自動コマンドを読み込み
5. `require('plugins.init')` でプラグインシステムを起動

参照: [init.lua](init.lua)

### init.luaの役割

`init.lua` は設定のエントリーポイントです。文字エンコーディングを設定し、各設定モジュールを読み込みます。

```lua
-- エンコーディング設定
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'ucs-bom', 'utf-8', 'cp932', 'sjis', 'euc-jp', 'iso-2022-jp' }

-- 各設定モジュールを読み込み
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('plugins.init')
```

---

## Part 2: プラグイン管理（lazy.nvim）

### lazy.nvimとは

[lazy.nvim](https://github.com/folke/lazy.nvim) は、Neovim用の高速でモダンなプラグインマネージャーです。

**特徴**:
- 高速な起動時間
- 自動的な遅延読み込み（lazy loading）
- プラグインの依存関係を自動解決
- UIでプラグインの管理が可能

### プラグインの管理操作

#### プラグイン管理UIを開く
```vim
:Lazy
```

#### 主なコマンド
- `:Lazy install` - 新しいプラグインをインストール
- `:Lazy update` - プラグインを更新
- `:Lazy sync` - インストールと更新を同時実行
- `:Lazy clean` - 未使用のプラグインを削除
- `:Lazy check` - 更新があるか確認

### プラグイン設定の基本パターン

プラグインは `lua/plugins/` 配下のファイルで定義されます。基本的なパターンは以下の通り:

```lua
return {
  -- プラグインの指定
  {
    'author/plugin-name',

    -- 依存関係
    dependencies = {
      'other/plugin',
    },

    -- 設定関数
    config = function()
      require('plugin-name').setup({
        -- プラグインの設定
      })

      -- キーマップなど
      vim.keymap.set('n', '<key>', '<command>')
    end,
  },
}
```

実例: [lua/plugins/editor.lua](lua/plugins/editor.lua)

### Lazy Loadingとは

プラグインを起動時ではなく、必要になったときに読み込む仕組みです。これにより起動時間が大幅に短縮されます。

**例**:
```lua
{
  'windwp/nvim-autopairs',
  event = 'InsertEnter',  -- 挿入モードに入ったときに読み込み
  opts = {},
}
```

この設定では、挿入モードに入るまでプラグインは読み込まれません。

---

## Part 3: 各プラグインの使い方

### Telescope - ファジーファインダー

[Telescope](https://github.com/nvim-telescope/telescope.nvim) は、ファイル、バッファ、grep結果などを検索するためのファジーファインダーです。

#### 基本操作

**バッファ一覧を表示**:
```
bb
```

Telescopeのウィンドウが開いたら:
- `Ctrl-j` / `Ctrl-k` - 上下移動
- `Enter` - 選択
- `Esc` - キャンセル

#### 他の便利な機能

プラグイン設定に追加すれば使える機能（例）:
```lua
-- ファイル検索
vim.keymap.set('n', '<C-p>', builtin.find_files)

-- grep検索
vim.keymap.set('n', '<C-g>', builtin.live_grep)

-- ヘルプタグ検索
vim.keymap.set('n', '<Space>h', builtin.help_tags)
```

参照: [lua/plugins/editor.lua:6-28](lua/plugins/editor.lua)

### nvim-tree - ファイルエクスプローラー

[nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) は、サイドバー形式のファイルツリーを提供します。

#### 基本操作

**ファイルツリーの開閉**:
```
,f
```

**ツリー内での操作**:
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

#### カスタマイズポイント

- タブと同期: ファイルツリーは各タブで自動的に開閉します
- Git統合: Git管理されているファイルには状態が表示されます
- アイコン表示: ファイル種別ごとにアイコンが表示されます

参照: [lua/plugins/editor.lua:32-111](lua/plugins/editor.lua)

### LSP - 言語サーバー

[LSP (Language Server Protocol)](https://microsoft.github.io/language-server-protocol/) により、IDE並みの機能が利用できます。

#### 有効な言語

現在の設定では以下の言語がサポートされています:
- **Go** (gopls)
- **Terraform** (terraform-ls)
- **Bash** (bash-language-server)

#### LSPキーマップ

LSPが有効なバッファでは、以下のキーマップが自動的に設定されます:

| キー | 機能 | 説明 |
|------|------|------|
| `gd` | Go to Definition | 定義にジャンプ |
| `gD` | Go to Declaration | 宣言にジャンプ |
| `gi` | Go to Implementation | 実装にジャンプ |
| `gr` | References | 参照箇所を表示 |
| `K` | Hover | ドキュメントを表示 |
| `Ctrl-k` | Signature Help | 関数シグネチャを表示 |
| `<Space>rn` | Rename | シンボルをリネーム |
| `<Space>ca` | Code Action | コードアクションを実行 |
| `<Space>f` | Format | コードをフォーマット |

#### 診断機能

LSPは以下の情報を自動的に表示します:
- エラーや警告の表示（仮想テキスト）
- シンボルの下線表示
- サイン列での表示

参照: [lua/plugins/lsp.lua](lua/plugins/lsp.lua)

### nvim-cmp - 補完

[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) は、強力な補完エンジンです。

#### 補完の操作方法

補完ポップアップが表示されたら:

| キー | 機能 |
|------|------|
| `Tab` | 次の候補を選択 / スニペット展開 |
| `Shift-Tab` | 前の候補を選択 |
| `Enter` | 確定 |
| `Ctrl-e` | キャンセル |
| `Ctrl-b` / `Ctrl-f` | ドキュメントスクロール |
| `Ctrl-Space` | 手動で補完を起動 |

#### 補完ソース

以下の順序で補完候補が提供されます:
1. LSPからの補完
2. スニペット
3. バッファ内のテキスト
4. ファイルパス

参照: [lua/plugins/completion.lua](lua/plugins/completion.lua)

### Treesitter - シンタックスハイライト

[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) は、コードの構文解析によるより正確なシンタックスハイライトを提供します。

#### サポート言語

以下の言語が自動的にインストールされます:
- Lua, Vim, Go, Terraform, HCL, Bash

新しい言語のパーサーは自動的にインストールされます（`auto_install = true`）。

参照: [lua/plugins/editor.lua:114-126](lua/plugins/editor.lua)

### その他の便利なプラグイン

#### vim-surround
囲み文字の操作を簡単にします。

**例**:
- `ysiw"` - カーソル下の単語を `"` で囲む
- `cs"'` - `"` を `'` に変更
- `ds"` - `"` を削除
- `yss)` - 行全体を `()` で囲む

#### Comment.nvim
コメントの切り替えを簡単にします。

**デフォルトキーマップ**:
- `gcc` - 現在行をコメント化/解除
- `gc` + モーション - 範囲をコメント化（例: `gcap` で段落をコメント）
- ビジュアルモード: `gc` - 選択範囲をコメント化/解除

#### switch.vim
true/false、yes/no などの値を切り替えます。

**キーマップ**:
```
!
```

カーソル位置の単語を切り替えます（true ↔ false、yes ↔ no など）。

参照: [lua/plugins/editor.lua:140-144](lua/plugins/editor.lua)

#### nvim-autopairs
括弧やクォートの自動補完を行います。

挿入モードで `(` を入力すると自動的に `)` が補完され、カーソルは括弧の中に配置されます。

---

## Part 4: カスタマイズガイド

### 既存のキーマップ一覧

詳細は [KEYMAPS.md](KEYMAPS.md) を参照してください。

### Vimの設定からの移行ポイント

元のVim設定（`~/.vim/vimrc`）と比較した主な違い:

#### プラグインマネージャー
- **Vim**: dein.vim
- **Neovim**: lazy.nvim

#### 設定の書き方
- **Vim**: `set number` → **Neovim**: `vim.opt.number = true`
- **Vim**: `nnoremap` → **Neovim**: `vim.keymap.set('n', ...)`

#### 追加された機能
- LSPサポート（gopls, terraform-ls, bash-language-server）
- Treesitterによる高度なシンタックスハイライト
- nvim-cmpによる統合的な補完
- Telescopeによるモダンなファジーファインダー

### プラグインの追加方法

1. 適切なファイルを選択（UI系なら `lua/plugins/ui.lua`、エディタ拡張なら `lua/plugins/editor.lua`）
2. プラグイン定義を追加:

```lua
{
  'author/plugin-name',
  config = function()
    require('plugin-name').setup({
      -- 設定
    })
  end,
}
```

3. Neovimを再起動
4. `:Lazy sync` でプラグインをインストール

### 設定のリロード方法

**設定ファイルをリロード**:
```
F5
```

または:
```vim
:source $MYVIMRC
```

**設定ファイルを編集**:
```
<Space><Space>
```

現在のバッファが空の場合は同じウィンドウで、そうでない場合は新しいタブで `init.lua` を開きます。

参照: [lua/config/keymaps.lua:26-30](lua/config/keymaps.lua)

---

## Part 5: 実践Tips

### 効率的なワークフロー例

#### ファイル編集の基本フロー

1. **プロジェクトに移動**
   ```bash
   cd ~/dev/src/github.com/user/project
   nvim
   ```

2. **ファイルツリーで概要を把握**
   ```
   ,f
   ```

3. **ファイルを開いて編集**
   - ツリーから `Enter` で新しいタブで開く
   - または `o` で現在のウィンドウで開く

4. **バッファ間を移動**
   ```
   bb
   ```
   Telescopeでバッファ一覧から選択

5. **保存**
   ```
   ,,
   ```

#### Go開発の例

1. **ファイルを開く**
   ```bash
   nvim main.go
   ```

2. **コードジャンプ**
   - `gd` で関数定義にジャンプ
   - `Ctrl-o` で戻る
   - `gr` で参照箇所を確認

3. **リファクタリング**
   - `<Space>rn` で変数名を一括変更
   - `<Space>ca` でコードアクション（import追加など）

4. **フォーマット**
   ```
   <Space>f
   ```

5. **エラーチェック**
   - LSPが自動的にエラーを表示
   - `:lua vim.diagnostic.open_float()` で詳細を表示

#### Terraform開発の例

1. **ファイルを開く**
   ```bash
   nvim main.tf
   ```

2. **補完を活用**
   - リソース名を入力すると自動補完
   - ドキュメントが表示される

3. **フォーマット**
   ```
   <Space>f
   ```
   terraform-lsが自動的にフォーマット

### LSPを使った開発

#### LSPの動作確認

```vim
:LspInfo
```

現在のバッファで有効なLSPクライアントを確認できます。

#### LSPログの確認

```vim
:LspLog
```

LSPの動作に問題がある場合、ログを確認できます。

### トラブルシューティング

#### プラグインが読み込まれない

1. `:Lazy` を開く
2. `I` でインストール状態を確認
3. 必要に応じて `:Lazy sync` を実行

#### LSPが動作しない

1. 言語サーバーがインストールされているか確認:
   ```bash
   which gopls
   which terraform-ls
   which bash-language-server
   ```

2. `:LspInfo` で接続状態を確認

3. 必要に応じて言語サーバーをインストール:
   ```bash
   # Go
   go install golang.org/x/tools/gopls@latest

   # Terraform
   brew install terraform-ls

   # Bash
   npm i -g bash-language-server
   ```

#### 設定が反映されない

1. `F5` でリロード
2. それでもダメなら一度Neovimを終了して再起動
3. プラグイン設定の場合は `:Lazy sync` を実行

#### 文字化けやエンコーディング問題

現在の設定では以下の順序で文字コードを判別します:
```
ucs-bom → utf-8 → cp932 → sjis → euc-jp → iso-2022-jp
```

特定のエンコーディングで開きたい場合:
```vim
:e ++enc=sjis filename.txt
```

---

## 次のステップ

1. **[KEYMAPS.md](KEYMAPS.md)** でキーマップを確認
2. 実際にファイルを編集しながら各機能を試す
3. 自分好みにカスタマイズする
4. 必要に応じてプラグインを追加

## 参考リンク

- [Neovim公式ドキュメント](https://neovim.io/doc/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
