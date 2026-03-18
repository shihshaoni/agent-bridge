#!/usr/bin/env bash
set -euo pipefail

PROMPT_FILE="${1:?prompt file required}"
cd "$(dirname "$0")/.."

codex exec --skip-git-repo-check - < "$PROMPT_FILE"
