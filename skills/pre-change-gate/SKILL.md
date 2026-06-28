---
name: pre-change-gate
description: Use before making a change — any file edit/create/delete, any command with side effects, or any commit. Guides the gate every change must pass: explore, clarify, flag mismatches, cover impact, define validation, then plan and get explicit user approval before proceeding. Also defines the Plan output contract. Do not use when only answering, exploring, or reviewing — the gate applies only when a change is about to be made.
---

# Pre-Change Gate

The gate every change must pass before it is made. It applies to any file change,
command with side effects, or commit, in any project. Work the steps in order; the
change does not proceed until the final step — approval — is met.

## When to use

- You are about to edit, create, or delete a file.
- You are about to run a command with side effects (migrations, installs, network
  writes, destructive or stateful operations).
- You are about to commit.

Do NOT invoke the gate when no change is being made — answering a question,
exploring, or reviewing. It governs changes, not reads.

## Workflow

Before any file change, command with side effects, or commit, you MUST complete
these in order:

1. **Explore** — read the relevant code/docs. No change without exploration.
2. **Clarify** — if a requirement is unclear, undocumented, or requires an
   assumption, STOP and ask. MUST NOT guess.
3. **Flag mismatches** — if code and documentation disagree, state it and let the
   user decide. MUST NOT resolve it unilaterally.
4. **Cover impact** — before planning, enumerate everything the change touches.
   You MUST account for: every doc that the change makes stale (README,
   `AGENTS.md`, comments, specs), and every side effect (migrations, config, env,
   build/install steps, symlink targets, downstream consumers, tests). MUST NOT
   leave an impacted doc or side effect unlisted; if one is intentionally out of
   scope, say so and why.
5. **Define validation** — state how the change will be verified before it is
   considered done: tests to add or run, commands to execute, and manual checks.
   If the change genuinely cannot be tested, you MUST say "none" and why. MUST NOT
   propose a change with no validation strategy.
6. **Plan** — produce a plan in the contract below.
7. **Approval** — wait for explicit user approval of the plan. No change proceeds
   without it.

## Plan output contract

```
Goal: <one line>
Changes:
  - <file/area>: <exact change>
Docs to update: <impacted docs, or "none">
Side effects: <migrations, config, install/build, downstream, tests, or "none">
Validation & testing: <tests to add/run, commands, manual checks; or "none" + why>
Trade-offs: <option A vs B, pros/cons> (omit if none)
Open questions: <blocking unknowns> (omit if none)
```
