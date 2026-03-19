#!/usr/bin/env bash
set -euo pipefail

PROMPT_FILE="${1:?prompt file required}"
cd "$(dirname "$0")/.."

gemini < "$PROMPT_FILE"
