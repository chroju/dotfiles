---
description: 現在のgit diffからConventional Commits形式のコミットメッセージを生成し、コミットとプッシュを実行
argument-hint: "[省略可: scopeまたはsummaryのヒント]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*)
---

# コンテキスト（自動収集）

- 現在のブランチ: !`git branch --show-current`
- 最近のコミット（直近5件）: !`git log --oneline -5`
- Git status: !`git status --porcelain=v1`
- HEADとの差分（staged & unstaged）: !`git diff HEAD`

# タスク

## 前提条件の確認

1. 現在のブランチが `main` または `master` の場合:
   - `git pull` を実行して最新化
   - 新しいブランチを作成（ブランチ名はユーザーに確認）
   - 新ブランチに切り替えてから作業を進める

## コミット対象の決定

2. **現在のコンテキストで編集したファイルのみ**をコミット対象とする
   - `git add -A` は使用しない
   - コンテキスト外で変更されたファイルは無視する
   - 論理的に異なる変更が混在している場合は、適宜複数のコミットに分ける

## コミットの実行

3. 上記のコンテキストを使用して、以下の**コミットメッセージ仕様**に従ったコミットメッセージを生成
4. 対象ファイルのみを `git add <files>` でステージング
5. 生成したメッセージでコミット
6. 現在のブランチにプッシュ

`$ARGUMENTS` が指定された場合、それを `scope` や要約のヒントとして扱う。

---

## コミットメッセージ仕様（必須）

### 1) フォーマット


    <type>(<scope>): <命令形の要約、50文字以内>

    [本文: 何を・なぜ、72文字で折り返し]

    [フッター: issue番号、BREAKING CHANGE等のメタデータ]

- `~/.gitmessages` がある場合はそれに倣う
- **type**（必須、いずれか1つ）: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- **scope**（省略可、kebab-case）: 例 auth, api, ui, deps, infra

### 2) 件名（1行目）

- 英語を使う
- 命令形（「Add」であり、「Added」「Adds」ではない）
- 50文字以内、先頭大文字、末尾にピリオドなし
- 件名の後に1行空行

### 3) 本文（何を・なぜを説明）

- 英語を使う
- 72文字で折り返し
- **何が変わったか**と**なぜ**に焦点（どうやってではない）
- ユーザーへの影響、トレードオフ、関連するコンテキストを記載
- 動作が変わる場合は移行手順を含める

**本文チェックリスト**

- 動機・コンテキスト
- 高レベルでの変更内容
- 影響・リスク・ロールバック手順

### 4) フッター（メタデータ）

- Closes #123 / Fixes #123 / Refs #123
- BREAKING CHANGE: <詳細 + 移行手順>
- Co-authored-by: Name <email>
- Signed-off-by: Name <email>（DCOの場合）

### 5) 例

良い例:

    feat(auth): Add password reset endpoint

    Adds POST /reset-password to allow email-based token resets.
    Sends time-limited tokens and invalidates on use.

    Closes #482

---

    fix(ui): Prevent sidebar overflow on Safari 17

    Use flex-basis and min-width to avoid text clipping on narrow
    viewports.

    Refs #519

---

    docs(readme): Add installation instructions for pnpm

---

    feat(api)!: require auth token for all POST routes

    All POST routes now validate JWTs. Anonymous writes removed.

    BREAKING CHANGE: Clients must include Authorization: Bearer <jwt>.

Revert:

    revert: feat(auth): Add password reset endpoint

    Reverts commit abc1234 due to regression in SSO flow.

---

## commit時の署名

- commit時にはデフォルトで署名するようになっており、 `--no-gpg-sign` や `--gpg-sign` は使用する必要がない
- 署名時にエラーが出た場合は、ユーザーに指示を仰ぐこと

---

## アシスタントが適用すべきヒューリスティック

- 変更内容から **type** を推測（テスト → test、パフォーマンス関連 → perf、依存関係のみ → build または chore(deps)）
- ファイルが明確にまとまっている場合は具体的な **scope** を優先（例: ディレクトリ名やパッケージ名）
- diffが広範なAPI変更を示している場合、! を検討し、本文/フッターで移行手順を記述
- 件名は50文字以内に収める。長い場合は意味を損なわずに簡潔にする
- diffに #123 のようなissue番号が含まれている場合、フッターに参照を含める

---

## 実行ステップ

### ステップ1: ブランチの確認と準備

1. 現在のブランチを確認
2. `main` または `master` ブランチにいる場合:
   - `git pull` を実行
   - 新しいブランチ名をユーザーに確認
   - `git checkout -b <new-branch>` でブランチ作成・切り替え

### ステップ2: 変更の分析とコミット

3. 現在のコンテキストで編集したファイルを特定
4. 論理的に異なる変更がある場合は、複数のコミットに分割
5. 各コミットについて:
   - コミットメッセージを生成
   - `git add <対象ファイル>` でステージング
   - `git commit -m "<生成されたメッセージ>"` でコミット
6. `git push origin <現在のブランチ>` でプッシュ
7. 使用したコミットメッセージと各ステップの成功/失敗を表示

