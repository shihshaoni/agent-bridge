import json
import subprocess
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).parent
WORKSPACE = ROOT / "workspace"
LOGS = ROOT / "logs"
RUN = ROOT / "run"
SCRIPTS = ROOT / "scripts"

MAX_TURNS = 3  # TODO: wire config.yaml later

def now():
    return datetime.now().astimezone().isoformat()


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def append_jsonl(path: Path, obj: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(obj, ensure_ascii=False) + "\n")


def log_event(turn: int, src: str, dst: str, typ: str, content: str) -> None:
    append_jsonl(
        LOGS / "transcript.jsonl",
        {
            "ts": now(),
            "turn": turn,
            "from": src,
            "to": dst,
            "type": typ,
            "content": content,
        },
    )


def write_state(state: dict) -> None:
    write_text(RUN / "relay_state.json", json.dumps(state, ensure_ascii=False, indent=2))


def call_agent(script_name: str, prompt: str) -> str:
    prompt_file = RUN / f"{script_name}_prompt.txt"
    write_text(prompt_file, prompt)

    result = subprocess.run(
        [str(SCRIPTS / script_name), str(prompt_file)],
        capture_output=True,
        text=True,
        check=False,
    )

    if result.returncode != 0:
        return f"[ERROR_EXIT={result.returncode}]\n{result.stderr.strip() or result.stdout.strip()}"
    return result.stdout.strip()


def truncate(text: str, limit: int = 1200) -> str:
    text = text.strip()
    if len(text) <= limit:
        return text
    return text[:limit] + "\n...[truncated]"


def build_claude_prompt(task: str, shared: str, decisions: str, human_note: str, codex_feedback: str | None) -> str:
    extra = f"\nLatest Codex feedback:\n{codex_feedback}\n" if codex_feedback else ""
    note = f"\nHuman note:\n{human_note}\n" if human_note.strip() else ""
    return f"""You are acting as a strategic reviewer.

Task:
{task}

Shared Context:
{shared}

Current Decisions:
{decisions}
{note}
{extra}

Please answer in this structure:
1. Most important subproblem
2. Concise plan
3. Key risks
4. What Codex should verify next

Keep it concrete and concise.
"""


def build_codex_prompt(task: str, shared: str, decisions: str, human_note: str, claude_output: str) -> str:
    note = f"\nHuman note:\n{human_note}\n" if human_note.strip() else ""
    return f"""You are acting as an implementation-oriented reviewer.

Task:
{task}

Shared Context:
{shared}

Current Decisions:
{decisions}
{note}

Claude's latest analysis:
{claude_output}

Please answer in this structure:
1. Feasibility check
2. Missing technical details
3. Concrete implementation or testing steps
4. What Claude should refine next

Keep it concrete and concise.
"""


def summarize_round(turn: int, previous: str, claude_output: str, codex_output: str) -> str:
    section = f"""

## Round {turn}

### Claude
{truncate(claude_output, 800)}

### Codex
{truncate(codex_output, 800)}
"""
    return previous.rstrip() + section + "\n"


def converged(claude_output: str, codex_output: str) -> bool:
    return False


def has_stop_signal(human_note: str) -> bool:
    lines = [line.strip() for line in human_note.splitlines()]
    return "STOP" in lines

def main() -> None:
    transcript_path = (LOGS / "transcript.jsonl").resolve()

    print("\n========== RELAY START ==========", flush=True)
    print(f"[relay] transcript file: {transcript_path}", flush=True)
    print("=================================\n", flush=True)

    task = read_text(WORKSPACE / "task.md").strip()

def main():
    task = read_text(WORKSPACE / "task.md").strip()
    shared = read_text(WORKSPACE / "shared_context.md").strip()
    decisions = read_text(WORKSPACE / "decisions.md").strip()

    if not task:
        print("workspace/task.md is empty")
        return

    codex_feedback = None
    stopped_reason = None

    for turn in range(1, MAX_TURNS + 1):
        human_note = read_text(WORKSPACE / "human_note.md").strip()

        state = {
            "current_turn": turn,
            "status": "running",
            "last_agent": None,
            "converged": False,
            "stop_reason": None,
        }
        write_state(state)

        if has_stop_signal(human_note):
            stopped_reason = "human_stop"
            log_event(turn, "relay", "system", "stop", "Stopped by human note")
            break

        claude_prompt = build_claude_prompt(task, shared, decisions, human_note, codex_feedback)
        log_event(turn, "relay", "claude", "prompt", claude_prompt)
        state["last_agent"] = "claude"
        write_state(state)

        claude_output = call_agent("ask_claude.sh", claude_prompt)
        log_event(turn, "claude", "relay", "response", claude_output)

        codex_prompt = build_codex_prompt(task, shared, decisions, human_note, claude_output)
        log_event(turn, "relay", "codex", "prompt", codex_prompt)
        state["last_agent"] = "codex"
        write_state(state)

        codex_output = call_agent("ask_codex.sh", codex_prompt)
        log_event(turn, "codex", "relay", "response", codex_output)

        decisions = summarize_round(turn, decisions, claude_output, codex_output)
        write_text(WORKSPACE / "decisions.md", decisions)
        log_event(turn, "relay", "system", "decision", f"Updated decisions for turn {turn}")

        if claude_output.startswith("[ERROR") or codex_output.startswith("[ERROR"):
            stopped_reason = "agent_error"
            log_event(turn, "relay", "system", "stop", "Stopped because of agent error")
            break

        if converged(claude_output, codex_output):
            stopped_reason = "converged"
            state["converged"] = True
            write_state(state)
            log_event(turn, "relay", "system", "stop", "Converged")
            break

        codex_feedback = truncate(codex_output, 1200)

    if stopped_reason is None:
        stopped_reason = "max_turns"

    final_summary = f"""# Final Summary

## Task
{task}

## Stop Reason
{stopped_reason}

## Decisions
{decisions}
"""
    write_text(WORKSPACE / "final_summary.md", final_summary)

    final_state = {
        "current_turn": turn if "turn" in locals() else 0,
        "status": "stopped",
        "last_agent": None,
        "converged": stopped_reason == "converged",
        "stop_reason": stopped_reason,
    }
    write_state(final_state)

    print(final_summary)


if __name__ == "__main__":
    main()
