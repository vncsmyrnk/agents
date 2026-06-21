---
name: brainstorm
description: Use when the user wants to create a document but the brief is incomplete. Guides a short interview to capture the goal document, the user's assumptions, clear goals, and—when the document makes a claim—a working hypothesis before drafting.
---

# Brainstorm a document

This skill turns an incomplete document request into a guided interview and then
into a draft. Use it to sharpen the user's thinking, not to invent missing
inputs.

## When to use

- The user wants a report, proposal, skill, spec, memo, plan, or similar
  document, but the brief is incomplete.
- The user wants to think through an idea before writing.
- The user wants you to extract assumptions, a hypothesis, and goals through
  direct questions.

Do not use this skill when:

- The user already gave a complete brief and wants the draft immediately.
- A more specific skill already fits the requested artifact.
- The user only wants open-ended ideation without converging on a document.

## Core principle

Ask focused questions until you can state the required brief below in concrete
terms. Then draft from that brief instead of improvising.

Choose the interview format that fits the agent and the user — batch related
questions or ask them one at a time, whichever reaches a clear brief fastest.
Use the agent's interactive question mechanism when available; otherwise ask
plainly in chat.

## Required brief

Before drafting, you must capture these items explicitly. They are the canonical
checklist; the workflow and stop rule refer back to them rather than restating
them.

- **Goal document** — the exact artifact the user wants produced.
- **First assumptions** — what the user currently believes is true, likely, or
  important.
- **Clear goals** — what the finished document must achieve.
- **Working hypothesis** *(only when the document makes a claim or argument)* —
  the main idea the document should test, defend, or explore, **and the intended
  method(s) of proving or supporting it** (evidence, data, reasoning, experiment,
  sources). Skip it for purely informational documents (e.g. a status memo or a
  reference spec).

Keep interviewing until each applicable item is explicit.

## Workflow

### 1. Confirm the goal document

Establish exactly what will be produced. Capture:

- document type
- working title or topic
- intended audience
- decision or outcome the document should support

If the user has not named the goal document yet, ask for that before anything
else.

### 2. Elicit the user's starting point

Surface what the user already thinks, filling the remaining brief items. Useful
prompts:

- "What are you assuming right now?"
- "What would make this document successful?"
- "What hypothesis should this document explore or support?" *(only if the
  document argues a point)*
- "How do you intend to prove or support that hypothesis?" *(ask whenever a
  hypothesis applies)*

### 3. Fill the missing brief

Ask only the questions still needed to draft well. Common gaps include:

- constraints such as length, deadline, format, or tone
- required sections or non-negotiable points
- evidence, examples, or sources to include
- risks, objections, or alternatives to address
- the action the reader should take after reading

Adapt each next question to the user's last answer.

### 4. Synthesize before drafting

Before writing, restate the brief compactly — the required items above plus
audience, key constraints, and open risks or unknowns. If the synthesis exposes
a mismatch or a major gap, ask follow-up questions before drafting.

### 5. Draft the document

Once the brief is sufficient, write the requested artifact. The draft should:

- reflect the user's stated assumptions
- test, explain, or defend the working hypothesis (when one applies)
- stay aligned with the clear goals

If uncertainty remains, label it explicitly instead of inventing facts.

If the goal document is a tracked file in this repo, drafting it is a file
change: follow `AGENTS.md`'s Pre-Change Gate — state where it will be saved and
in what format, and get plan approval before writing. Reference the gate; do not
restate its steps here.

### 6. Refine with targeted follow-up

After presenting the draft, ask for focused feedback only if another pass is
needed. Prefer concrete refinement questions over broad invitations.

## Stop rule

Stop asking questions and start drafting once every applicable item in the
required brief is explicit and any remaining gaps are minor enough to mark as
assumptions in the draft.

## Output expectations

When this skill is used well, the result is:

1. a short brief grounded in the user's own answers
2. a draft of the requested document
3. any remaining assumptions called out plainly
