#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASK_FILE="$ROOT/workspace/task.md"

"$ROOT/scripts/reset_task_state.sh"

cat > "$TASK_FILE" <<'EOD'
# Task

Describe the new task here.

Constraints:
- Keep the answer practical
- Prefer incremental changes
- Final output should be in markdown
EOD

${EDITOR:-vim} "$TASK_FILE"
