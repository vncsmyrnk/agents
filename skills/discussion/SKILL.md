---
name: discussion
description: Use when the human already has a clear goal and part of an approach and wants it pressure-tested before committing. First make the goal and path definitely clear, then act as a loyal opposition — check whether the problem is already solved and whether the path is a known dead-end, weighing simpler alternatives and hidden assumptions — to avoid redundant work and proven-bad approaches. Not for forming an incomplete brief (use brainstorm), nor for executing an already-agreed change (use the pre-change-gate).
---

# Discuss a goal and its approach

The human arrives with a clear goal and some pieces of the way there. This skill
makes that goal and path definitely clear, then pressure-tests them as a loyal
opposition — to prevent redundant work and known-bad paths before effort is spent.

## When to use

- The human has a clear goal and a partial approach, and wants it validated or
  challenged before committing.
- You suspect the problem may already be solved, or the path may be a known
  dead-end.
- You want a structured critical review before investing in implementation.

Do not use this skill when:

- The goal or brief is still unformed — use **brainstorm** to capture it first.
- The approach is already agreed and you are about to change code — go to the
  **pre-change-gate**.
- The human explicitly wants execution without scrutiny — respect that, but still
  flag material risks (`AGENTS.md` → Alignment & Proactive Discussion).

## Core principle

Be a loyal opposition, not an obstacle. Challenge with evidence, present trade-offs,
then let the human decide — silence is not consent (`AGENTS.md` → Alignment &
Proactive Discussion, Communication). The aim is to de-risk the goal, not to win
the argument.

## Workflow

### 1. Make the goal definitely clear

Restate the goal and the proposed path in your own words and get agreement. If
anything is ambiguous or rests on an assumption, STOP and ask — do not guess. If
the goal itself turns out to be unformed, switch to **brainstorm**.

### 2. Check whether the problem is already solved

Investigate before debating: search the codebase, dependencies, and docs, and
consider standard-library or well-known solutions and prior art. If a solution
exists, surface it and recommend reusing or adapting it instead of rebuilding.

### 3. Stress-test the path as opposition councilor

Argue the strongest case against the approach:

- Has this path been tried and failed here before (git history, docs, comments)?
- Is it a known anti-pattern, deprecated, or a footgun?
- What hidden assumptions, edge cases, or costs does it carry?
- Is there a simpler or more robust alternative?

Back each objection with evidence or explicit reasoning; do not dress speculation
as fact.

### 4. Present trade-offs and converge

Lay the objections out as trade-offs (pros/cons) and give a recommendation. Reach
one outcome: validate the path, redirect to an existing solution, or steer to a
better path. The human decides.

### 5. Record the outcome

Capture the decision, its rationale, and any rejected alternatives (`AGENTS.md` →
Documentation & No-Drift) so the reasoning is not lost. If the outcome is a change,
proceed through the **pre-change-gate**; do not restate it here.

## Stop rule

Stop opposing once the goal is clear, prior art is checked, the main objections are
raised with evidence and addressed, and the human has decided. Do not relitigate a
settled decision.

## Output expectations

1. A sharpened, agreed goal and approach.
2. A short list of evidence-backed objections plus the existing-solution check.
3. A decision — validate, redirect, or redirect-to-existing — with recorded rationale.
