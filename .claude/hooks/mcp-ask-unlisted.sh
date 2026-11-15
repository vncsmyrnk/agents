#!/usr/bin/env bash
# Ask before any MCP tool not covered by permissions.allow.
#
tool=$(jq -r '.tool_name')
settings="$HOME/.claude/settings.json"
jq -e --arg t "$tool" '
    [.permissions.allow[]? | select(startswith("mcp__"))]
    | any(. as $r | $t == $r
          or ($t | startswith(($r | rtrimstr("*") | rtrimstr("__")) + "__")))
  ' "$settings" >/dev/null 2>&1 && exit 0
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s is not in the MCP allowlist"}}\n' "$tool"
