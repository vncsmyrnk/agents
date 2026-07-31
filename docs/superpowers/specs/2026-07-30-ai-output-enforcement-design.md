# AI Writing Quality Enforcement Design (Repo-Scoped)

## Goal

Improve the clarity of AI-facing instructions in this repository and establish a
separate, evidence-based path for evaluating generated output.

The design has two layers:

1. **Instruction-document hygiene:** statically lint repository Markdown where
   automated rules can produce reliable findings.
2. **Runtime-output evaluation:** later evaluate generated responses with
   task-aware criteria and representative prompt/response fixtures.

Static Markdown linting does not enforce runtime output. Each layer must make
claims that match the behavior it can observe.

## Scope

### Layer 1: Instruction-document hygiene

- First-party Markdown in this repository, including:
  - `AGENTS.md`
  - `skills/**/SKILL.md`
  - `.copilot/**/*.md`
  - `docs/**/*.md`
- Local and CI execution of the same lint configuration.
- Rule profiles appropriate to each document class.
- Explicit handling for code blocks, inline code, quotations, generated content,
  external content, and fixtures that intentionally contain violations.
- Warning-only rollout for prose findings until promotion criteria are met.
- Immediate failure for stale inventory, invalid configuration, failed rule
  fixtures, or linter execution errors.

### Layer 2: Runtime-output evaluation

- A future evaluation harness for representative agent tasks and outputs.
- Task-aware assessment of clarity, completeness, correctness, and brevity.
- Held-out and adversarial prompt/response fixtures.
- Human judgment as the reference for qualities that static rules cannot
  determine reliably.

## Non-Goals

- Changing model providers or decoding parameters.
- Shipping runtime wrappers or output interceptors in the instruction-document
  hygiene phase.
- Treating phrase frequency, readability scores, or a self-evaluator as proof of
  output quality.
- Implementing a complete controlled-language standard through regular
  expressions.

## Requirements

1. Instructions should use direct, clear language and avoid demonstrated
   low-value wording patterns.
2. Every automated rule must identify an observable textual condition and state
   the quality risk it is intended to reduce.
3. Instruction-document checks must be auditable locally and in CI.
4. Blocking rules must meet agreed signal-to-noise thresholds on a labeled
   repository corpus before CI treats them as errors.
5. Brevity guidance must be task-sensitive:
   - Prefer concise answers by default.
   - Preserve material context, correctness, and required detail over a fixed
     word count.
   - Honor explicit user length and format requirements.
   - Do not omit important details merely to satisfy a style metric.
6. Runtime-output quality claims must be supported by representative evaluation,
   not inferred from instruction-document lint results.

## Writing-System References

The following systems are candidates for rule design, not adopted wholesale:

1. **ASD-STE100 (Simplified Technical English)**
   - Consider for bounded technical-instruction contexts where controlled
     vocabulary and sentence forms fit the audience.
   - Do not assume that its maintenance-document conventions fit general agent
     dialogue, code review, or explanatory writing.
2. **ISO 24495-1 Plain Language**
   - Consider its audience, structure, wording, and usability principles as
     evaluation dimensions.
3. **Microsoft Writing Style Guide**
   - Consider its technical-writing guidance for terminology, directness, and
     user-focused instructions.

Adoption decisions must follow comparative evaluation against repository examples.
No single writing system is the default baseline until that evaluation shows a
clear domain fit.

## Layer 1 Mechanism Evaluation

### Selected approach: Vale

Use Vale as the primary prose linter because it supports repository-owned rules,
path-based configuration, contextual scopes, severity levels, and machine-readable
output without adding an application dependency stack.

Vale provides:

- high-confidence phrase and terminology checks
- document-class-specific rule profiles
- exclusions for non-prose and intentional examples
- severity levels for advisory and blocking findings
- machine-readable results for fixture verification

A POSIX-shell wrapper provides repository-wide discovery, inventory validation,
profile dispatch, fixture verification, and actionable dependency errors. Narrow
support scripts are acceptable only where Vale cannot express inventory or
fixture assertions.

Vale rules must not claim to determine semantic clarity or runtime-output quality.

### Alternatives considered

- `textlint` offers stronger syntax-aware plugins but adds a Node dependency stack
  and more custom-plugin maintenance.
- A custom checker offers exact repository behavior but has the highest
  implementation and long-term maintenance cost.

Use one of these alternatives only for a documented requirement that Vale and a
narrow support script cannot satisfy.

## Layer 1 Architecture

### Repository components

- `.vale.ini` assigns rule profiles by document class and excludes non-prose
  scopes.
- `.vale/styles/Agents/` contains repository-owned, auditable rules.
- `docs/ai-writing/inventory.tsv` lists every first-party Markdown file with its
  profile or a rationale-backed exclusion.
- `docs/ai-writing/corpus/` contains labeled pass and fail fixtures from every
  document class, including protected contexts.
- `scripts/lint-docs.sh` is the single local and CI entry point.
- A narrow fixture verifier checks expected Vale findings and calculates
  per-rule corpus results.
- `make lint-docs` invokes the entry point.
- `.github/workflows/lint-docs.yml` installs Vale `3.16.0` and invokes the same
  Make target.

### Document profiles

The inventory classifies Markdown as:

