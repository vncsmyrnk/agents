# AI Writing Quality Enforcement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add warning-first, repository-scoped Markdown hygiene checks with a
complete inventory, labeled corpus, local command, and identical CI entry point.

**Architecture:** Vale owns prose matching and Markdown-aware exclusions. Small
POSIX-shell scripts own file inventory validation, fixture assertions, corpus
metrics, and orchestration; `make lint-docs` is the only public entry point used
locally and in GitHub Actions.

**Tech Stack:** Vale 3.16.x, POSIX shell, GNU Make, GitHub Actions

## Global Constraints

- CI MUST install Vale `3.16.0`; local execution MUST accept only Vale `3.16.x`.
- Prose findings MUST remain warnings and MUST NOT fail the initial rollout.
- Missing or stale inventory entries, invalid configuration, fixture mismatches,
  and Vale execution errors MUST fail locally and in CI.
- Every first-party Markdown file MUST have a profile or a rationale-backed
  exclusion.
- Intentional examples, quotations, fenced code, and inline code MUST produce no
  findings.
- Future blocking promotion requires at least 95% precision and zero false
  positives in protected contexts.
- Existing technical meaning and explicit user length or format requirements
  MUST be preserved.
- Layer 2 runtime-output evaluation is outside this implementation.
- Do not commit unless the user explicitly requests a commit, as required by
  `AGENTS.md`.

---

### Task 1: Markdown Inventory Validator

**Files:**
- Create: `scripts/check-markdown-inventory.sh`
- Create: `scripts/test-check-markdown-inventory.sh`

**Interfaces:**
- Consumes: repository root as argument 1 and inventory path as optional argument
  2
- Produces: exit 0 when discovered Markdown exactly matches valid inventory;
  otherwise prints actionable `ERROR:` lines and exits nonzero

- [ ] **Step 1: Write the failing inventory-validator test**

Create `scripts/test-check-markdown-inventory.sh`:

```sh
#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CHECKER="$SCRIPT_DIR/check-markdown-inventory.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/docs"
printf '# Root\n' >"$TMP_DIR/README.md"
printf '# Guide\n' >"$TMP_DIR/docs/guide.md"

write_inventory() {
  cat >"$TMP_DIR/inventory.tsv"
}

assert_passes() {
  if ! "$CHECKER" "$TMP_DIR" "$TMP_DIR/inventory.tsv" >"$TMP_DIR/output" 2>&1; then
    cat "$TMP_DIR/output" >&2
    printf 'expected inventory check to pass\n' >&2
    exit 1
  fi
}

assert_fails_with() {
  expected=$1
  if "$CHECKER" "$TMP_DIR" "$TMP_DIR/inventory.tsv" >"$TMP_DIR/output" 2>&1; then
    printf 'expected inventory check to fail\n' >&2
    exit 1
  fi
  if ! grep -F "$expected" "$TMP_DIR/output" >/dev/null; then
    cat "$TMP_DIR/output" >&2
    printf 'expected error containing: %s\n' "$expected" >&2
    exit 1
  fi
}

write_inventory <<'EOF'
path	profile	rationale
README.md	explanatory	Repository overview
docs/guide.md	explanatory	User guide
EOF
assert_passes

write_inventory <<'EOF'
path	profile	rationale
README.md	explanatory	Repository overview
EOF
assert_fails_with 'missing from inventory: docs/guide.md'

write_inventory <<'EOF'
path	profile	rationale
README.md	explanatory	Repository overview
docs/guide.md	explanatory	User guide
docs/stale.md	explanatory	Removed guide
EOF
assert_fails_with 'stale inventory entry: docs/stale.md'

write_inventory <<'EOF'
path	profile	rationale
README.md	explanatory	Repository overview
README.md	explanatory	Duplicate
docs/guide.md	explanatory	User guide
EOF
assert_fails_with 'duplicate inventory entry: README.md'

write_inventory <<'EOF'
path	profile	rationale
README.md	excluded
docs/guide.md	explanatory	User guide
EOF
assert_fails_with 'excluded entry requires rationale: README.md'

write_inventory <<'EOF'
path	profile	rationale
README.md	unknown	Invalid profile
docs/guide.md	explanatory	User guide
EOF
assert_fails_with 'invalid profile for README.md: unknown'

printf 'inventory validator tests: PASS\n'
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
chmod +x scripts/test-check-markdown-inventory.sh
./scripts/test-check-markdown-inventory.sh
```

