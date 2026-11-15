---
name: pre-change-gate
description: Use before making a non-trivial change — multi-file, irreversible, outward-facing (push, deploy, network write), loosening permissions, or exposing secrets. Guides the gate every change must pass e.g. explore, clarify, flag mismatches, cover impact, define validation, then plan and get explicit user approval before proceeding. Also defines the Plan output contract. Do not use when only answering, exploring, or reviewing — the gate applies only when a change is about to be made.
---

# Pre-Change Gate

The gate every non-trivial change must pass before it is made, in any project.
Work the steps in order; the change does not proceed until the final step —
approval — is met, except where `AGENTS.md` (`Making changes`) allows auto mode
to proceed after stating the plan.

## When to use

- The change spans multiple files.
- The change is irreversible (destructive or stateful operations, migrations).
- The change is outward-facing (push, deploy, network writes).
- The change loosens permissions or exposes secrets. Changes that only tighten
  permissions (adding `ask`/`deny` rules, narrowing an allowlist) do not count.

Trivial changes — single file, reversible, and explicitly requested — MAY skip
the gate; state what changed and how it was validated. Do NOT invoke the gate
when no change is being made — answering a question, exploring, or reviewing.
In auto mode, state the plan but do not wait for approval unless the change is
irreversible or outward-facing. In unattended sessions, follow the unattended
rule in `AGENTS.md` (`Making changes`) in place of per-change confirmation.

## Workflow

Before a non-trivial change (see "When to use"), you MUST complete these in
order:

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
