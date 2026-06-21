AGENTS_FILE := $(abspath AGENTS.md)

.PHONY: install
install:
	@mkdir -p ~/.gemini
	@ln -sf $(AGENTS_FILE) ~/.gemini/GEMINI.md
	@mkdir -p ~/.claude
	@ln -sf $(AGENTS_FILE) ~/.claude/CLAUDE.md
	@mkdir -p ~/.codex
	@ln -sf $(AGENTS_FILE) ~/.codex/AGENTS.md
	@mkdir -p ~/.github
	@ln -sf $(AGENTS_FILE) ~/.github/copilot-instructions.md
