# Agent Policies

This file is the canonical source for shared agent protocols. Changes here must be reflected in all agent profiles. Use `make validate` to check consistency.

## Git Workflow

**CRITICAL: Never commit directly to `main`. Always use feature branches.**
**CRITICAL: Feature branches are LOCAL ONLY. Never push them to origin unless explicitly asked by name.**

1. `git switch -c <descriptive-branch-name>` — create and switch to a feature branch
2. Make edits and test
3. **Secret scan** — Before staging, scan changed files for leaked secrets (private keys, API tokens, passwords, credentials). Use `gitleaks detect --no-git` if available; otherwise manual grep: `grep -rnE '(-----BEGIN|sk-|ghp_|gho_|ghu_|ghs_|ghr_|xox[baprs]-|AIza[0-9A-Za-z_-]{35}|AKIA[0-9A-Z]{16})' <changed files>`. If any secrets are found, STOP — do not commit, alert the Lead immediately.
4. `git add <files>` — stage changes
5. `git commit -m "<message>"` — commit on the branch
6. **Test and report results to the Engineering Lead** — do NOT rebase or merge yet
7. **Wait for the Lead's decision:**
   - `"merge"` → rebase on main, merge, push main, delete branch
   - `"merge without rebase"` → merge as-is (preserve commit history, e.g., for code audits), push main, delete branch
   - `"don't merge"` / no response → stop, keep branch as-is

**Merge commands (after approval):**
```
# Standard merge (rebase + merge):
git rebase main
git switch main
git merge <branch-name>
git push origin main
git branch -d <branch-name>

# Merge without rebase (preserve history):
git switch main
git merge <branch-name>
git push origin main
git branch -d <branch-name>
```

**Diagnose before fixing:** NEVER propose or implement a fix before first confirming the root cause.

**Approval before merge:** NEVER merge without explicit Lead approval. Present test results first, then wait.

## Standardized Output Format

All agents MUST return results in this structure:

```
## Summary
[1-2 sentence summary of what was done]

## Artifacts
- [file path]: [what changed]
- [file path]: [what changed]

## Validation
[How the change was verified — tests run, checks performed, evidence]

## Issues / Risks
- [severity]: [description]
- [severity]: [description]

## Next Steps
- [actionable next item or "None — ready for sign-off"]
```

**Status field:** First line of Summary should include status: `✅` (success), `⚠️` (partial), or `❌` (failure).

## Diagnose-Before-Fixing Protocol

1. **Investigate** — gather evidence, read logs, check state
2. **Report** — present root cause to the Lead with supporting evidence
3. **Confirm** — wait for Lead to confirm the diagnosis
4. **Proceed** — only then implement the fix
