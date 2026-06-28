---
name: add-agents-requirement
description: Use when adding, changing, or removing a behavioral requirement (rule) in the generic AGENTS.md instructions file. Applies the pre-change-gate workflow — clarify intent, classify MUST/MUST NOT/SHOULD, choose the correct section, check for conflicts and duplication, format the rule as a Trigger → Action pair, and emit the Plan output contract for approval before editing.
---

# Add a requirement to AGENTS.md

This skill governs how a new requirement enters the generic `AGENTS.md` (the
behavioral base layer shared across every AI CLI agent). `AGENTS.md` is a
normative document with its own conventions; a careless edit erodes those
conventions. Follow this workflow exactly — it applies the **pre-change-gate**
skill to the file that holds the shared behavioral rules.

## When to use

- The user wants to add a new rule, principle, or constraint to `AGENTS.md`.
- The user wants to modify or remove an existing rule.
- The user describes desired agent behavior that belongs in the base layer
  rather than a project-specific file.

If the request is project-specific (build/test/run commands, repo layout,
conventions for one codebase) or belongs in a skill rather than the base layer,
it does NOT go here — route it per **Where behavior is documented** in
`AGENTS.md`.

## Workflow

### 1. Explore
Read the current `AGENTS.md` in full before proposing anything. You must know
the existing sections, their style, and the rules already present. The standard
sections are: How to read this file, The agent's role in software
development, About this repository, Precedence, Making changes,
Communication, Alignment & Proactive Discussion, Technical Stance,
Documentation & No-Drift, Where behavior is documented, Version Control.

### 2. Clarify intent
If the requirement's scope, strength, or trigger is unclear, STOP and ask. Do
not guess. Confirm:
- **What** behavior is required or forbidden.
- **When** it applies (the trigger condition).
- **Why** — the underlying principle (record it; see step 7).

### 3. Classify normativity
Assign exactly one RFC 2119 keyword, matching how the file already uses them:
- **MUST / MUST NOT** — non-negotiable; no exceptions without explicit in-session override.
- **SHOULD** — strong default; deviation requires a stated reason.

If the user wants something weaker than SHOULD, question whether it belongs in a
normative base layer at all.

### 4. Choose the section
Place the rule in the section whose theme it matches. If none fits, propose a
**new section** with a heading consistent with the existing ones (sentence-style
`## Title`), and say why a new section is warranted rather than stretching an
existing one.

### 5. Check for conflict and duplication
Compare the proposed rule against every existing rule:
- **Duplication** — if it restates an existing rule, refine the existing one
  instead of adding a near-copy.
- **Conflict** — if it contradicts an existing rule (or the Precedence order),
  surface the conflict explicitly and let the user decide. MUST NOT silently
  resolve it.

### 6. Format as Trigger → Action
Most rules in this file follow the **Trigger → Action** form. Match the
surrounding style of the target section:

```
- **Trigger:** <the condition that activates the rule>. **Action:** you MUST/SHOULD <the required behavior>.
```

Some sections (e.g. Precedence, Version Control) use plain normative sentences
or numbered lists — follow whatever the chosen section already does. Reuse the
file's existing keywords and domain language; do not introduce new vocabulary
for concepts already named.

### 7. Plan and get approval
Before editing, emit the **Plan output contract** exactly as the
**pre-change-gate** skill defines it:

```
Goal: <one line>
Changes:
  - AGENTS.md (<section>): <exact rule text being added/changed>
Docs to update: <README or other docs the change makes stale, or "none">
Side effects: <none, typically — this is a doc-only change unless install/tooling is touched>
Trade-offs: <only if more than one viable phrasing/placement>
Open questions: <blocking unknowns> (omit if none)
```

Wait for explicit approval. No edit proceeds without it.

### 8. Apply and cover impact
After approval:
- Insert the rule in the chosen section, preserving ordering and formatting.
- Update any doc the change makes stale (README, comments, other specs). If a
  decision or previously-undocumented principle was settled during the
  discussion, record it per the file's Documentation & No-Drift rule.
- MUST NOT commit unless the user explicitly asks. When they do, use a
  Conventional Commit message (`feat:`, `fix:`, `chore:`, …).
