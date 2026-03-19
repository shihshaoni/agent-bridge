#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[reset] resetting runtime state..."

# logs
mkdir -p "$ROOT/logs"
: > "$ROOT/logs/transcript.jsonl"

# workspace (保留 task.md)
mkdir -p "$ROOT/workspace"
: > "$ROOT/workspace/decisions.md"
: > "$ROOT/workspace/final_summary.md"
: > "$ROOT/workspace/human_note.md"

# run artifacts
rm -rf "$ROOT/run"
mkdir -p "$ROOT/run"

echo "[reset] done"
echo "[reset] task.md preserved"
