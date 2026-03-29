---
description: 会話内容をScrapboxページとして開く
argument-hint: "[省略可: ページタイトルのヒント]"
allowed-tools: Bash(python3:*), Bash(open:*)
---

# タスク

直前の会話内容をScrapboxのページとして整理し、ブラウザで開く。

## ページの作成ルール

### タイトル
- プレフィックスに `🤖 ` を付ける
- 内容を端的に表す日本語タイトル
- `$ARGUMENTS` が指定された場合はそれをタイトルのヒントとして使う

### 本文
- 先頭行に `[by Claude Code]` を入れる
- Scrapboxの記法に従う
  - インデントにはタブを使う
  - 箇条書きはインデントで表現する（`-` は使わない）
  - コードブロックは `code:言語名` の後にインデントで記述
- 関連するキーワードは `[キーワード]` でブラケティングする（例: `[tmux]`, `[OSC]`, `[DCS]`）
- 参考URLがある場合は `[URL]` 形式で記載

## 実行ステップ

1. 会話内容を整理してタイトルと本文を決定する
2. python3でタイトルと本文をURLエンコードしてScrapbox URLを生成する
   - URL形式: `https://scrapbox.io/chroju/{encoded_title}?body={encoded_body}`
3. `open` コマンドでブラウザを開く
