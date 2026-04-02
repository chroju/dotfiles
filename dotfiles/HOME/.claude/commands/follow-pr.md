---
description: PRをマージまで追いかけ、チェック・対応・マージ・クリーンアップを実行
argument-hint: "[省略可: PR番号]"
allowed-tools: Bash(gh pr view:*), Bash(gh pr merge:*), Bash(git status:*), Bash(git branch:*), Bash(git switch:*), Bash(git pull:*), Skill(check-pr), Skill(loop)
---

# タスク

PRをマージされるまで追いかける。`/check-pr` を定期実行してCI修正・コメント対応を行い、マージ準備が整ったらマージとクリーンアップを実行する。

## Step 1: PR番号の特定

1. `$ARGUMENTS` が数値として指定されている場合、それをPR番号として使用
2. 指定がない場合、`gh pr view --json number -q '.number'` で現在のブランチに紐づくPRを取得
3. PRが見つからない場合: 「現在のブランチに関連するPRが見つかりません。PR番号を引数で指定してください。」と表示して終了

## Step 2: PR状態の確認

以下のコマンドでPR情報を取得:

```bash
gh pr view <number> --json state,reviewDecision,statusCheckRollup,title,url,number,headRefName
```

- `state` が `MERGED` → **Step 4（クリーンアップ）** へ
- `state` が `CLOSED` → 「PR #N はクローズされています。」と報告して終了
- `state` が `OPEN` → **Step 3** へ

## Step 3: 監視の開始

`/loop 5m /check-pr <number>` を実行してPRの定期監視を開始する。

`/check-pr` がマージ準備完了（CI全成功＆レビュー承認済み）を報告したら、**Step 4** へ進む。

## Step 4: マージ

1. 「PR #N "タイトル" をマージします。」と報告
2. `gh pr merge <number> --merge` を実行
   - `gh pr merge` は ask 権限が設定されているため、ユーザー確認が入る
3. マージ成功 → **Step 5** へ

## Step 5: クリーンアップ

1. `headRefName` からマージ済みブランチ名を取得
2. `git switch main` でmainブランチに切り替え
3. `git pull` で最新化
4. `git branch -d <branch>` でローカルブランチを削除（リモートブランチは削除しない）
5. 「PR #N はマージされました。ローカルブランチ `<branch>` を削除しました。」と報告して終了

## エラーハンドリング

- `gh` コマンドが認証エラー → 「GitHub CLIの認証が必要です。`gh auth login` を実行してください。」
- PR番号が無効 → 「PR #N が見つかりません。番号を確認してください。」
- ブランチ削除に失敗 → 状況を報告し、手動対応を促す