Expected: FAIL because `scripts/check-markdown-inventory.sh` does not exist.

- [ ] **Step 3: Implement the inventory validator**

Create `scripts/check-markdown-inventory.sh`:

```sh
#!/bin/sh
set -eu

ROOT=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
INVENTORY=${2:-"$ROOT/docs/ai-writing/inventory.tsv"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

if [ ! -f "$INVENTORY" ]; then
  printf 'ERROR: inventory not found: %s\n' "$INVENTORY" >&2
  exit 1
fi

(
  cd "$ROOT"
  find . -type f -name '*.md' -not -path './.git/*' -print |
    sed 's#^\./##' |
    LC_ALL=C sort
) >"$TMP_DIR/discovered"

if ! awk -F '	' '
  BEGIN {
    valid["normative"] = 1
    valid["procedure"] = 1
    valid["explanatory"] = 1
    valid["fixture"] = 1
    valid["excluded"] = 1
    failed = 0
  }
  NR == 1 {
    if ($1 != "path" || $2 != "profile" || $3 != "rationale") {
      print "ERROR: inventory header must be: path<TAB>profile<TAB>rationale" > "/dev/stderr"
      failed = 1
    }
    next
  }
  NF != 3 {
    print "ERROR: inventory row must have exactly three tab-separated fields at line " NR > "/dev/stderr"
    failed = 1
    next
  }
  !($2 in valid) {
    print "ERROR: invalid profile for " $1 ": " $2 > "/dev/stderr"
    failed = 1
  }
  $2 == "excluded" && $3 == "" {
    print "ERROR: excluded entry requires rationale: " $1 > "/dev/stderr"
    failed = 1
  }
  seen[$1]++ {
    print "ERROR: duplicate inventory entry: " $1 > "/dev/stderr"
    failed = 1
  }
  {
    print $1
  }
  END {
    if (failed) {
      exit 1
    }
  }
' "$INVENTORY" >"$TMP_DIR/listed"; then
  exit 1
fi

LC_ALL=C sort "$TMP_DIR/listed" -o "$TMP_DIR/listed"

failed=0
while IFS= read -r path; do
  [ -n "$path" ] || continue
  printf 'ERROR: missing from inventory: %s\n' "$path" >&2
  failed=1
done <<EOF
$(comm -23 "$TMP_DIR/discovered" "$TMP_DIR/listed")
EOF

while IFS= read -r path; do
  [ -n "$path" ] || continue
  printf 'ERROR: stale inventory entry: %s\n' "$path" >&2
  failed=1
done <<EOF
$(comm -13 "$TMP_DIR/discovered" "$TMP_DIR/listed")
EOF

exit "$failed"
```

- [ ] **Step 4: Run the inventory-validator tests**

Run:

```bash
chmod +x scripts/check-markdown-inventory.sh
./scripts/test-check-markdown-inventory.sh
```

Expected:

```text
inventory validator tests: PASS
```

---

### Task 2: Vale Rules and Labeled Corpus

**Files:**
- Create: `.vale.ini`
- Create: `.vale/styles/Agents/Wordy.yml`
- Create: `.vale/styles/Agents/LowValueLeadIn.yml`
- Create: `.vale/styles/AgentsNormative/WeakDirective.yml`
- Create: `docs/ai-writing/README.md`
- Create: `docs/ai-writing/corpus/cases.tsv`
- Create: `docs/ai-writing/corpus/general/fail-in-order-to.md`
- Create: `docs/ai-writing/corpus/general/fail-wordy.md`
- Create: `docs/ai-writing/corpus/general/fail-low-value-leadin.md`
- Create: `docs/ai-writing/corpus/general/pass-clear.md`
- Create: `docs/ai-writing/corpus/general/pass-utilization.md`
- Create: `docs/ai-writing/corpus/normative/fail-weak-directive.md`
- Create: `docs/ai-writing/corpus/procedure/pass-direct-procedure.md`
- Create: `docs/ai-writing/corpus/protected/external.md`
- Create: `docs/ai-writing/corpus/protected/inline-code.md`
- Create: `docs/ai-writing/corpus/protected/fenced-code.md`
- Create: `docs/ai-writing/corpus/protected/quotation.md`
- Create: `scripts/verify-writing-rules.sh`
- Create: `scripts/test-writing-rules.sh`

