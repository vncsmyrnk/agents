#!/bin/sh
# Ask before any Bash command that requests domains outside the sandbox
# allowlist (sandbox.network.allowedDomains in ~/.claude/settings.json).
# Patterns: "*.example.com" matches subdomains; other entries match exactly.
# Fails safe: unreadable settings or unparseable input both ask.
input=$(cat)
settings="$HOME/.claude/settings.json"
allow=$(jq -c '.sandbox.network.allowedDomains // []' "$settings" 2>/dev/null) || allow='[]'
unmatched=$(printf '%s' "$input" | jq -r --argjson allow "$allow" '
  def allowed($p):
    if ($p | startswith("*.")) then endswith("." + ($p[2:])) else . == $p end;
  (.tool_input.allowed_domains // [])
  | map(. as $d | select([$allow[] as $p | $d | allowed($p)] | any | not))
  | join(", ")
' 2>/dev/null) || unmatched="(unparseable hook input)"
[ -z "$unmatched" ] && exit 0
jq -n --arg d "$unmatched" '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "ask",
  permissionDecisionReason: ("Command requests network access to non-allowlisted domains: " + $d)
}}'
