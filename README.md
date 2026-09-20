[![GitHub main branch check runs](https://img.shields.io/github/check-runs/vncsmyrnk/agents/main?style=plastic&logo=github&label=CI%20workflow)](https://github.com/vncsmyrnk/agents/actions/workflows/ci.yaml)

A single, generic [`AGENTS.md`](AGENTS.md) shared across every AI CLI agent. It defines the **behavioral base layer** — *how* an agent should work (clarify, plan, get approval, document, commit) — independent of any specific project.

Instead of maintaining one instruction file per tool, this repo keeps one source of truth.

## Install

```bash
autoreconf -fi
./configure
make install
```

This copies `AGENTS.md` into the locations each agent reads on startup:

| Tool | Location |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` |
| GitHub Copilot | `~/.copilot/copilot-instructions.md` |

## Skills

Reusable [Agent Skills](https://code.claude.com/docs/en/skills) live under [`skills/`](skills), one directory per skill (`skills/<name>/SKILL.md` plus any supporting files). `SKILL.md` is a shared, cross-tool format, so the same skill is distributed to every supported agent.

`make install` copies each skill directory into each tool's skills path:

| Tool | Location |
| --- | --- |
| Claude Code | `~/.claude/skills/<name>` |
| GitHub Copilot | `~/.copilot/skills/<name>` |

### Included skills

- `add-agents-requirement` — guides safe edits to the shared `AGENTS.md`
  behavioral rules.
- `brainstorm` — interviews the user to capture the goal document, first
  assumptions, a working hypothesis, and clear goals before drafting.
- `discussion` — pressure-tests a clear goal and partial approach as a loyal
  opposition, to avoid already-solved problems and proven-bad paths.
- `pre-change-gate` — the gate every change passes before editing: explore,
  clarify, cover impact, define validation, plan, and get approval.

## Precedence

The rules in `AGENTS.md` are the base layer. A project's own `AGENTS.md` and any explicit in-session user instruction take precedence over it — see the **Precedence** section in [`AGENTS.md`](AGENTS.md).
