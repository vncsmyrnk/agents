claudedir = @claudedir@
claudeskillsdir = $(claudedir)

copilotdir = @copilotdir@
copilotskillsdir = $(copilotdir)

agentsdir = $(datadir)/agents

SKILLS = skills/add-agents-requirement/SKILL.md \
	skills/brainstorm/SKILL.md \
	skills/discussion/SKILL.md \
	skills/pre-change-gate/SKILL.md \
	skills/session-journal/SKILL.md

CLEANFILES =
EXTRA_DIST = \
	AGENTS.md

dist_claude_DATA = \
	CLAUDE.md \
	.claude/settings.json \
	.claude/settings.unattended.json \
	.claude/default.mcp.json

dist_claude_SCRIPTS = \
	.claude/statusline-command.sh

claude-unattended: bin/claude-unattended
	sed \
		-e 's|@DATADIR[@]|$(pkgdatadir)|g' \
		-e 's|@AGENTSDIR[@]|$(agentsdir)|g' \
		-e 's|@CLAUDEDIR[@]|$(claudedir)|g' \
		-e 's|@SRT[@]|$(SRT)|g' < $< > $@
	chmod u+x $@

dist_bin_SCRIPTS = claude-unattended
agents_DATA = srt-settings.json

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
