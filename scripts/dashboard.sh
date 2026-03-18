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

# === 建立 4 個 pane（先不要填內容） ===

# 0: first pane already exists
tmux split-window -h -t "$SESSION":0      # → pane 1
tmux split-window -v -t "$SESSION":0.0    # → pane 2
tmux split-window -v -t "$SESSION":0.1    # → pane 3

# layout
tmux select-layout -t "$SESSION":0 tiled

# === 現在重新抓 pane id（非常重要） ===
PANES=($(tmux list-panes -t "$SESSION":0 -F "#{pane_id}"))

# === 分配角色 ===
# pane 0: relay
tmux send-keys -t "${PANES[0]}" "cd '$ROOT' && python3 relay.py" C-m

# pane 1: transcript
tmux send-keys -t "${PANES[1]}" "cd '$ROOT' && tail -F logs/transcript.jsonl" C-m

# pane 2: human_note editor
tmux send-keys -t "${PANES[2]}" "cd '$ROOT' && \${EDITOR:-vim} workspace/human_note.md" C-m

# pane 3: final summary
tmux send-keys -t "${PANES[3]}" "cd '$ROOT' && touch workspace/final_summary.md && tail -F workspace/final_summary.md" C-m

tmux attach -t "$SESSION"
