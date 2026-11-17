claudedir = @claudedir@
claudeskillsdir = $(claudedir)
claudehooksdir = $(claudedir)/hooks

copilotdir = @copilotdir@
copilotskillsdir = $(copilotdir)

SKILLS = skills/add-agents-requirement/SKILL.md \
	skills/brainstorm/SKILL.md \
	skills/discussion/SKILL.md \
	skills/pre-change-gate/SKILL.md \
	skills/session-journal/SKILL.md

CLEANFILES =
EXTRA_DIST = \
	bin/agents \
	AGENTS.md

dist_claude_DATA = \
	CLAUDE.md \
	.claude/settings.json \
	.claude/settings.unattended.json \
	.claude/default.mcp.json

dist_claudehooks_SCRIPTS = \
	.claude/hooks/mcp-ask-unlisted.sh \
	.claude/hooks/bash-ask-network.sh

dist_claude_SCRIPTS = \
	.claude/statusline-command.sh

PRIVATE_SETTINGS = $(srcdir)/.claude/settings.private.json
PRIVATE_MCP = $(srcdir)/.claude/default.mcp.private.json

install-data-hook:
	@if test -f $(PRIVATE_SETTINGS); then \
		echo "merging $(PRIVATE_SETTINGS) into $(DESTDIR)$(claudedir)/settings.json"; \
		jq -s '. as [$$a, $$b] | ($$a * $$b) | .permissions = (reduce ("allow", "ask", "deny") as $$k (.permissions // {}; (($$a.permissions[$$k] // []) + ($$b.permissions[$$k] // [])) as $$v | if $$v == [] then . else .[$$k] = $$v end))' \
			$(DESTDIR)$(claudedir)/settings.json $(PRIVATE_SETTINGS) > $(DESTDIR)$(claudedir)/settings.json.tmp && \
		mv $(DESTDIR)$(claudedir)/settings.json.tmp $(DESTDIR)$(claudedir)/settings.json; \
	fi
	@if test -f $(PRIVATE_MCP); then \
		echo "merging $(PRIVATE_MCP) into $(DESTDIR)$(claudedir)/default.mcp.json"; \
		jq -s '.[0] * .[1]' \
			$(DESTDIR)$(claudedir)/default.mcp.json $(PRIVATE_MCP) > $(DESTDIR)$(claudedir)/default.mcp.json.tmp && \
		mv $(DESTDIR)$(claudedir)/default.mcp.json.tmp $(DESTDIR)$(claudedir)/default.mcp.json; \
	fi

agents: bin/agents
	sed \
		-e 's|@CLAUDEDIR[@]|$(claudedir)|g' \
		< $< > $@
	chmod u+x $@

dist_bin_SCRIPTS = \
	agents

CLEANFILES += agents

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