**Interfaces:**
- Consumes: repository root as optional argument 1 and `VALE_BIN` as an optional
  environment override
- Produces: per-rule `tp`, `fp`, `fn`, and precision output; exits nonzero on a
  fixture mismatch, a protected-context finding, an incompatible Vale version,
  or a Vale execution error

- [ ] **Step 1: Write the failing fixture-verifier test**

Create `scripts/test-writing-rules.sh`:

```sh
#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
OUTPUT=$(mktemp)
trap 'rm -f "$OUTPUT"' EXIT HUP INT TERM

if ! "$SCRIPT_DIR/verify-writing-rules.sh" "$ROOT" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT" >&2
  exit 1
fi

for expected in \
  'Agents.Wordy	tp=2	fp=0	fn=0	precision=100.00%' \
  'Agents.LowValueLeadIn	tp=1	fp=0	fn=0	precision=100.00%' \
  'AgentsNormative.WeakDirective	tp=1	fp=0	fn=0	precision=100.00%'
do
  if ! grep -F "$expected" "$OUTPUT" >/dev/null; then
    cat "$OUTPUT" >&2
    printf 'missing expected corpus result: %s\n' "$expected" >&2
    exit 1
  fi
done

if ! grep -F 'protected-context false positives: 0' "$OUTPUT" >/dev/null; then
  cat "$OUTPUT" >&2
  printf 'protected-context result missing\n' >&2
  exit 1
fi

printf 'writing rule tests: PASS\n'
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
chmod +x scripts/test-writing-rules.sh
./scripts/test-writing-rules.sh
```

Expected: FAIL because `scripts/verify-writing-rules.sh` does not exist.

- [ ] **Step 3: Add Vale configuration and rules**

Create `.vale.ini`:

```ini
StylesPath = .vale/styles
MinAlertLevel = warning

[*.md]
BasedOnStyles = Agents
BlockIgnores = (?m)^>.*$

[AGENTS.md]
BasedOnStyles = Agents, AgentsNormative

[skills/*/SKILL.md]
BasedOnStyles = Agents, AgentsNormative

[docs/ai-writing/corpus/normative/*.md]
BasedOnStyles = Agents, AgentsNormative

[docs/ai-writing/corpus/procedure/*.md]
BasedOnStyles = Agents, AgentsNormative
```

Create `.vale/styles/Agents/Wordy.yml`:

```yaml
extends: substitution
message: "Use '%s' instead of '%s' for direct wording."
level: warning
ignorecase: true
swap:
  utilize: use
  in order to: to
```

Create `.vale/styles/Agents/LowValueLeadIn.yml`:

```yaml
extends: existence
message: "Remove the low-value lead-in '%s' and state the point directly."
level: warning
ignorecase: true
tokens:
  - it is important to note
  - it should be noted that
  - please note that
```

Create `.vale/styles/AgentsNormative/WeakDirective.yml`:

```yaml
extends: existence
message: "Replace the weak directive '%s' with an explicit requirement."
level: warning
ignorecase: true
tokens:
  - you may want to consider
  - it might be a good idea to
```

- [ ] **Step 4: Add the labeled corpus**

Create `docs/ai-writing/corpus/cases.tsv`:

```text
path	profile	expected_check	protected	rationale
docs/ai-writing/corpus/general/fail-wordy.md	explanatory	Agents.Wordy	no	Wordy substitution
docs/ai-writing/corpus/general/fail-in-order-to.md	explanatory	Agents.Wordy	no	Wordy purpose phrase
docs/ai-writing/corpus/general/fail-low-value-leadin.md	explanatory	Agents.LowValueLeadIn	no	Low-value lead-in
docs/ai-writing/corpus/general/pass-clear.md	explanatory	none	no	Direct acceptable prose
docs/ai-writing/corpus/general/pass-utilization.md	explanatory	none	no	Related technical term is acceptable
docs/ai-writing/corpus/normative/fail-weak-directive.md	normative	AgentsNormative.WeakDirective	no	Weak normative directive
docs/ai-writing/corpus/procedure/pass-direct-procedure.md	procedure	none	no	Direct procedural wording
docs/ai-writing/corpus/protected/external.md	excluded	none	yes	External content is excluded
docs/ai-writing/corpus/protected/inline-code.md	fixture	none	yes	Inline code is protected
docs/ai-writing/corpus/protected/fenced-code.md	fixture	none	yes	Fenced code is protected
docs/ai-writing/corpus/protected/quotation.md	fixture	none	yes	Quotations are protected
```

