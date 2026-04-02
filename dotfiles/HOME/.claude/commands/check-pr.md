---
description: PRの状態を1回チェックし、CI失敗の修正・コメント対応を実行
argument-hint: "[省略可: PR番号]"
allowed-tools: Bash(gh pr view:*), Bash(gh pr checks:*), Bash(gh api:*), Bash(gh run view:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git switch:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git pull:*), Read, Glob, Grep, Edit, MultiEdit, Write, Skill(commit)
---

# タスク

PRの状態を1回チェックし、CI失敗の修正・レビューコメントへの対応を実行する。
`/loop` との組み合わせ（例: `/loop 5m /check-pr`）で定期的な監視が可能。

## Step 1: PR番号の特定

1. `$ARGUMENTS` が数値として指定されている場合、それをPR番号として使用
2. 指定がない場合、`gh pr view --json number -q '.number'` で現在のブランチに紐づくPRを取得
3. PRが見つからない場合: 「現在のブランチに関連するPRが見つかりません。PR番号を引数で指定してください。」と表示して終了

## Step 2: PR状態の一括取得

以下のコマンドでPR情報を取得:

```bash
gh pr view <number> --json state,reviewDecision,statusCheckRollup,reviews,title,url,number,headRefName
```

- `state` が `MERGED` → 「PR #N は既にマージされています。`/follow-pr` でクリーンアップできます。」と報告して終了
- `state` が `CLOSED` → 「PR #N はクローズされています。」と報告して終了
- `state` が `OPEN` → **Step 3** へ

状態の概要を1行で報告する（例: 「PR #123 "タイトル" を確認中...」）

## Step 3: 優先度に基づくアクション分岐

以下の優先度順に条件を評価し、**最初に該当した1つのアクションのみ**を実行する。

### 優先度1: CIチェック失敗

**条件**: `statusCheckRollup` に `conclusion` が `FAILURE` のチェックがある

1. `gh pr checks <number>` で失敗しているチェックを特定
2. GitHub Actionsの場合、`gh run view <run_id> --log-failed` でログを取得
   - GitHub Actions以外の場合はログ取得をスキップし、チェック名とURLを報告
3. ログからエラー原因を分析
4. 関連するソースコードを `Read`, `Grep`, `Glob` で調査
5. 修正を実施（`Edit` / `Write`）
6. `/commit` スキルでコミット＆プッシュ
7. 「CI失敗を修正しました: <概要>」と報告

**修正できない場合**:
- 無理に修正を試みない
- 失敗内容とログの要約を報告し、ユーザーの判断を仰ぐ

### 優先度2: 未対応コメント

**条件**: CIが全て成功（または未設定）で、未対応のコメントがある

#### コメントの取得

以下の3種類のコメントを取得する:

1. `gh api repos/{owner}/{repo}/pulls/{number}/comments` でレビューコメント（diff行へのコメント）取得
2. `gh api repos/{owner}/{repo}/issues/{number}/comments` で一般コメント（PR全体へのコメント）取得
3. `gh pr view <number> --json reviews` でレビュー情報を取得

#### 未対応コメントの判定

- **レビューコメント**: スレッド内で最新の返信がPR作成者以外 → 未対応
- **一般コメント**: PR作成者以外からのコメントで、その後にPR作成者からのより新しい一般コメントが存在しない → 未対応
- `reviewDecision` が `CHANGES_REQUESTED` → 未対応のレビューあり

#### 各未対応コメントへの対応

- 指摘が明確でコード修正で対応可能な場合:
  - コードを修正（`Edit`）
  - `/commit` スキルでコミット＆プッシュ
  - `gh api` で修正内容をリプライとして投稿
- 設計判断が必要、または曖昧なコメントの場合:
  - コメント内容をユーザーに報告し、判断を委ねる
  - 勝手に修正しない

### 優先度3: マージ準備完了

**条件**: `statusCheckRollup` が全て `SUCCESS`（またはチェック未設定）かつ `reviewDecision` が `APPROVED`

- 「PR #N はすべてのチェックに合格し、承認済みです。マージ準備完了です。」と報告して終了

### 優先度4: 待機中

**条件**: 上記いずれにも該当しない（チェック実行中、レビュー待ちなど）

- 現在の状態を簡潔に報告して終了:
  - チェック実行中の場合: 「CIチェックが実行中です。」
  - レビュー待ちの場合: 「レビュー待ちです。」

## 冪等性

- 毎回PR状態をAPIから新規取得する（前回の結果をキャッシュしない）
- 前回プッシュした修正でCIが再実行中 → 優先度4（待機中）に自然に分岐する
- 既にリプライ済みのコメントスレッドはスキップする

## エラーハンドリング

- `gh` コマンドが認証エラー → 「GitHub CLIの認証が必要です。`gh auth login` を実行してください。」
- PR番号が無効 → 「PR #N が見つかりません。番号を確認してください。」
- CIログの取得に失敗 → 失敗したチェック名とURLを表示し、手動確認を促す
- コード修正中にエラー → 変更をrevertせず、状況を報告してユーザーに判断を委ねる
