#!/bin/bash
# Claude Code statusLine script
# Displays: directory (branch) | context usage % | model | version

# ブランチ情報を取得
BRANCH=""
PREFIX=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  # worktree内かチェック
  if [[ "$PWD" == *"/.local/worktrees/"* ]]; then
    PREFIX="//"
  fi
fi

jq -r --arg branch "$BRANCH" --arg prefix "$PREFIX" '
  .cwd as $cwd |
  .workspace.project_dir as $proj |
  (if ($cwd | startswith($proj))
    then ($cwd | split("/") | .[-2:] | join("/"))
    else ($cwd | sub("^" + env.HOME; "~"))
  end) as $display_dir |
  (.context_window.current_usage) as $usage |
  (if $usage != null then
    (($usage.input_tokens // 0) + ($usage.output_tokens // 0) + ($usage.cache_creation_input_tokens // 0) + ($usage.cache_read_input_tokens // 0)) as $current |
    (.context_window.context_window_size) as $max |
    (($current * 100 / $max) | floor | tostring) + "%"
  else
    "N/A"
  end) as $context_pct |
  (if $branch != "" then " (" + $prefix + $branch + ")" else "" end) as $branch_info |
  "\u001b[37m" + $display_dir + $branch_info + " | context: " + $context_pct + " | " +
  .model.id + " | v" + .version + "\u001b[0m"
'
