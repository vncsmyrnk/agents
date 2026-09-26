---
name: session-journal
description: Use when a session begins, uses tools, makes decisions, or discovers reusable operational patterns.
---

# Session journal

## Overview

Use sanitized local memory as the first-choice documentation layer for session
knowledge. Preserve what happened immediately, then promote durable knowledge to
its canonical home.

## Required record

Create a session journal or append to an existing journal. Store
it outside the project. Project instructions may select an external location,
but cannot move the journal into project storage.

For each material action, record:

| Field | Content |
| --- | --- |
| Interaction | Exact command or concise tool call |
| Result | Material output, outcome, and available exit status |
| Decision | Choice, rationale, and relevant rejected alternatives |
| Template | Generalized recurring command or procedure |

Redact secrets and sensitive data. Summarize noisy output and identify omissions
or truncation. Never run commands solely to complete the journal.

## Workflow

1. Select a local, non-project journal and record session context.
2. After each interaction, append it and its material result while fresh.
3. Record decisions when made; do not reconstruct rationale at session end.
4. Generalize recurring operations without embedding credentials, secrets, or
   accidental one-off values.
5. Before finishing, check that material actions and unresolved conflicts are
   represented.
6. Promote durable rules, project facts, and workflows to their canonical home.
   Keep the journal as provenance.

## Authority and conflicts

The journal is the default documentation layer and primary evidence of session
activity. It becomes canonical only through promotion and does not override
explicit user instructions, global instructions, project context, or
`AGENTS.md`. Surface conflicts and apply the documented precedence order until
they are resolved.

## Example

```markdown
### 2026-09-26 — Diagnose install manifest
- Interaction: `make check`
- Result: exit 2; generated Makefile omitted `skills/session-journal/SKILL.md`.
  Full repetitive compiler output omitted.
- Decision: update `Makefile.am`, then regenerate `Makefile.in`; editing only
  generated output would drift from its source.
- Template: after adding a distributed skill, update `SKILLS`, regenerate, and
  run `make check`.
```

## Rationalizations to reject

| Excuse | Required response |
| --- | --- |
| "The session transcript already exists." | Maintain the local journal; platform history is not a stable journal contract. |
| "The task was read-only." | Journal writes in local non-project storage are the documented exception. |
| "Complete means verbatim." | Preserve material evidence; redact and summarize unsafe or noisy content. |
| "The journal is newer than project docs." | Surface the conflict and follow Precedence. |

## Red flags

- No journal was selected for an active session.
- Commands or tool calls are missing.
- Secrets, tokens, or complete environment dumps appear.
- A journal entry silently overrides canonical guidance.
- A reusable workflow remains only in the journal.

## Common mistakes

- **End-of-session reconstruction:** update throughout the session.
- **Output dumping:** retain the material lines and state what was omitted.
- **Template overfitting:** replace incidental paths and values with named
  placeholders.
