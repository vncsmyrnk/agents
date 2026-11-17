#!/bin/sh
# Ask before any Bash command that requests network access beyond the sandbox
# allowlist. In auto mode, the Bash tool's `allowed_domains` input is the only
# way to reach a non-allowlisted host, so checking it covers every case.
# Fails safe: unparseable input also asks.
input=$(cat)
domains=$(printf '%s' "$input" | jq -r '(.tool_input.allowed_domains // []) | join(", ")' 2>/dev/null) \
  || domains="(unparseable hook input)"
[ -z "$domains" ] && exit 0
jq -n --arg d "$domains" '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "ask",
  permissionDecisionReason: ("Command requests network access to non-allowlisted domains: " + $d)
}}'
