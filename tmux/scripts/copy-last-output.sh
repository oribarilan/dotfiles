#!/usr/bin/env bash
# Copy the output of the last command from the current tmux pane to clipboard.
# Detects command boundaries using the Powerlevel10k prompt character (❯/❮).
#
# Usage: bind to a tmux key, e.g.:
#   bind Y run-shell "~/.config/dotfiles/tmux/scripts/copy-last-output.sh"

set -euo pipefail

# p10k prompt chars: vi-insert ❯, vi-cmd ❮ (skip V/▶ — too generic)
PROMPT_PATTERN='[❯❮]'

# Capture full scrollback as plain text (ANSI stripped)
content=$(tmux capture-pane -p -S -)

# Find line numbers of the last two prompt lines
prompt_nums=$(echo "$content" | grep -n "$PROMPT_PATTERN" | tail -2 | cut -d: -f1)
second_last=$(echo "$prompt_nums" | head -1)
last=$(echo "$prompt_nums" | tail -1)

if [[ -z "$second_last" || -z "$last" || "$second_last" == "$last" ]]; then
  tmux display-message "Could not find two prompt boundaries"
  exit 0
fi

# Extract everything between the two prompt lines (the command output)
start=$((second_last + 1))
end=$((last - 1))

if [[ $start -gt $end ]]; then
  tmux display-message "No output from last command"
  exit 0
fi

# Get output lines, strip trailing blank lines
output=$(echo "$content" | sed -n "${start},${end}p" | sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}')

if [[ -z "$output" ]]; then
  tmux display-message "No output from last command"
  exit 0
fi

# Copy to system clipboard
if command -v pbcopy &>/dev/null; then
  printf '%s' "$output" | pbcopy
elif command -v xclip &>/dev/null; then
  printf '%s' "$output" | xclip -selection clipboard
elif command -v xsel &>/dev/null; then
  printf '%s' "$output" | xsel --clipboard
else
  tmux display-message "No clipboard tool found"
  exit 1
fi

line_count=$(echo "$output" | wc -l | tr -d ' ')
tmux display-message "Copied $line_count lines of last command output"
