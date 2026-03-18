#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SESSION="agent-bridge"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -c "$ROOT"
tmux rename-window -t "$SESSION" "dashboard"

# === 建立 4 個 pane ===
tmux split-window -h -t "$SESSION":0
tmux split-window -v -t "$SESSION":0.0
tmux split-window -v -t "$SESSION":0.1

# layout
tmux select-layout -t "$SESSION":0 tiled

# 抓 pane id
PANES=($(tmux list-panes -t "$SESSION":0 -F "#{pane_id}"))

# === 分配 ===

# 左上：relay
tmux send-keys -t "${PANES[0]}" "cd '$ROOT' && python3 relay.py" C-m

# 右上：transcript
tmux send-keys -t "${PANES[1]}" "cd '$ROOT' && tail -F logs/transcript.jsonl" C-m

# 左下：human_note editor
tmux send-keys -t "${PANES[2]}" "cd '$ROOT' && \${EDITOR:-vim} workspace/human_note.md" C-m

# 右下：空白（控制用）
tmux send-keys -t "${PANES[3]}" "cd '$ROOT'" C-m
tmux send-keys -t "${PANES[3]}" "echo 'Control pane (commands / experiments)'" C-m

tmux attach -t "$SESSION"
