#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SESSION="agent-bridge"

mkdir -p "$ROOT/logs" "$ROOT/run" "$ROOT/workspace"
touch "$ROOT/logs/transcript.jsonl" "$ROOT/logs/events.log"

tmux has-session -t "$SESSION" 2>/dev/null && tmux kill-session -t "$SESSION"

tmux new-session -d -s "$SESSION" -n main
tmux split-window -h -t "$SESSION":0
tmux split-window -v -t "$SESSION":0.0
tmux split-window -v -t "$SESSION":0.1

# Pane 0: Claude
tmux send-keys -t "$SESSION":0.0 "cd '$ROOT' && echo 'Claude pane ready'" C-m

# Pane 1: Codex
tmux send-keys -t "$SESSION":0.1 "cd '$ROOT' && echo 'Codex pane ready'" C-m

# Pane 2: Relay
tmux send-keys -t "$SESSION":0.2 "cd '$ROOT' && python3 relay.py" C-m

# Pane 3: Transcript tail
tmux send-keys -t "$SESSION":0.3 "cd '$ROOT' && tail -f logs/transcript.jsonl" C-m

tmux select-pane -t "$SESSION":0.2
tmux attach -t "$SESSION"