Create `docs/ai-writing/corpus/general/fail-wordy.md`:

```markdown
Use this command to utilize the shared configuration.
```

Create `docs/ai-writing/corpus/general/fail-in-order-to.md`:

```markdown
Run the check in order to validate the inventory.
```

Create `docs/ai-writing/corpus/general/fail-low-value-leadin.md`:

```markdown
It is important to note that the command reads repository Markdown.
```

Create `docs/ai-writing/corpus/general/pass-clear.md`:

```markdown
The command reads repository Markdown.
```

Create `docs/ai-writing/corpus/general/pass-utilization.md`:

```markdown
CPU utilization is recorded separately.
```

Create `docs/ai-writing/corpus/normative/fail-weak-directive.md`:

```markdown
You may want to consider validating the inventory before linting.
```

Create `docs/ai-writing/corpus/procedure/pass-direct-procedure.md`:

```markdown
Validate the inventory before linting.
```

Create `docs/ai-writing/corpus/protected/external.md`:

```markdown
It is important to note that this wording belongs to external content.
```

Create `docs/ai-writing/corpus/protected/inline-code.md`:

```markdown
The literal phrase `in order to utilize` is test input.
```

Create `docs/ai-writing/corpus/protected/fenced-code.md`:

````markdown
```text
It is important to note that this is fixture content.
```
````

Create `docs/ai-writing/corpus/protected/quotation.md`:

```markdown
> You may want to consider this quoted wording.
```

- [ ] **Step 5: Implement fixture verification and metrics**

Create `scripts/verify-writing-rules.sh`:

```sh
#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=${1:-$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)}
VALE_BIN=${VALE_BIN:-vale}
CASES="$ROOT/docs/ai-writing/corpus/cases.tsv"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

if ! version=$("$VALE_BIN" --version 2>&1); then
  printf 'ERROR: Vale 3.16.x is required; unable to run %s\n' "$VALE_BIN" >&2
  exit 1
fi

case "$version" in
  *3.16.*) ;;
  *)
    printf 'ERROR: Vale 3.16.x is required; found: %s\n' "$version" >&2
    exit 1
    ;;
esac

if [ ! -f "$CASES" ]; then
  printf 'ERROR: corpus case manifest not found: %s\n' "$CASES" >&2
  exit 1
fi

printf 'expected	actual	protected\n' >"$TMP_DIR/observations.tsv"
failed=0
protected_false_positives=0

tail -n +2 "$CASES" >"$TMP_DIR/cases.tsv"
while IFS='	' read -r path profile expected protected rationale; do
  [ -n "$path" ] || continue
  if [ ! -f "$ROOT/$path" ]; then
    printf 'ERROR: corpus fixture not found: %s\n' "$path" >&2
    exit 1
  fi

  if [ "$profile" = excluded ]; then
    printf 'none	none	%s\n' "$protected" >>"$TMP_DIR/observations.tsv"
    continue
  fi

  if ! output=$(
    cd "$ROOT"
    "$VALE_BIN" --config=.vale.ini --output=JSON --no-exit "$path"
  ); then
    printf 'ERROR: Vale execution failed for fixture: %s\n' "$path" >&2
    exit 1
  fi

  checks=$(
    printf '%s\n' "$output" |
      sed 's/"Check"[[:space:]]*:[[:space:]]*"/\
/g' |
      sed -n '2,$s/".*//p'
  )

  found_expected=0
  found_any=0
  for actual in $checks; do
    found_any=1
    [ "$actual" = "$expected" ] && found_expected=1
    printf '%s	%s	%s\n' "$expected" "$actual" "$protected" >>"$TMP_DIR/observations.tsv"
    if [ "$protected" = yes ]; then
      protected_false_positives=$((protected_false_positives + 1))
      printf 'ERROR: protected fixture produced %s: %s\n' "$actual" "$path" >&2
      failed=1
    elif [ "$expected" = none ] || [ "$actual" != "$expected" ]; then
      printf 'ERROR: unexpected %s in fixture: %s\n' "$actual" "$path" >&2
      failed=1
    fi
  done

  if [ "$expected" != none ] && [ "$found_expected" -eq 0 ]; then
    printf '%s	none	%s\n' "$expected" "$protected" >>"$TMP_DIR/observations.tsv"
    printf 'ERROR: expected %s was not found in fixture: %s\n' "$expected" "$path" >&2
    failed=1
  elif [ "$expected" = none ] && [ "$found_any" -eq 0 ]; then
    printf 'none	none	%s\n' "$protected" >>"$TMP_DIR/observations.tsv"
  fi
done <"$TMP_DIR/cases.tsv"

awk -F '	' '
  NR == 1 { next }
  {
    expected = $1
    actual = $2
    if (actual != "none") {
      seen[actual] = 1
      if (actual == expected) {
        tp[actual]++
      } else {
        fp[actual]++
      }
    }
    if (expected != "none") {
      seen[expected] = 1
      if (actual == "none") {
        fn[expected]++
      }
    }
  }
  END {
    for (rule in seen) {
      denominator = tp[rule] + fp[rule]
      precision = denominator ? (100 * tp[rule] / denominator) : 0
      printf "%s\ttp=%d\tfp=%d\tfn=%d\tprecision=%.2f%%\n",
        rule, tp[rule], fp[rule], fn[rule], precision
    }
  }
' "$TMP_DIR/observations.tsv" | LC_ALL=C sort

printf 'protected-context false positives: %d\n' "$protected_false_positives"
exit "$failed"
```

