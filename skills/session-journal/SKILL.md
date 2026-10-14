---
name: session-journal
description: Use when a session begins, uses tools, makes decisions, or discovers reusable operational patterns.
---

# Session journal

## Overview

Use sanitized local memory as the first-choice documentation layer for session
knowledge. Preserve what happened immediately, then promote durable knowledge to
its canonical home. Maintain a persistent index so later sessions can retrieve
journals and canonical project information.

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

1. Consult the index below, select a local, non-project journal, and record
   session context. Create the index if it does not exist.
2. After each interaction, append it and its material result while fresh.
3. Record decisions when made; do not reconstruct rationale at session end.
4. Generalize recurring operations without embedding credentials, secrets, or
   accidental one-off values.
5. Before finishing, check that material actions and unresolved conflicts are
   represented and the index reflects the current records.
6. Promote durable rules, project facts, and workflows to their canonical home.
   Keep the journal as provenance.

## Index and retrieval

Use `~/.local/share/agent-memory/index.md` as the shared, cross-agent entry point,
outside all projects. The index contains pointers, not copies of project facts.
Its required fields are:

| Field | Content |
| --- | --- |
| Project | Distinct identifier: absolute repository root, not just its name; use `non-project` for unscoped activity |
| Journal | Absolute path to each relevant journal |
| Topics and dates | Sanitized search keywords and activity dates |
| Canonical information | Paths or links to the project's instructions and promoted documentation, when present |

At session start and before retrieving prior journal/project information, consult
the index, match the project identifier and topics/dates, then read the linked
sources. Verify that links resolve; the index is not evidence for the linked
content. If the index or a matching entry is missing, report that gap and use
known local sources or ask for the missing location. Do not invent prior history
or conclude that no history exists merely because it is not indexed.

Update the index when a journal or linked project document is created, moved,
removed, or receives promoted knowledge; refresh topics/dates after material
activity. Repair stale links and remove obsolete entries when discovered.
Existing journals found during retrieval must be indexed. Keep unrelated
projects with the same name separate.

Apply the journal's sanitization rules to index entries. Required local journal
and index writes share the journal-write exception in `AGENTS.md`; edits to
linked project documents and other operations still require the pre-change gate.

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
- The index is missing, stale, or was skipped before retrieving prior information.
- Secrets, tokens, or complete environment dumps appear.
- A journal entry silently overrides canonical guidance.
- A reusable workflow remains only in the journal.

## Common mistakes

- **End-of-session reconstruction:** update throughout the session.
- **Output dumping:** retain the material lines and state what was omitted.
- **Template overfitting:** replace incidental paths and values with named
  placeholders.
- **Index as a second source of truth:** link to canonical information instead
  of duplicating it.
