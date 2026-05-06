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

python3 -c "
import sys, json, math

data = json.load(sys.stdin)
cwd = data.get('cwd', '')
proj = data.get('workspace', {}).get('project_dir', '')

if cwd.startswith(proj):
    parts = cwd.split('/')
    display_dir = '/'.join(parts[-2:])
else:
    home = '$HOME'
    display_dir = cwd.replace(home, '~', 1)

usage = data.get('context_window', {}).get('current_usage')
if usage:
    current = sum(usage.get(k, 0) for k in ['input_tokens','output_tokens','cache_creation_input_tokens','cache_read_input_tokens'])
    max_ctx = data.get('context_window', {}).get('context_window_size', 1)
    pct = round(current * 100 / max_ctx * 10) / 10
    ctx = f'Ctx: {pct}%'
else:
    ctx = 'Ctx: N/A'

model = data.get('model', {})
model_name = model.get('display_name') or model.get('id', '')

C = '\033'
yellow  = f'{C}[33m'
magenta = f'{C}[35m'
cyan    = f'{C}[36m'
sep     = f'{C}[90m | '
light   = f'{C}[38;5;245m'
reset   = f'{C}[0m'

print(f'{yellow}{display_dir}{sep}{magenta}⎇ $BRANCH{sep}{cyan}⧉  $WORKTREE{sep}{light}{ctx} | {model_name}{reset}', end='')
"
