---
description: git worktreeを管理（作成/削除/一覧表示）
argument-hint: "<new|add|remove|list> <branch-name> [-b|-f]"
allowed-tools: Bash(git worktree:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git status:*), Bash(git check-ref-format:*), Bash(mkdir:*)
---

# コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 既存のworktree一覧: !`git worktree list`
- リポジトリルート: !`git rev-parse --show-toplevel`

# タスク

## 引数解析

1. `$ARGUMENTS`から以下を抽出:
   - サブコマンド: `new`, `add`, `remove`, `list`のいずれか
   - ブランチ名（サブコマンドが`list`以外の場合）
   - オプション: `-b`（ブランチも削除）、`-f`（強制削除）

2. 引数が不足している場合、使用方法を表示:
   ```
   使用方法:
     /worktree new <branch-name>       # 新規ブランチ + worktree作成
     /worktree add <branch-name>       # 既存ブランチのworktree作成
     /worktree remove <branch-name> [-b] [-f]  # worktree削除
     /worktree list                    # worktree一覧表示
   ```

## サブコマンド実行

### new: 新規ブランチ + worktree作成

1. ブランチ名のバリデーション:
   - `git check-ref-format --branch <branch>`でブランチ名の妥当性を確認
   - エラーの場合: 「無効なブランチ名です: '<branch>'。git ブランチ命名規則に従ってください。」

2. リポジトリルート取得:
   - `git rev-parse --show-toplevel`
   - エラーの場合: 「gitリポジトリ内で実行してください。」

3. worktreeパス構築:
   - `<repo-root>/.local/worktrees/<branch>`

4. .local/worktreesディレクトリの作成:
   - `mkdir -p <repo-root>/.local/worktrees`（必要に応じて）

5. worktree衝突チェック:
   - `git worktree list | grep ".local/worktrees/<branch>"`
   - 既に存在する場合: 「worktree '.local/worktrees/<branch>' は既に存在します。異なるブランチ名を使用するか、/worktree remove で削除してください。」

6. worktree作成:
   - `git worktree add -b <branch> .local/worktrees/<branch>`

7. 成功メッセージ:
   ```
   worktree '.local/worktrees/<branch>' を作成しました。

   次のコマンドで移動できます:
   cd .local/worktrees/<branch>
   ```

### add: 既存ブランチのworktree作成

1. ブランチの存在確認:
   - `git branch --list <branch>`で確認
   - 存在しない場合: 「ブランチ '<branch>' は存在しません。/worktree new <branch> で新規作成してください。」

2. リポジトリルート取得:
   - `git rev-parse --show-toplevel`
   - エラーの場合: 「gitリポジトリ内で実行してください。」

3. worktreeパス構築:
   - `<repo-root>/.local/worktrees/<branch>`

4. .local/worktreesディレクトリの作成:
   - `mkdir -p <repo-root>/.local/worktrees`（必要に応じて）

5. worktree衝突チェック:
   - `git worktree list | grep ".local/worktrees/<branch>"`
   - 既に存在する場合: 「worktree '.local/worktrees/<branch>' は既に存在します。異なるブランチ名を使用するか、/worktree remove で削除してください。」

6. worktree作成:
   - `git worktree add .local/worktrees/<branch> <branch>`

7. 成功メッセージ:
   ```
   worktree '.local/worktrees/<branch>' を作成しました。

   次のコマンドで移動できます:
   cd .local/worktrees/<branch>
   ```

### remove: worktree削除

1. リポジトリルート取得:
   - `git rev-parse --show-toplevel`
   - エラーの場合: 「gitリポジトリ内で実行してください。」

2. worktreeパス構築:
   - `<repo-root>/.local/worktrees/<branch>`

3. worktree存在確認:
   - `git worktree list | grep ".local/worktrees/<branch>"`
   - 存在しない場合: 「worktree '.local/worktrees/<branch>' は存在しません。」

4. 未コミット変更の検出（`-f`オプションがない場合）:
   - `(cd <worktree-path> && git status --porcelain)`
   - 変更がある場合:
     ```
     worktree '<branch>' に未コミットの変更があります:
     <変更内容>

     続行すると変更が失われます。
     -f オプションで強制削除するか、先にコミットしてください。
     ```
   - 処理を中断

5. worktree削除:
   - `-f`オプションがある場合: `git worktree remove --force <worktree-path>`
   - `-f`オプションがない場合: `git worktree remove <worktree-path>`

6. ブランチ削除（`-b`オプションがある場合）:
   - `git branch -D <branch>`
   - 成功メッセージに「ブランチ '<branch>' も削除しました。」を追加

7. 成功メッセージ:
   ```
   worktree '.local/worktrees/<branch>' を削除しました。
   [ブランチも削除した場合: ブランチ '<branch>' も削除しました。]
   ```

### list: worktree一覧表示

1. worktree一覧を取得して表示:
   - `git worktree list -v`

## エラーハンドリング

- すべてのgitコマンドの実行時にエラーチェックを行う
- エラーメッセージは日本語で分かりやすく表示
- ユーザーに次の行動を提案する（例: 「/worktree new <branch> で新規作成してください。」）

## 注意事項

- worktreeからのcdは永続化しないため、ユーザーに手動で`cd`を実行するよう案内する
- リポジトリルートを常に取得することで、worktree内からコマンドを実行しても正しく動作するようにする
- ブランチ名に`/`が含まれる場合（例: `feat/add-feature`）、自動的にサブディレクトリが作成される
