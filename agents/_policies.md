# Agent Policies

This file is the canonical source for shared agent protocols. Changes here must be reflected in all agent profiles. Use `make validate` to check consistency.

## Git Workflow

**CRITICAL: Never commit directly to `main`. Always use feature branches.**
**CRITICAL: Feature branches are LOCAL ONLY. Never push them to origin unless explicitly asked by name.**

1. `git switch -c <descriptive-branch-name>` — create and switch to a feature branch
2. Make edits and test
3. `git add <files>` — stage changes
4. `git commit -m "<message>"` — commit on the branch
5. `git rebase main` — rebase feature branch onto main (use `-i` for interactive squashing)
6. `git switch main` — return to main
7. `git merge <branch-name>` — merge the completed work
8. `git push origin main` — push ONLY main to origin
9. `git branch -d <branch-name>` — delete the local feature branch

**Final state before reporting:** branch tested, rebased on main, merged to main, main pushed to origin, feature branch deleted.

**Diagnose before fixing:** NEVER propose or implement a fix before first confirming the root cause.

**Approval before merge:** NEVER merge a feature branch into `main` without explicit approval from the Engineering Lead.

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
