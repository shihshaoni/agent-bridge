#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cat > "$ROOT/workspace/decisions.md" <<'EOD'
# Decisions

No decisions yet.
EOD

cat > "$ROOT/workspace/human_note.md" <<'EOD'
# Human Note

Leave empty unless you want to guide the next round.
Write STOP on a line by itself to stop the relay.
EOD

: > "$ROOT/logs/transcript.jsonl"
: > "$ROOT/logs/events.log"

rm -f \
  "$ROOT/workspace/final_summary.md" \
  "$ROOT/run/relay_state.json" \
  "$ROOT"/run/*_prompt.txt

echo "Task state reset complete."
