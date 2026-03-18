#!/usr/bin/env bash
set -euo pipefail

PROMPT_FILE="${1:?prompt file required}"

claude --print < "$PROMPT_FILE"
