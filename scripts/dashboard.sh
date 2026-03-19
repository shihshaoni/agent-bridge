#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SESSION="agent-bridge"
MODE="${1:-default}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -c "$ROOT"
tmux rename-window -t "$SESSION" "dashboard"

# Build 4 panes
tmux split-window -h -t "$SESSION":0
tmux split-window -v -t "$SESSION":0.0
tmux split-window -v -t "$SESSION":0.1

tmux select-layout -t "$SESSION":0 tiled

PANES=($(tmux list-panes -t "$SESSION":0 -F "#{pane_id}"))

# Pane 0: relay
tmux send-keys -t "${PANES[0]}" "cd '$ROOT' && python3 relay.py" C-m

# Pane 1: transcript
tmux send-keys -t "${PANES[1]}" "cd '$ROOT' && touch logs/transcript.jsonl && tail -F logs/transcript.jsonl" C-m

# Pane 2: human_note editor
tmux send-keys -t "${PANES[2]}" "cd '$ROOT' && \${EDITOR:-vim} workspace/human_note.md" C-m

# Pane 3: mode-specific
if [ "$MODE" = "gemini" ]; then
  if command -v jq >/dev/null 2>&1; then
    tmux send-keys -t "${PANES[3]}" \
      "cd '$ROOT' && touch logs/transcript.jsonl && tail -F logs/transcript.jsonl | jq -r 'select(.from==\"gemini\" or .to==\"gemini\") | \"\\(.ts) [\\(.type)] \\(.from) -> \\(.to)\\n\\(.content)\\n---\"'" \
      C-m
  else
    tmux send-keys -t "${PANES[3]}" \
      "cd '$ROOT' && touch logs/transcript.jsonl && grep --line-buffered gemini < <(tail -F logs/transcript.jsonl)" \
      C-m
  fi
else
  tmux send-keys -t "${PANES[3]}" "cd '$ROOT'" C-m
  tmux send-keys -t "${PANES[3]}" "echo 'Control pane (commands / experiments)'" C-m
  tmux send-keys -t "${PANES[3]}" "echo ''" C-m
  tmux send-keys -t "${PANES[3]}" "echo 'Examples:'" C-m
  tmux send-keys -t "${PANES[3]}" "echo '  bash scripts/reset_task_state.sh'" C-m
  tmux send-keys -t "${PANES[3]}" "echo '  bash scripts/new_task.sh'" C-m
  tmux send-keys -t "${PANES[3]}" "echo '  python3 relay.py'" C-m
  tmux send-keys -t "${PANES[3]}" "echo '  cat workspace/final_summary.md'" C-m
fi

tmux attach -t "$SESSION"