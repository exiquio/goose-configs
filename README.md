# Goose Configs — Modular Agent Configuration Profiles

[![Goose CLI](https://img.shields.io/badge/Goose-CLI-8B5CF6)](https://block.github.io/goose/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A modular, multi-agent configuration system for the [Goose CLI](https://block.github.io/goose/) AI assistant framework. This repo implements a **Hub-and-Spoke multi-agent topology** where an **Engineering Lead** orchestrates four specialized sub-agents, each with a dedicated model, domain expertise, and tool permissions.

Design philosophy: **delegate everything, never go hands-on.** The Engineering Lead coordinates; sub-agents do the work. Dual enforcement (behavioral + interactive) ensures this invariant is never violated.

---

## Architecture

```
                    ┌──────────────────────────────────────┐
                    │          Engineering Lead             │
                    │     (goosehints / GOOSE_MOIM)         │
                    │  Orchestrates, Triage, Routes, Sign-Off│
                    └──────┬──────┬──────┬──────┬──────────┘
                           │      │      │      │
              ┌────────────┘      │      │      └────────────┐
              ▼                   ▼      ▼                   ▼
     ┌────────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────┐
     │   DevSecOps    │  │ Security QA│  │  Software  │  │  Technical   │
     │  deepseek-v4-  │  │ deepseek-  │  │  Engineer  │  │  Researcher  │
     │    flash       │  │  v4-pro    │  │ deepseek-  │  │ qwen3.6-flash│
     │                │  │            │  │  v4-flash  │  │              │
     │ infra, CI/CD,  │  │ BDS specs, │  │ code, apps,│  │ docs, arch,  │
     │ configs, env   │  │ security   │  │ scripts,   │  │ research,    │
     │                │  │ audits     │  │ tooling    │  │ writing      │
     └────────────────┘  └────────────┘  └────────────┘  └──────────────┘
```

### Agent Model Allocation

| Agent | Model | Provider | Role |
|-------|-------|----------|------|
| **Engineering Lead** *(orchestrator)* | — | — | Routes tasks, coordinates workflow, owns sign-off. Never implements directly. |
| **DevSecOps** | `deepseek-v4-flash` | custom_deepseek | Infrastructure, dotfiles, shell configs, CI/CD pipelines, environment provisioning, system dependencies |
| **Security QA** | `deepseek-v4-pro` | custom_deepseek | BDS specifications, security acceptance tests, threat models, security audit reports, validation |
| **Software Engineer** | `deepseek-v4-flash` | custom_deepseek | Application logic, scripts, libraries, tooling, git operations on source code |
| **Technical Researcher** | `qwen3.6-flash` | alibaba / dashscope | Primary research, whitepaper analysis, codebase exploration, architecture mapping, technical writing |

### Extension Restrictions by Agent

| Agent | Allowed Extensions | Blocked Extensions |
|-------|--------------------|--------------------|
| **Engineering Lead** | All (orchestrator) | — |
| **DevSecOps** | `developer`, `analyze`, `todo` | `summon`, `notebooklm`, `apps`, `skills`, `extensionmanager`, `tom` |
| **Security QA** | `developer`, `analyze`, `todo` | `summon`, `notebooklm`, `apps`, `skills`, `extensionmanager`, `tom` |
| **Software Engineer** | `developer`, `analyze`, `todo` | `summon`, `notebooklm`, `apps`, `skills`, `extensionmanager`, `tom` |
| **Technical Researcher** | `developer`, `analyze`, `todo`, `notebooklm` | `summon`, `apps`, `skills`, `extensionmanager`, `tom` |

---

## Repository Structure

```
goose-configs/
├── agents/                    # Agent profile definitions
│   ├── _policies.md          # Shared agent protocols (Git workflow, output format, diagnose-before-fixing)
│   ├── devsecops.md          # DevSecOps agent — frontmatter: name, model, description, extension restrictions
│   ├── security_qa.md        # Security QA agent — model: deepseek-v4-pro (premium for audits)
│   ├── software_engineer.md  # Software Engineer agent — model: deepseek-v4-flash
│   └── technical_researcher.md # Technical Researcher agent — model: qwen3.6-flash
├── config.yaml               # Goose CLI configuration: extensions, providers, models
├── goosehints                # Engineering Lead orchestrator definition (workflow, delegation, git protocol)
├── guardrails.md             # MOIM-injected behavioral enforcement (NEVER use shell/write/edit directly)
├── permission.yaml           # Tool-level authorization (smart_approve with allow/deny lists)
├── STATE.md                  # Persistent session state — auto-loaded via MOIM every turn
├── Makefile                  # install, validate, test, check targets
└── README.md                 # This file
```

---

## Key Features

### 1. Hub-and-Spoke Multi-Agent Topology
A single **Engineering Lead** agent orchestrates four domain-expert sub-agents. The Lead plans, triages, routes, coordinates, and signs off — but **never** implements directly. All code, configs, tests, and documentation are delegated to the appropriate sub-agent.

### 2. Dual Enforcement (Behavioral + Interactive)
Two layers prevent the Engineering Lead from violating the delegation invariant:

| Layer | File | Mechanism | Scope |
|-------|------|-----------|-------|
| **Behavioral** | `guardrails.md` | MOIM-injected persistent instructions loaded every turn via `GOOSE_MOIM_MESSAGE_FILE` | Engineering Lead only |
| **Interactive** | `permission.yaml` | `smart_approve` tool-level authorization — `shell`, `write`, `edit` always prompt for approval | Engineering Lead only |

`guardrails.md` states: *"You MUST delegate ALL implementation tasks to subagents. You MUST NEVER use shell, write, edit, or text_editor directly."* If a subagent fails, the protocol is: retry with refined instructions → switch agents → escalate. **Never go hands-on.**

### 3. Behavior-Driven Security (BDS) Workflow
Security acceptance tests and misuse/abuse scenarios are written **before** implementation begins. `security_qa` produces BDS specs that define functional boundaries, invariants, and threat models. Implementation only starts after BDS specs are approved.

### 4. Git Workflow with Safety Checks
- **Feature branches are LOCAL ONLY** — never pushed to origin without explicit approval
- Pre-commit secret scanning via `gitleaks` (or manual grep)
- Diagnose-before-fixing protocol: gather evidence → report root cause → confirm → fix
- Never merge without explicit Lead approval (merge, merge without rebase, or don't merge)
- Multi-repo dependency ordering (merge source repos before consumers)

### 5. Standardized Output Format
Every agent returns results in a structured format:

```
┌────────────────────────────────────────────┐
│  Summary     ✅/⚠️/❌ + 1-2 sentence       │
│  Artifacts   Files changed/created/deleted │
│  Validation  How the change was verified   │
│  Issues/     Known issues, risks, edge     │
│    Risks     cases                         │
│  Next Steps  Actionable next items or      │
│              "None — ready for sign-off"   │
└────────────────────────────────────────────┘
```

### 6. Parallel Execution
Independent tasks that touch different files can run in parallel via `delegate(async: true, ...)`. Results are collected with `load(source: "<taskId>")`. This speeds up the workflow significantly for multi-file changes.

### 7. Continuity & Session State
`STATE.md` maintains persistent session context across Goose sessions. It's auto-loaded every turn via MOIM (`GOOSE_MOIM_MESSAGE_FILE`). A **Continuation Prompt** format allows seamless handoff between sessions or when switching thinking effort modes.

### 8. Thinking Effort Mode Switching
The `agentic-team` fish function supports two modes:

| Mode | Command | Thinking Effort | Best For |
|------|---------|-----------------|----------|
| **light** | `agentic-team light` | `low` | Simple tasks, config tweaks, quick fixes, trivial triage |
| **heavy** | `agentic-team heavy` | `max` | Complex architecture, security audits, debugging, multi-system reasoning |

---

## Setup

### Prerequisites
- [Goose CLI](https://block.github.io/goose/) installed
- Git
- Make

### Installation

```bash
# Clone the repository
git clone https://github.com/exiquio/goose-configs.git ~/Code/Personal/goose-configs

# Navigate to the repo
cd ~/Code/Personal/goose-configs

# Create symlinks — links repo files to ~/.config/goose/ and ~/.agents/
make install
```

### Symlink Structure

`make install` creates the following symlinks:

```
~/.config/goose/
├── config.yaml    → ~/Code/Personal/goose-configs/config.yaml
└── goosehints     → ~/Code/Personal/goose-configs/goosehints

~/.agents/
└── agents/        → ~/Code/Personal/goose-configs/agents/
```

This means you edit files **in the repo** and the changes take effect immediately. No manual copy operations needed.

### Validation

```bash
# Validate all agent profiles for structural correctness
make validate

# Run full test suite (validation + future regression tests)
make test

# Pre-push checks (branch validation, structural checks)
make check
```

The `validate` target checks every agent profile for:
- YAML frontmatter (`---` delimiter)
- `name:` field
- `model:` field
- `## Output Format` section
- `## Summary` in output format
- `Diagnose before fixing` directive (warning if missing)

---

## Workflow

The Engineering Lead follows an 8-step workflow for every task (with shortcuts for trivial items):

```
┌─────────────────────────────────────────────────────────┐
│                     WORKFLOW                            │
├─────────────────────────────────────────────────────────┤
│  1. Intake & Planning                                    │
│     → Analyze requirements, assess complexity            │
│     → Determine triage level (trivial / standard / complex)│
│                                                         │
│  ┌─ Trivial ──────────────────────────────────────┐    │
│  │ Aliases, one-line config tweaks, dotfile edits │    │
│  │ Delegate → Sign-Off (skip research, skip BDS)  │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
│  ┌─ Standard / Complex ───────────────────────────┐    │
│  │  2. Research & Specification                    │    │
│  │     → Delegate to technical_researcher          │    │
│  │     → Reads docs, maps architecture, produces   │    │
│  │       structured specs                          │    │
│  │                                                 │    │
│  │  3. BDS Specification                           │    │
│  │     → Delegate to security_qa                   │    │
│  │     → Security acceptance tests, invariants,    │    │
│  │       misuse/abuse scenarios                    │    │
│  │                                                 │    │
│  │  4. Implementation                              │    │
│  │     → Delegate to software_engineer (code) or   │    │
│  │       devsecops (infra/configs)                 │    │
│  │     → Build from researcher specs + BDS specs   │    │
│  │                                                 │    │
│  │  5. Validation                                  │    │
│  │     → Delegate to security_qa                   │    │
│  │     → Execute tests, audit against BDS specs    │    │
│  │     → Return findings with error details        │    │
│  │                                                 │    │
│  │  6. Iterate (4 ↔ 5 until pass)                  │    │
│  │     → Route findings back to implementer        │    │
│  │     → Repeat until all tests pass               │    │
│  │                                                 │    │
│  │  7. Documentation (when applicable)             │    │
│  │     → Delegate to technical_researcher          │    │
│  │     → Update reference docs, architecture docs  │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
│  8. Sign-Off                                            │
│     → Present final, verified solution to user          │
│     → Await merge decision                              │
└─────────────────────────────────────────────────────────┘
```

### Agent Selection Guide

| Domain | Agent |
|--------|-------|
| Code, applications, scripts, libraries, tooling, git operations on source code | **software_engineer** |
| Infrastructure, dotfiles, shell configs, CI/CD, environment provisioning, system dependencies | **devsecops** |
| Whitepaper analysis, documentation reading, codebase exploration, architecture mapping, technical writing, audit reports | **technical_researcher** |
| Test writing, security auditing, BDS specifications, validation, threat modeling | **security_qa** |

### Critical Rules

1. **Delegate everything.** The Engineering Lead never uses `shell`, `write`, or `edit` directly. Even a one-line config tweak must be delegated.
2. **Diagnose before fixing.** Gather evidence, report root cause, confirm with Lead, then fix. Never propose a fix before confirming the root cause.
3. **Feature branches are LOCAL ONLY.** Never push to origin without explicit approval.
4. **Never merge without approval.** Present test results first, then wait for the user to decide.
5. **Multi-repo dependency ordering.** When work spans multiple repos, merge source repos (the ones being read/copied FROM) before consumer repos.
6. **Secret scan before staging.** Use `gitleaks detect --no-git` or manual `grep` for credentials, API keys, private keys before every commit.

---

## Core Files Reference

| File | Purpose | Enforcement Layer |
|------|---------|-------------------|
| `config.yaml` | Goose CLI configuration — extensions, providers, active model | Config |
| `goosehints` | Engineering Lead orchestrator definition — workflow, delegation, git protocol, domain boundaries | Instructional |
| `guardrails.md` | MOIM-injected behavioral enforcement — "NEVER use shell/write/edit" | **Behavioral** |
| `permission.yaml` | Tool-level authorization — `smart_approve` with allow/deny/ask lists | **Interactive** |
| `STATE.md` | Persistent session state — milestones, decisions, active branches, pending items | Session |
| `agents/_policies.md` | Shared agent protocols — git workflow, output format, diagnose-before-fixing | Policy |
| `Makefile` | Automation — `install` (symlinks), `validate` (profile checks), `check` (pre-push) | Tooling |

---

## Configuration Details

### Extensions (config.yaml)

| Extension | Enabled | Type | Purpose |
|-----------|---------|------|---------|
| `developer` | ✅ | builtin | Write/edit files, execute shell commands |
| `analyze` | ✅ | platform | Code structure analysis with tree-sitter |
| `todo` | ✅ | platform | Task tracking and progress notes |
| `summon` | ✅ | platform | Load knowledge and delegate to subagents |
| `notebooklm` | ✅ | stdio | Query NotebookLM workspaces for domain knowledge |
| `skills` | ✅ | platform | Discover and provide skill instructions |
| `extensionmanager` | ✅ | platform | Discover, enable, disable extensions |
| `tom` | ✅ | platform | MOIM-injected persistent context (`GOOSE_MOIM_MESSAGE_TEXT`, `GOOSE_MOIM_MESSAGE_FILE`) |
| `apps` | ✅ | platform | Create and manage custom Goose apps (HTML/CSS/JS) |
| `code_execution` | ❌ | platform | Code execution mode (disabled for security) |
| `summarize` | ❌ | platform | File/directory summarization |
| `chatrecall` | ❌ | platform | Search past conversations |
| `orchestrator` | ❌ | platform | Agent session management |

### Providers

| Provider | Model | Purpose |
|----------|-------|---------|
| `custom_deepseek` | `deepseek-v4-pro` | Primary — Engineering Lead + Security QA |
| `dashscope` | `qwen3.6-flash` | Secondary — Technical Researcher |
| `alibaba` | `qwen3.6-flash` | Fallback — Technical Researcher |

---

## License

MIT

---

## Related Repositories

- [web3-security/devops](https://github.com/exiquio/web3-security) — Consumer repo that rsyncs agent profiles from here via Makefile. Merge `goose-configs` first, then `web3-security`.
