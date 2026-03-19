#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/workspace/final_answers.md"

if [ ! -f "$SRC" ]; then
  echo "[download] final_answers.md not found: $SRC"
  exit 1
fi

mkdir -p "$HOME/Downloads"
TS="$(date +%Y%m%d-%H%M%S)"
DEST="$HOME/Downloads/final_answers-$TS.md"

cp "$SRC" "$DEST"

echo "[download] copied to: $DEST"

# macOS: reveal in Finder
if [[ "$OSTYPE" == "darwin"* ]]; then
  open -R "$DEST" >/dev/null 2>&1 || true
fi
