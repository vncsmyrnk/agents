claudedir = @claudedir@
claudeskillsdir = $(claudedir)
claudehooksdir = $(claudedir)/hooks

copilotdir = @copilotdir@
copilotskillsdir = $(copilotdir)

claudebuilddir =  .claude-out
$(claudebuilddir):
	mkdir $(claudebuilddir)

copilotbuilddir =  .copilot-out
$(copilotbuilddir):
	mkdir $(copilotbuilddir)

SKILLS = skills/add-agents-requirement/SKILL.md \
	skills/brainstorm/SKILL.md \
	skills/discussion/SKILL.md \
	skills/pre-change-gate/SKILL.md \
	skills/session-journal/SKILL.md

CLEANFILES =
EXTRA_DIST = \
	bin/agents \
	.claude/settings.json \
	.claude/settings.private.json \
	AGENTS.md

dist_claude_DATA = \
	$(claudebuilddir)/CLAUDE.md \
	$(claudebuilddir)/settings.json \
	$(claudebuilddir)/default.mcp.json \
	.claude/settings.unattended.json

dist_claudehooks_SCRIPTS = \
	.claude/hooks/mcp-ask-unlisted.sh \
	.claude/hooks/bash-ask-network.sh

dist_claude_SCRIPTS = \
	.claude/statusline-command.sh

agents: bin/agents
	sed \
		-e 's|@CLAUDEDIR[@]|$(claudedir)|g' \
		< $< > $@
	chmod u+x $@

dist_bin_SCRIPTS = \
	agents

CLEANFILES += agents

$(claudebuilddir)/CLAUDE.md: AGENTS.md | $(claudebuilddir)
	cp $< $@

CLEANFILES += $(claudebuilddir)/CLAUDE.md

$(claudebuilddir)/settings.json: .claude/settings.json .claude/settings.private.json | $(claudebuilddir)
	@if [ ! -f .claude/settings.private.json ]; then \
		cp $< $@; \
		exit 0; \
	fi
	./build/merge-json $^ > $@

CLEANFILES += $(claudebuilddir)/settings.json

.claude/settings.private.json:
	echo "{}" > $@

$(claudebuilddir)/default.mcp.json: .claude/default.mcp.json .claude/default.mcp.private.json | $(claudebuilddir)
	@if [ ! -f .claude/default.mcp.private.json ]; then \
		cp $< $@; \
		exit 0; \
	fi
	./build/merge-json $^ > $@

CLEANFILES += $(claudebuilddir)/default.mcp.json

.claude/default.mcp.private.json:
	echo "{}" > $@

nobase_dist_claudeskills_DATA = $(SKILLS)

dist_copilot_DATA = \
	$(copilotbuilddir)/copilot-instructions.md \
	.copilot/settings.json

$(copilotbuilddir)/copilot-instructions.md: AGENTS.md | $(copilotbuilddir)
	cp $< $@

CLEANFILES += $(copilotbuilddir)/copilot-instructions.md

nobase_dist_copilotskills_DATA = $(SKILLS)
