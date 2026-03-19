#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/workspace/final_summary.md"

if [ ! -f "$SRC" ]; then
  echo "[download] final_summary.md not found: $SRC"
  exit 1
fi

mkdir -p "$HOME/Downloads"
TS="$(date +%Y%m%d-%H%M%S)"
DEST="$HOME/Downloads/final_summary-$TS.md"

cp "$SRC" "$DEST"

echo "[download] copied to: $DEST"

if [[ "$OSTYPE" == "darwin"* ]]; then
  open -R "$DEST" >/dev/null 2>&1 || true
fi
