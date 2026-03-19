# Agent Bridge

A terminal-native multi-agent system: **Claude (strategy)** + **Codex (implementation)** + **Gemini (cross-review)**, orchestrated by `relay.py` in a structured, observable loop.

---

# How It Works

```
relay → Claude → Codex → Gemini → decisions.md → repeat
```

Each turn, relay reads `task.md`, `shared_context.md`, `decisions.md`, `human_note.md`, calls Claude then Codex then Gemini, and updates `decisions.md`. After all turns, each agent independently writes a final answer. Loop ends on `max_turns`, `STOP`, agent error, or convergence.

### Agent Roles

| Agent | Role |
|-------|------|
| **Claude** | Strategic reviewer — identifies key subproblems, plans, and risks |
| **Codex** | Implementation reviewer — feasibility checks, technical details, concrete steps |
| **Gemini** | Cross-reviewer — identifies agreement/disagreement, weak points, decides if another turn is needed |

---

# Quick Start

```bash
bash scripts/new_task.sh              # set up task
bash scripts/dashboard.sh             # launch tmux dashboard (default mode)
bash scripts/dashboard.sh gemini      # launch tmux dashboard (gemini-focused mode)
bash scripts/reset_task_state.sh      # reset before new task
bash scripts/bootstrap_tmux.sh        # alternative: start tmux + relay directly
```

---

# Dashboard Layout

```
┌───────────────┬──────────────────────┐
│ relay         │ transcript           │
│ (streaming)   │ (event log tail)     │
├───────────────┼──────────────────────┤
│ human_note    │ control / gemini log │
│ (edit live)   │ (commands / tests)   │
└───────────────┴──────────────────────┘
```

In `gemini` mode, the bottom-right pane streams only Gemini-related events from the transcript.

---

# Human-in-the-loop

Edit `workspace/human_note.md` to inject guidance mid-run. Changes take effect on the next turn. Add `STOP` on its own line to halt.

---

# Project Structure

```
agent-bridge/
├── relay.py
├── config.yaml
├── workspace/
│   ├── task.md
│   ├── task_template.md
│   ├── shared_context.md
│   ├── decisions.md
│   ├── human_note.md
│   ├── final_answers.md
│   └── final_summary.md
├── logs/
│   ├── transcript.jsonl
│   └── events.log
├── run/
│   ├── relay_state.json
│   └── *_prompt.txt
└── scripts/
    ├── ask_claude.sh
    ├── ask_codex.sh
    ├── ask_gemini.sh
    ├── reset_task_state.sh
    ├── new_task.sh
    ├── dashboard.sh
    ├── bootstrap_tmux.sh
    ├── render_transcript.py
    ├── download_final_summary.sh
    └── download_final_answers.sh
```

---

# Logs & Outputs

| File | Content |
|------|---------|
| `transcript.jsonl` | Structured event log (prompt / response / decision / metrics) |
| `decisions.md` | Compressed working memory, fed into next turn |
| `final_answers.md` | Each agent's independent final answer to the task |
| `final_summary.md` | Task, stop reason, decisions, and all final answers |
| `run/relay_state.json` | Current relay state (turn, status, last agent, stop reason) |

```bash
# Render transcript as readable markdown
python3 scripts/render_transcript.py

# Download results to ~/Downloads (macOS: reveals in Finder)
bash scripts/download_final_summary.sh
bash scripts/download_final_answers.sh
```

---

# Writing Good Tasks

Use `workspace/task_template.md` as a starting point. Example:

```markdown
# Task
Identify the top 3 reliability risks in relay.py

## Context
- Project type: agent orchestration system
- Current state: working prototype

## Constraints
- Avoid large rewrites
- Focus on production issues

## Output Requirements
- Ranked list with minimal fixes
```

---

# Configuration

`config.yaml` defines file paths and agent roles:

```yaml
max_turns: 3
claude_role: strategic_reviewer
codex_role: implementation_reviewer
transcript_file: logs/transcript.jsonl
state_file: run/relay_state.json
```

> Note: `relay.py` currently uses `MAX_TURNS = 3` directly. `config.yaml` wiring is planned.

---

# Design Principles

file-based state · deterministic control flow · single orchestrator · full observability · incremental convergence

---

# Limitations & Future Work

**Now:** `config.yaml` not yet wired into `relay.py`, naive token truncation, no context window management, convergence check always returns false.

**Planned:** semantic summarization, cost dashboard, multi-agent parallelism, task versioning, config.yaml integration.
