# Agent Bridge

A terminal-native multi-agent system: **Claude (strategy)** + **Codex (implementation)**, orchestrated by `relay.py` in a structured, observable loop.

---

# How It Works

```
relay → Claude → relay → Codex → relay → decisions.md + transcript.jsonl → repeat
```

Each turn, relay reads `task.md`, `shared_context.md`, `decisions.md`, `human_note.md`, calls Claude then Codex, and updates state. Loop ends on `max_turns`, `STOP`, error, or convergence.

---

# Quick Start

```bash
bash scripts/new_task.sh       # set up task
bash scripts/dashboard.sh      # launch tmux dashboard
bash scripts/reset_task_state.sh  # reset before new task
```

---

# Dashboard Layout

```
┌───────────────┬──────────────────────┐
│ relay         │ transcript           │
│ (streaming)   │ (event log)          │
├───────────────┼──────────────────────┤
│ human_note    │ control              │
│ (edit live)   │ (commands / tests)   │
└───────────────┴──────────────────────┘
```

---

# Human-in-the-loop

Edit `workspace/human_note.md` to inject guidance mid-run. Changes take effect on the next turn. Add `STOP` to halt.

---

# Project Structure

```
agent-bridge/
├── relay.py
├── workspace/
│   ├── task.md
│   ├── shared_context.md
│   ├── decisions.md
│   ├── human_note.md
│   └── final_summary.md
├── logs/
│   └── transcript.jsonl
├── run/
│   └── *_prompt.txt
└── scripts/
    ├── ask_claude.sh
    ├── ask_codex.sh
    ├── reset_task_state.sh
    ├── new_task.sh
    └── dashboard.sh
```

---

# Logs

| File | Content |
|------|---------|
| `transcript.jsonl` | Structured event log (prompt / response / decision / metrics) |
| `decisions.md` | Compressed working memory, fed into next turn |
| `final_summary.md` | Task result, stop reason, decisions, metrics |

---

# Writing Good Tasks

```markdown
# Task
Identify the top 3 reliability risks in relay.py

Constraints:
- Avoid large rewrites
- Focus on production issues

Output:
- ranked list
- minimal fixes
```

---

# Design Principles

file-based state · deterministic control flow · single orchestrator · full observability · incremental convergence

# Limitations & Future Work

**Now:** no parallel agents, naive token estimation, no context window management.
**Planned:** semantic summarization, cost dashboard, multi-agent parallelism, task versioning.
