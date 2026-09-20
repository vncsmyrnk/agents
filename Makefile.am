claudedir = @claudedir@
claudeskillsdir = $(claudedir)

copilotdir = @copilotdir@
copilotskillsdir = $(copilotdir)

SKILLS = skills/add-agents-requirement/SKILL.md \
	skills/brainstorm/SKILL.md \
	skills/discussion/SKILL.md \
	skills/pre-change-gate/SKILL.md

CLEANFILES =
EXTRA_DIST = \
	AGENTS.md

dist_claude_DATA = \
	CLAUDE.md \
	.claude/settings.json

dist_claude_SCRIPTS = \
	.claude/statusline-command.sh

CLAUDE.md: AGENTS.md
	cp $< $@

CLEANFILES += CLAUDE.md

nobase_dist_claudeskills_DATA = $(SKILLS)

dist_copilot_DATA = \
	copilot-instructions.md \
	.copilot/settings.json

copilot-instructions.md: AGENTS.md
	cp $< $@

CLEANFILES += copilot-instructions.md

nobase_dist_copilotskills_DATA = $(SKILLS)
