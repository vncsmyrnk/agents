# agents

A single, generic [`AGENTS.md`](AGENTS.md) shared across every AI CLI agent. It defines the **behavioral base layer** — *how* an agent should work (clarify, plan, get approval, document, commit) — independent of any specific project.

Instead of maintaining one instruction file per tool, this repo keeps one source of truth and symlinks it into each tool's expected location.

## Install

```bash
make install
```

This symlinks `AGENTS.md` into the locations each agent reads on startup:

| Tool | Location |
| --- | --- |
| Gemini | `~/.gemini/GEMINI.md` |
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex / Cursor | `~/.codex/AGENTS.md` |
| GitHub Copilot | `~/.github/copilot-instructions.md` |

Because these are symlinks (`ln -sf`), edits to `AGENTS.md` in this repo take effect immediately for every tool — no reinstall needed.

## Updating

Edit [`AGENTS.md`](AGENTS.md) directly. The change propagates to all tools through the existing symlinks.

Re-run `make install` only when:
- A target file was deleted or replaced with a non-symlink.
- You add a new agent location to the [`Makefile`](Makefile).

## Precedence

The rules in `AGENTS.md` are the base layer. A project's own `AGENTS.md` and any explicit in-session user instruction take precedence over it — see the **Precedence** section in [`AGENTS.md`](AGENTS.md).

## Requirements

- GNU Make
- A POSIX shell with `ln` and `mkdir` (Linux/macOS)
