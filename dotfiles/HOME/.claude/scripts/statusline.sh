#!/bin/bash
# Claude Code statusLine script
# Displays: owner/repo | ⎇ branch[*] | Ctx: X.X% | Model
# (owner/repo is an OSC 8 hyperlink on the host, a raw URL inside devcontainers;
#  branch has a trailing * when running inside a non-main worktree)

BRANCH=$(git branch --show-current 2>/dev/null || echo "-")

WORKTREE_MARK=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  MAIN_WORKTREE=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
  CURRENT_WORKTREE=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$MAIN_WORKTREE" ] && [ "$CURRENT_WORKTREE" != "$MAIN_WORKTREE" ]; then
    WORKTREE_MARK="*"
  fi
fi

input=$(cat)

REMOTE_URL=$(git remote get-url origin 2>/dev/null)
if [ -n "$REMOTE_URL" ]; then
  REPO_PATH=$(echo "$REMOTE_URL" | sed -E 's#^git@[^:]+:##; s#^https?://[^/]+/##; s#\.git$##')
  REPO_HOST=$(echo "$REMOTE_URL" | sed -E 's#^git@([^:]+):.*#\1#; s#^https?://([^/]+)/.*#\1#')
  DISPLAY_DIR="${REPO_PATH}"
  REPO_URL="https://${REPO_HOST}/${REPO_PATH}"
else
  CWD=$(echo "$input" | jq -r '.cwd // ""')
  DISPLAY_DIR=$(echo "$CWD" | awk -F/ '{print $(NF-1)"/"$NF}')
  REPO_URL=""
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
sep="${C}[90m | "
light="${C}[38;5;245m"
red="${C}[38;5;210m"
reset="${C}[0m"

MODEL_COLOR="${light}"
if echo "$MODEL_NAME" | grep -qi "fable"; then
  MODEL_COLOR="${red}"
fi

if [ -n "$DEVCONTAINER_IND" ]; then
  printf "%s%s%s" "${blue}" "⬡" "${sep}"
fi

# OSC 8 hyperlinks are stripped from statusLine output inside devcontainers
# (works on the host), so fall back to showing the raw URL there.
if [ -n "$REPO_URL" ] && [ -n "$DEVCONTAINER_IND" ]; then
  LINKED_DIR="${REPO_URL}"
elif [ -n "$REPO_URL" ]; then
  LINKED_DIR="${C}]8;;${REPO_URL}${C}\\${DISPLAY_DIR}${C}]8;;${C}\\"
else
  LINKED_DIR="${DISPLAY_DIR}"
fi

printf "%s%s%s%s%s%s%s" \
  "${yellow}" "${LINKED_DIR}" \
  "${sep}" "${magenta}⎇ ${BRANCH}${WORKTREE_MARK}" \
  "${sep}" "${light}${CTX} | ${MODEL_COLOR}${MODEL_NAME}" \
  "${reset}"