- [ ] **Step 6: Document rule rationale and limitations**

Create `docs/ai-writing/README.md`:

```markdown
# Instruction-document hygiene

`make lint-docs` inventories first-party Markdown, verifies the labeled rule
corpus, and runs Vale over included prose. These checks evaluate repository
instructions and documentation; they do not observe or enforce generated
runtime output.

## Profiles

| Profile | Content | Rules |
| --- | --- | --- |
| `normative` | `AGENTS.md` | General and normative rules |
| `procedure` | `skills/*/SKILL.md` | General and normative rules |
| `explanatory` | README and design documents | General rules |
| `fixture` | Labeled corpus Markdown | Verified separately |
| `excluded` | Generated or external Markdown | No prose linting; rationale required |

## Rules

| Rule | Trigger and quality risk | Remediation | Known false-negative risk | Corpus examples |
| --- | --- | --- | --- | --- |
| `Agents.Wordy` | `utilize` or `in order to` adds words without technical meaning | Replace with `use` or `to` | Other wordy phrases are intentionally outside this narrow rule | `fail-wordy.md`, `fail-in-order-to.md`, `pass-utilization.md` |
| `Agents.LowValueLeadIn` | A listed note-taking lead-in delays the substantive point | Remove the lead-in and state the point directly | Unlisted lead-ins are not detected | `fail-low-value-leadin.md`, `pass-clear.md` |
| `AgentsNormative.WeakDirective` | A listed weak directive hides whether an instruction is required | State the required action directly with the document's normative language | Indirect wording outside the two listed phrases is not detected | `fail-weak-directive.md`, `pass-direct-procedure.md` |

Inline code, fenced code, quotations, and excluded external content are protected
from findings. The protected corpus contains a positive example for each
exclusion mechanism.

All prose rules start at warning severity. A rule may be proposed for blocking
only after the labeled corpus shows at least 95% precision and no protected
context false positives. Rule promotion is a separate reviewed policy change.

## Corpus labels

`corpus/cases.tsv` records each fixture's document profile, expected Vale check,
protected-context status, and rationale. `scripts/verify-writing-rules.sh`
reports true positives, false positives, false negatives, precision, and the
protected-context false-positive count.
```

- [ ] **Step 7: Run the fixture test and install only if Vale is missing**

Run:

```bash
chmod +x scripts/verify-writing-rules.sh scripts/test-writing-rules.sh
./scripts/test-writing-rules.sh
```

Expected when Vale is already compatible:

```text
writing rule tests: PASS
```

If and only if the command reports that Vale 3.16.x is missing, install the
pinned binary into a task-local temporary directory:

```bash
mkdir -p /tmp/vale-3.16.0
curl -fsSL \
  https://github.com/vale-cli/vale/releases/download/v3.16.0/vale_3.16.0_Linux_64-bit.tar.gz \
  -o /tmp/vale-3.16.0/vale.tar.gz
printf '%s  %s\n' \
  '1049f4a585ccd1af96dcf4bdc16800cb3ce426b432da2b27893def42dcfe0ccb' \
  '/tmp/vale-3.16.0/vale.tar.gz' |
  sha256sum -c -
tar -xzf /tmp/vale-3.16.0/vale.tar.gz -C /tmp/vale-3.16.0 vale
PATH="/tmp/vale-3.16.0:$PATH" ./scripts/test-writing-rules.sh
```

Expected:

```text
/tmp/vale-3.16.0/vale.tar.gz: OK
writing rule tests: PASS
```

---

### Task 3: Repository Lint Orchestration

**Files:**
- Create: `docs/ai-writing/inventory.tsv`
- Create: `scripts/lint-docs.sh`
- Create: `scripts/test-lint-docs.sh`

**Interfaces:**
- Consumes: repository root as optional argument 1; optional `VALE_BIN`,
  `INVENTORY_CHECKER`, and `FIXTURE_VERIFIER` environment overrides
- Produces: fixture metrics and advisory Vale findings on stdout; exits nonzero
  only for inventory, fixture, configuration, dependency, or execution failures

- [ ] **Step 1: Write the failing orchestration test**

Create `scripts/test-lint-docs.sh`:

```sh
#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
LINTER="$SCRIPT_DIR/lint-docs.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/repo/docs/ai-writing" "$TMP_DIR/bin"
printf '# Advisory fixture\n' >"$TMP_DIR/repo/doc.md"
cat >"$TMP_DIR/repo/docs/ai-writing/inventory.tsv" <<'EOF'
path	profile	rationale
doc.md	explanatory	Test document
EOF

cat >"$TMP_DIR/bin/pass-checker" <<'EOF'
#!/bin/sh
exit 0
EOF

cat >"$TMP_DIR/bin/fail-checker" <<'EOF'
#!/bin/sh
printf 'ERROR: synthetic infrastructure failure\n' >&2
exit 1
EOF

cat >"$TMP_DIR/bin/fake-vale" <<'EOF'
#!/bin/sh
printf 'doc.md:1:1:Agents.Wordy:advisory finding\n'
exit 0
EOF

chmod +x "$TMP_DIR/bin/pass-checker" "$TMP_DIR/bin/fail-checker" "$TMP_DIR/bin/fake-vale"

if ! INVENTORY_CHECKER="$TMP_DIR/bin/pass-checker" \
  FIXTURE_VERIFIER="$TMP_DIR/bin/pass-checker" \
  VALE_BIN="$TMP_DIR/bin/fake-vale" \
  "$LINTER" "$TMP_DIR/repo" >"$TMP_DIR/output" 2>&1; then
  cat "$TMP_DIR/output" >&2
  printf 'advisory findings must not fail lint-docs\n' >&2
  exit 1
fi

if ! grep -F 'Agents.Wordy:advisory finding' "$TMP_DIR/output" >/dev/null; then
  cat "$TMP_DIR/output" >&2
  printf 'advisory finding was not printed\n' >&2
  exit 1
fi

if INVENTORY_CHECKER="$TMP_DIR/bin/fail-checker" \
  FIXTURE_VERIFIER="$TMP_DIR/bin/pass-checker" \
  VALE_BIN="$TMP_DIR/bin/fake-vale" \
  "$LINTER" "$TMP_DIR/repo" >"$TMP_DIR/output" 2>&1; then
  printf 'infrastructure failures must fail lint-docs\n' >&2
  exit 1
fi

printf 'lint orchestration tests: PASS\n'
```

- [ ] **Step 2: Run the orchestration test to verify it fails**

Run:

```bash
chmod +x scripts/test-lint-docs.sh
./scripts/test-lint-docs.sh
```

Expected: FAIL because `scripts/lint-docs.sh` does not exist.

- [ ] **Step 3: Implement the orchestration script**

Create `scripts/lint-docs.sh`:

```sh
#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=${1:-$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)}
VALE_BIN=${VALE_BIN:-vale}
INVENTORY_CHECKER=${INVENTORY_CHECKER:-"$SCRIPT_DIR/check-markdown-inventory.sh"}
FIXTURE_VERIFIER=${FIXTURE_VERIFIER:-"$SCRIPT_DIR/verify-writing-rules.sh"}
INVENTORY="$ROOT/docs/ai-writing/inventory.tsv"

"$INVENTORY_CHECKER" "$ROOT" "$INVENTORY"
VALE_BIN="$VALE_BIN" "$FIXTURE_VERIFIER" "$ROOT"

while IFS='	' read -r path profile rationale; do
  [ "$path" = path ] && continue
  case "$profile" in
    normative|procedure|explanatory)
      if ! (
        cd "$ROOT"
        "$VALE_BIN" --config=.vale.ini --output=line --no-exit "$path"
      ); then
        printf 'ERROR: Vale execution failed for repository file: %s\n' "$path" >&2
        exit 1
      fi
      ;;
    fixture|excluded) ;;
    *)
      printf 'ERROR: unsupported inventory profile for %s: %s\n' "$path" "$profile" >&2
      exit 1
      ;;
  esac
done <"$INVENTORY"
```

- [ ] **Step 4: Add the definitive Markdown inventory**

Create `docs/ai-writing/inventory.tsv`:

```text
path	profile	rationale
AGENTS.md	normative	Shared cross-agent behavioral instructions
README.md	explanatory	Repository overview and usage
docs/ai-writing/README.md	explanatory	Writing-check policy and rule documentation
docs/ai-writing/corpus/general/fail-in-order-to.md	fixture	Labeled intentional violation
docs/ai-writing/corpus/general/fail-low-value-leadin.md	fixture	Labeled intentional violation
docs/ai-writing/corpus/general/fail-wordy.md	fixture	Labeled intentional violation
docs/ai-writing/corpus/general/pass-clear.md	fixture	Labeled acceptable prose
docs/ai-writing/corpus/general/pass-utilization.md	fixture	Labeled acceptable technical term
docs/ai-writing/corpus/normative/fail-weak-directive.md	fixture	Labeled intentional violation
docs/ai-writing/corpus/procedure/pass-direct-procedure.md	fixture	Labeled acceptable procedure
docs/ai-writing/corpus/protected/external.md	fixture	Excluded external-content fixture
docs/ai-writing/corpus/protected/fenced-code.md	fixture	Protected-context fixture
docs/ai-writing/corpus/protected/inline-code.md	fixture	Protected-context fixture
docs/ai-writing/corpus/protected/quotation.md	fixture	Protected-context fixture
docs/superpowers/plans/2026-07-30-ai-writing-quality-enforcement.md	explanatory	Approved implementation plan
docs/superpowers/specs/2026-07-30-ai-output-enforcement-design.md	explanatory	Approved design specification
skills/add-agents-requirement/SKILL.md	procedure	Reusable agent procedure
skills/brainstorm/SKILL.md	procedure	Reusable agent procedure
skills/discussion/SKILL.md	procedure	Reusable agent procedure
skills/pre-change-gate/SKILL.md	procedure	Reusable agent procedure
```

- [ ] **Step 5: Run orchestration and inventory tests**

Run:

```bash
chmod +x scripts/lint-docs.sh scripts/test-lint-docs.sh
./scripts/test-check-markdown-inventory.sh
./scripts/test-lint-docs.sh
```

Expected:

```text
inventory validator tests: PASS
lint orchestration tests: PASS
```

- [ ] **Step 6: Run the repository lint command directly**

Run:

```bash
PATH="/tmp/vale-3.16.0:$PATH" ./scripts/lint-docs.sh
```

If Vale was already installed locally, omit the temporary `PATH` prefix.

Expected:

```text
Agents.LowValueLeadIn	tp=1	fp=0	fn=0	precision=100.00%
Agents.Wordy	tp=2	fp=0	fn=0	precision=100.00%
AgentsNormative.WeakDirective	tp=1	fp=0	fn=0	precision=100.00%
protected-context false positives: 0
```

No existing prose remediation is expected: the approved phrases occur only as
inline-code examples in the design specification, which Vale protects. Any
additional output is an unexpected verification failure: stop execution and
present the finding with its rule rationale for user adjudication.

---

### Task 4: Local and CI Policy Wiring

**Files:**
- Modify: `Makefile`
- Modify: `README.md`
- Create: `.github/workflows/lint-docs.yml`

**Interfaces:**
- Consumes: Task 3's `scripts/lint-docs.sh`
- Produces: `make lint-docs` locally and the same command in GitHub Actions

- [ ] **Step 1: Write the failing public-entry-point check**

Run:

```bash
make -n lint-docs
```

Expected: FAIL with `No rule to make target 'lint-docs'`.

- [ ] **Step 2: Add the Make target**

Append to `Makefile`:

```make
.PHONY: lint-docs
lint-docs:
	@./scripts/lint-docs.sh
```

- [ ] **Step 3: Document local usage and dependency**

Add this section to `README.md` before `## Updating`:

````markdown
## Instruction-document hygiene

Run the repository Markdown inventory, labeled-corpus checks, and advisory Vale
rules with:

```bash
make lint-docs
```

Local execution requires Vale `3.16.x`. Prose findings are warnings during the
initial rollout, while stale inventory, invalid configuration, fixture
mismatches, and linter execution errors fail the command. These checks evaluate
repository instructions and documentation; they do not observe generated
runtime output.
````

Add `Vale 3.16.x` to the `## Requirements` list:

```markdown
- Vale 3.16.x (for `make lint-docs`)
```

- [ ] **Step 4: Add the GitHub Actions workflow**

Create `.github/workflows/lint-docs.yml`:

```yaml
name: Lint documentation

on:
  pull_request:
  push:

permissions:
  contents: read

jobs:
  lint-docs:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Install Vale 3.16.0
        env:
          VALE_VERSION: 3.16.0
          VALE_SHA256: 1049f4a585ccd1af96dcf4bdc16800cb3ce426b432da2b27893def42dcfe0ccb
        run: |
          mkdir -p "$RUNNER_TEMP/vale"
          curl -fsSL \
            "https://github.com/vale-cli/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz" \
            -o "$RUNNER_TEMP/vale/vale.tar.gz"
          printf '%s  %s\n' "$VALE_SHA256" "$RUNNER_TEMP/vale/vale.tar.gz" |
            sha256sum -c -
          tar -xzf "$RUNNER_TEMP/vale/vale.tar.gz" -C "$RUNNER_TEMP/vale" vale
          echo "$RUNNER_TEMP/vale" >>"$GITHUB_PATH"

      - name: Check instruction-document hygiene
        run: make lint-docs
```

- [ ] **Step 5: Run all targeted validation**

Run:

```bash
./scripts/test-check-markdown-inventory.sh
PATH="/tmp/vale-3.16.0:$PATH" ./scripts/test-writing-rules.sh
./scripts/test-lint-docs.sh
PATH="/tmp/vale-3.16.0:$PATH" make lint-docs
```

If Vale was already installed locally, omit the temporary `PATH` prefixes.

Expected:

```text
inventory validator tests: PASS
writing rule tests: PASS
lint orchestration tests: PASS
Agents.LowValueLeadIn	tp=1	fp=0	fn=0	precision=100.00%
Agents.Wordy	tp=2	fp=0	fn=0	precision=100.00%
AgentsNormative.WeakDirective	tp=1	fp=0	fn=0	precision=100.00%
protected-context false positives: 0
```

- [ ] **Step 6: Verify the CI workflow uses the public entry point**

Run:

```bash
grep -F 'run: make lint-docs' .github/workflows/lint-docs.yml
grep -F 'VALE_VERSION: 3.16.0' .github/workflows/lint-docs.yml
grep -F 'VALE_SHA256: 1049f4a585ccd1af96dcf4bdc16800cb3ce426b432da2b27893def42dcfe0ccb' \
  .github/workflows/lint-docs.yml
```

Expected: all three lines are printed exactly once.
