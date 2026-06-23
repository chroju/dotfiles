#!/bin/bash
# Claude Code statusLine script
# Displays: ../dir | ⎇ branch | ⧉ worktree | Ctx: X.X% | Model

BRANCH=$(git branch --show-current 2>/dev/null || echo "-")

WORKTREE="-"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  MAIN_WORKTREE=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
  CURRENT_WORKTREE=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$MAIN_WORKTREE" ] && [ "$CURRENT_WORKTREE" != "$MAIN_WORKTREE" ]; then
    WORKTREE=$(basename "$CURRENT_WORKTREE")
  fi
fi

input=$(cat)

CWD=$(echo "$input" | jq -r '.cwd // ""')
PROJ=$(echo "$input" | jq -r '.workspace.project_dir // ""')

if [ -n "$PROJ" ] && [[ "$CWD" == "$PROJ"* ]]; then
  DISPLAY_DIR=$(echo "$CWD" | awk -F/ '{print $(NF-1)"/"$NF}')
else
  DISPLAY_DIR="${CWD/#$HOME/\~}"
fi

CURRENT=$(echo "$input" | jq '
  (.context_window.current_usage // {}) |
  (.input_tokens // 0) + (.output_tokens // 0) +
  (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
')
MAX_CTX=$(echo "$input" | jq '.context_window.context_window_size // 0')

if [ "${MAX_CTX:-0}" -gt 0 ] && [ "${CURRENT:-0}" -gt 0 ]; then
  PCT=$(awk "BEGIN { printf \"%.1f\", $CURRENT * 100 / $MAX_CTX }")
  CTX="Ctx: ${PCT}%"
else
  CTX="Ctx: N/A"
fi

MODEL_NAME=$(echo "$input" | jq -r '.model.display_name // .model.id // ""')

DEVCONTAINER_IND=""
if [ -n "${container}" ]; then
  DEVCONTAINER_IND="yes"
fi

C=$'\033'
yellow="${C}[33m"
blue="${C}[34m"
magenta="${C}[35m"
cyan="${C}[36m"
sep="${C}[90m | "
light="${C}[38;5;245m"
reset="${C}[0m"

if [ -n "$DEVCONTAINER_IND" ]; then
  printf "%s%s%s" "${blue}" "⬡" "${sep}"
fi

printf "%s%s%s%s%s%s%s%s%s%s%s" \
  "${yellow}" "${DISPLAY_DIR}" \
  "${sep}" "${magenta}⎇ ${BRANCH}" \
  "${sep}" "${cyan}⧉  ${WORKTREE}" \
  "${sep}" "${light}${CTX} | ${MODEL_NAME}" \
  "${reset}"
