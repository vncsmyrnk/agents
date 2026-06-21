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

.PHONY: clean
clean:
	@rm -f ~/.gemini/GEMINI.md
	@rm -f ~/.claude/CLAUDE.md
	@rm -f ~/.codex/AGENTS.md
	@rm -f ~/.github/copilot-instructions.md