1. normative instructions
2. skill procedures
3. explanatory documentation
4. test fixtures
5. generated or external content

Every discovered Markdown file must have a profile or documented exclusion.
Generated content, external content, and fixtures that intentionally contain
violations are excluded from repository prose linting but remain visible in the
inventory.

### Execution flow

`make lint-docs` performs these steps in order:

1. Discover first-party Markdown and compare it with the checked-in inventory.
2. Reject missing, stale, duplicate, or rationale-free inventory entries.
3. Verify rule fixtures and calculate per-rule labeled-corpus results.
4. Run Vale over each included document profile.
5. Print advisory prose findings without failing the command.

The local command requires Vale `3.16.x`. A missing or incompatible binary
produces an actionable error. CI installs Vale `3.16.0` and calls the same Make
target.

Inventory errors, malformed configuration, fixture mismatches, and linter
execution errors fail locally and in CI. Prose findings remain warnings during
the initial rollout.

### Initial rule set

Begin with narrow rules for observable wording patterns:

- wordy substitutions such as `utilize` and `in order to`
- low-value lead-ins such as `it is important to note`
- weak directive phrases in normative documents

Each rule must document its textual trigger, quality risk, severity, positive and
negative examples, protected contexts, and known limitations. Ambiguous patterns
remain advisory or are removed. Existing high-confidence true positives are
rewritten without changing their technical meaning.

### Corpus and promotion policy

The labeled corpus samples every document class and includes true violations,
acceptable prose, ambiguous cases, quotations, code blocks, inline code,
generated or external content, and intentional violations.

The fixture verifier reports true positives, false positives, false negatives,
and precision per rule. A rule may be proposed for blocking only when it reaches
at least 95% precision on the labeled corpus and produces no false positives in
protected contexts. Promotion is a separate, reviewed policy change; this
implementation does not promote any prose rule automatically.

## Implementation Phases

### 1. Inventory and classification

- Build the definitive list of first-party Markdown.
- Classify files by purpose, such as normative instructions, skill procedures,
  explanatory documentation, and test fixtures.
- Record excluded files and regions with rationale.

### 2. Baseline corpus

- Sample representative prose from every document class.
- Label true violations, acceptable uses, quotations, code, and ambiguous cases.
- Include examples that contain targeted phrases without exhibiting the targeted
  quality problem.

### 3. Rule design

- Define each rule with its trigger, rationale, severity, positive and negative
  examples, and known limitations.
- Separate mechanically detectable problems from qualities that require human
  judgment.
- Prefer narrow rules with high precision over broad proxies for "AI slop."

### 4. Tool proof of concept

- Implement the initial rules in Vale.
- Add only narrow support scripting for inventory and fixture assertions that
  Vale cannot express.
- Measure rule results against the labeled corpus before considering promotion.

### 5. Policy wiring

- Add one local entry point that scans every in-scope Markdown file with its
  assigned profile.
- Run the same entry point in CI.
- Introduce all prose rules as warnings.
- Promote a rule to blocking only after it meets the agreed precision threshold
  and has documented remediation.

### 6. Future runtime-output evaluation design

- Define task categories before setting output expectations.
- Build held-out prompt/response fixtures covering short answers, explanations,
  reviews, plans, and cases requiring substantial context.
- Test omission pressure, conflicting format constraints, quoted banned phrases,
  and attempts to optimize for the evaluator rather than the task.
- Use blind human ratings for clarity, completeness, and correctness.
- Track verbosity separately so concise but incomplete output cannot score well.
- Evaluate across supported models or agent environments before generalizing a
  result.
- Do not use model self-critique as the sole acceptance gate because its errors
  can correlate with the generator's errors.

Layer 2 is outside this implementation cycle and requires a separate
implementation decision because Layer 1 does not ship a runtime observation or
enforcement mechanism.

## Exceptions and Governance

- Exclusions and allowlist entries require an in-repository rationale.
- Rule changes must include:
  - examples that should fail and pass
  - labeled-corpus results
  - expected false-positive and false-negative impact
  - the intended severity and remediation
- Recalibrate or remove rules whose signal degrades as repository content changes.
- Do not broaden a rule from one document class to all Markdown without evidence
  that its context and precision remain valid.

## Acceptance Criteria

### Layer 1

- Every first-party Markdown file is inventoried and assigned a profile or a
  documented exclusion.
- Local and CI checks use the same configuration and file discovery.
- Intentional examples, quotations, and code do not create findings.
- Fixture verification reports per-rule corpus results.
- No rule is blocking in the initial rollout.
- Any future blocking rule must reach at least 95% precision and have no false
  positives in protected contexts.
- Existing high-confidence findings are corrected without changing technical
  meaning.
- Missing Vale installations or versions outside `3.16.x` produce actionable
  local errors.
- Inventory, configuration, fixture, and execution failures fail locally and in
  CI.
- Documentation describes findings as instruction-document hygiene, not runtime
  output enforcement.

### Layer 2 design

- Task categories and quality dimensions are explicit.
- Evaluation includes held-out, adversarial, and omission-sensitive cases.
- Completeness and correctness cannot be offset by brevity alone.
- Human reference judgments and disagreement handling are defined.
- The design identifies the runtime observation point required for actual
  enforcement.
