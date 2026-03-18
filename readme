# Agent Bridge

A terminal-native multi-agent system that orchestrates **Claude (strategy)** and **Codex (implementation)** in a structured, observable loop.

This project focuses on:

* iterative reasoning
* engineering decision loops
* full observability (streaming + logs + summaries)

---

# Core Idea

Instead of chatting with one model, this system runs:

relay → Claude → relay → Codex → relay → summarize → repeat

* Claude = strategic reasoning
* Codex = implementation validation
* relay.py = single orchestrator

All interactions are:

* streamed live
* logged structurally
* summarized incrementally

---

# Features

* Streaming agent output (real-time in terminal)
* Structured event logging (`transcript.jsonl`)
* Incremental decision memory (`decisions.md`)
* Final synthesis (`final_summary.md`)
* Human-in-the-loop injection (`human_note.md`)
* tmux dashboard for full observability

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
├── scripts/
│   ├── ask_claude.sh
│   ├── ask_codex.sh
│   ├── reset_task_state.sh
│   ├── new_task.sh
│   └── dashboard.sh
```

---

# How It Works

Each turn:

1. relay reads:

   * task.md
   * shared_context.md
   * decisions.md
   * human_note.md

2. Claude step

   * receives full context
   * outputs strategic analysis (streaming)

3. Codex step

   * receives Claude output + context
   * outputs implementation feedback (streaming)

4. relay updates:

   * decisions.md (compressed memory)
   * transcript.jsonl (full log)

5. loop continues until:

   * max_turns
   * STOP signal
   * error
   * convergence (disabled by default)

---

# Data Flow

```
task.md
   ↓
relay
   ↓
Claude (strategy)
   ↓
relay
   ↓
Codex (implementation)
   ↓
relay
   ↓
decisions.md + transcript.jsonl
```

---

# Running the System

## 1. Start a new task

```bash
bash scripts/new_task.sh
```

---

## 2. Launch dashboard

```bash
bash scripts/dashboard.sh
```

---

# Dashboard Layout

```
┌───────────────┬──────────────────────┐
│ relay         │ transcript           │
│ (streaming)   │ (event log)          │
├───────────────┼──────────────────────┤
│ human_note    │ final_summary        │
│ (edit live)   │ (final output)       │
└───────────────┴──────────────────────┘
```

---

# Human-in-the-loop Control

Edit:

```
workspace/human_note.md
```

Example:

```
Focus only on reliability issues
Avoid large refactors
Challenge config assumptions
```

Changes take effect on the **next turn**.

---

## Stop the system

Add a line:

```
STOP
```

---

# Streaming Output

relay uses `subprocess.Popen` to stream output:

```
========== TURN 1 ==========
[relay] sending prompt to Claude

<Claude streaming output>

[metrics] Claude: 2.14s | ~320 tokens

[relay] sending prompt to Codex

<Codex streaming output>

[metrics] Codex: 1.87s | ~280 tokens
```

---

# Logs

## transcript.jsonl

Structured event log:

```json
{
  "turn": 1,
  "from": "claude",
  "type": "response",
  "content": "..."
}
```

Includes:

* prompt
* response
* decision
* stop
* metrics

---

## decisions.md

Compressed working memory across turns.

Used as input for next iteration.

---

## final_summary.md

Final result:

* task
* stop reason
* decisions
* metrics

---

# Reset State

Before starting a new task:

```bash
bash scripts/reset_task_state.sh
```

---

# Writing Good Tasks

Bad:

```
Review the system
```

Good:

```
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

* file-based state (debuggable)
* deterministic control flow
* single orchestrator
* observable system behavior
* incremental convergence

---

# Limitations

* no parallel agents
* naive token estimation
* context growth not optimized
* convergence heuristic disabled

---

# Future Work

* context window management
* semantic summarization
* cost dashboard
* multi-agent parallelism
* task versioning

---

# Summary

Agent Bridge is not a chatbot.

It is a:

**terminal-native, observable, multi-agent reasoning system**

designed for engineering workflows.

---
