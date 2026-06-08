#!/usr/bin/env bash
# cl — wrapper around `claude -p`.
# Defaults to --model sonnet, --effort low, and --dangerously-skip-permissions,
# but forwards any other flags and lets you override the defaults:
#   - pass --model / --effort explicitly to override those defaults
#   - pass --safe to disable --dangerously-skip-permissions (--safe is consumed,
#     not forwarded to claude)
#
# Usage: cl [flags] [prompt words...]
#   cl summarize this repo
#   cl --model opus deep review          # overrides the sonnet default
#   cl --effort high tricky question     # overrides the low default
#   cl --safe do something sensitive     # keep normal permission checks
set -e

# True if $1 appears among the remaining args (as `--flag` or `--flag=value`).
has_flag() {
  local needle=$1; shift
  local a
  for a in "$@"; do
    [[ $a == "$needle" || $a == "$needle="* ]] && return 0
  done
  return 1
}

# Separate flags (and their values) from prompt words.
# Known flags that consume the next argument as their value:
VALUE_FLAGS=(--model --effort --output-format --max-turns --system-prompt --append-system-prompt --mcp-config --permission-prompt-tool --input-format --resume)

safe=false
json=false
flags=()
prompt_words=()
skip_next=false

for a in "$@"; do
  if $skip_next; then
    flags+=("$a")
    skip_next=false
    continue
  fi
  if [[ $a == --safe ]]; then
    safe=true
  elif [[ $a == -j ]]; then
    json=true
  elif [[ $a == --* ]]; then
    flags+=("$a")
    # Check if this flag consumes the next arg
    for vf in "${VALUE_FLAGS[@]}"; do
      if [[ $a == "$vf" ]]; then
        skip_next=true
        break
      fi
    done
  else
    prompt_words+=("$a")
  fi
done

set -- "${flags[@]}"

defaults=()
has_flag --model  "$@" || defaults+=(--model sonnet)
has_flag --effort "$@" || defaults+=(--effort low)
$safe || defaults+=(--dangerously-skip-permissions)
$json && { has_flag --output-format "$@" || defaults+=(--output-format json); }

prompt="${prompt_words[*]}"

if [[ -n $prompt ]]; then
  exec claude -p "${defaults[@]}" "$@" "$prompt"
else
  exec claude -p "${defaults[@]}" "$@"
fi
