#!/usr/bin/env bash
# Claude Code status line:
#   <model display name> | [progress bar] <limit%>% (5h) | <context tokens>/<context window> tokens

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')

# Prefer the 5-hour session limit; fall back to 7-day if 5h is absent.
limit_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // .rate_limits.seven_day.used_percentage // empty')
limit_label=$(echo "$input" | jq -r 'if .rate_limits.five_hour then "5h" elif .rate_limits.seven_day then "7d" else empty end')

ctx_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Dim colors (safe on dark/light dimmed themes)
DIM="\033[2m"
RESET="\033[0m"
BAR_FILLED="\033[2;36m"  # dim cyan

build_bar() {
  pct="$1"
  width=10
  filled=$(awk -v p="$pct" -v w="$width" 'BEGIN { printf "%d", (p/100)*w }')
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  empty=$((width - filled))
  bar=""
  i=0
  while [ "$i" -lt "$filled" ]; do bar="${bar}#"; i=$((i + 1)); done
  i=0
  while [ "$i" -lt "$empty" ]; do bar="${bar}-"; i=$((i + 1)); done
  printf '%s' "$bar"
}

out="${DIM}${model}${RESET}"

if [ -n "$limit_pct" ] && [ -n "$limit_label" ]; then
  bar=$(build_bar "$limit_pct")
  pct_fmt=$(printf '%.0f' "$limit_pct")
  out="${out} ${DIM}|${RESET} ${BAR_FILLED}[${bar}]${RESET} ${DIM}${pct_fmt}% (${limit_label})${RESET}"
fi

if [ -n "$ctx_tokens" ] && [ -n "$ctx_size" ]; then
  out="${out} ${DIM}|${RESET} ${DIM}${ctx_tokens}/${ctx_size} tokens${RESET}"
fi

printf '%b\n' "$out"
