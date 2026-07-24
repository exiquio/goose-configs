# Goose Session State — Persistent Context

> Auto-loaded via MOIM every turn. Update after significant milestones.
> Last updated: 2026-07-24 11:30 +07:00

## Current Work

Config review complete — 8 issues identified and fixed, architecture verified against goose docs.

## Architecture Overview

- **goose-configs/** repo at ~/Code/Personal/goose-configs/ (git, on `main`)
- Symlinked to ~/.config/goose/ (config.yaml, goosehints)
- **Subagents:** devsecops, security_qa, software_engineer (live in agents/)
- **Extensions:** developer, analyze, todo, summon, notebooklm, skills, extensionmanager, tom, apps

## Delegation Enforcement (3 Layers)

1. **guardrails.md (MOIM-injected every turn)** — BEHAVIORAL. Cannot context-drift. Covers delegation invariant, failure protocol, process invariants (circuit breaker, diagnose-before-fixing, secret scanning), agent configuration, git protocol, task triage, domain boundaries, and session state.
1. **permission.yaml** — INTERACTIVE. smart_approve: shell/write/edit/delegate ask before.
1. **guardrails.md domain boundaries** — PERSISTENT. Injected every turn via MOIM. Maps every agent to its exclusive domain. Prevents misrouting (e.g., READMEs to software_engineer).

## Key Decisions

- Domain boundaries live in guardrails.md (MOIM-injected every turn), NOT just goosehints (loaded once, context-drifts). This prevents the "routing knowledge evaporates" failure mode.
- goosehints is instructional only (loaded once, context-drifted). All enforcement rules live in guardrails.md (MOIM-injected every turn).
- available_tools removed from config.yaml — delegation enforced solely via MOIM guardrails + permission.yaml
- config.rescue.yaml and make rescue/restore are now retired (no longer needed — config.yaml has no available_tools)
- Feature branches are LOCAL ONLY. Never push without explicit approval.
- Diagnose before fixing. Approve before merging.
- Gitleaks installed via Go, binary copied to ~/.local/bin (system method, not cargo — no crate exists)

## Completed

- [x] STATE.md created and merged to main (session state system live)
- [x] 8-check delegation verification (all passed)
- [x] Fixed broken YAML in config.yaml (restored available_tools key)
- [x] Main branch is clean, synced with origin/main
- [x] Rescue/restore symlink system tested and working
- [x] E2E write+cat pipeline confirmed working
- [x] Post-restart delegation verification (7/8 structural checks pass)
- [x] Fixed available_tools tool-name format (developer\_\_ prefix → plain names: tree, read_image, analyze)
- [x] Post-restart verification round 2 — removed available_tools from config.yaml, fixed symlink, retired rescue system
- [x] Post-restart verification round 3 — 5/5 checks passed, architecture confirmed stable
- [x] Config review (cross-referenced against goose docs) — 8 issues found and fixed:
  - [x] #1 permission.yaml moved into repo with symlink
  - [x] #2 stale 'cat' removed from permission.yaml tool list
  - [x] #3 goosehints updated (removed stale available_tools + PreToolUse hooks references)
  - [x] #4 retired rescue system fully removed (config.rescue.yaml + Makefile targets)
  - [x] #5 guardrails.md tool names fixed (developer__ prefix → plain names)
  - [x] #6 trailing 'test' artifact removed from security_qa.md
  - [x] #7 agent files replaced with directory symlink (~/.agents/agents/ → repo)
  - [x] #8 gitleaks verified installed (8.24.3, already present)
- [x] Switched technical_researcher to qwen3.6-flash (alibaba/dashscope providers)
- [x] Added qwen3.6-flash route to LiteLLM proxy (DashScope Singapore API)
- [x] Local delegation test passed (write/read/delete pipeline)
- [x] VM sync verified (agent file at ~/.agents/agents/technical_researcher.md, model confirmed)
- [x] Both repos committed and pushed (goose-configs: 57c8a3c, devops: ebb9d15)
- [x] Domain boundaries added to guardrails.md — technical_researcher explicitly owns READMEs, docs; impl agents FORBIDDEN from docs
- [x] guardrails.md expanded: 4 new sections (Process Invariants, Agent Configuration, Git Protocol, Task Triage) covering 21 previously missing rules
- [x] Cross-reference audit complete: 27 gaps found, 21 fixed (11 critical + 10 important), 6 cosmetic deferred
- [x] 5 READMEs written across all ~/Code/Personal repos

## Active Branches

- None (main is clean)

## Pending

- None — architecture reviewed and stable.
