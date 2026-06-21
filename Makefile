AGENTS_FILE := $(abspath AGENTS.md)
SKILLS_DIR := $(abspath skills)
SKILL_PATHS := ~/.claude/skills ~/.codex/skills ~/.copilot/skills ~/.gemini/config/skills

.PHONY: install
install:
	@mkdir -p ~/.gemini
	@ln -sf $(AGENTS_FILE) ~/.gemini/GEMINI.md
	@mkdir -p ~/.claude
	@ln -sf $(AGENTS_FILE) ~/.claude/CLAUDE.md
	@mkdir -p ~/.codex
	@ln -sf $(AGENTS_FILE) ~/.codex/AGENTS.md
	@mkdir -p ~/.copilot
	@ln -sf $(AGENTS_FILE) ~/.copilot/copilot-instructions.md
	@for path in $(SKILL_PATHS); do \
		mkdir -p $$path; \
		for skill in $(SKILLS_DIR)/*/; do \
			[ -d "$$skill" ] || continue; \
			ln -sfn "$${skill%/}" "$$path/$$(basename $$skill)"; \
		done; \
	done

.PHONY: clean
clean:
	@rm -f ~/.gemini/GEMINI.md
	@rm -f ~/.claude/CLAUDE.md
	@rm -f ~/.codex/AGENTS.md
	@rm -f ~/.copilot/copilot-instructions.md
	@for path in $(SKILL_PATHS); do \
		for skill in $(SKILLS_DIR)/*/; do \
			[ -d "$$skill" ] || continue; \
			rm -f "$$path/$$(basename $$skill)"; \
		done; \
	done
