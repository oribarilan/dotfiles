#!/usr/bin/env bash
# Sessionbar — renders session pills with positional indices for the tmux status line.
# Called via hooks (event-driven). Reads custom order from @session_order variable.
#
# Catppuccin mocha palette:
#   mantle=#181825  crust=#11111b  mauve=#cba6f7  overlay_2=#9399b2

current=$(tmux display-message -p '#{client_session}')

# Read order from cached variable, sync with live sessions
saved=$(tmux show-option -gqv @session_order)
actual=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

if [ -n "$saved" ]; then
  # Build synced order: saved entries that still exist, then new sessions
  sessions=""
  while IFS= read -r s; do
    echo "$actual" | grep -qxF "$s" && sessions="${sessions}${sessions:+$'\n'}${s}"
  done <<< "$(echo "$saved" | tr ',' '\n')"
  while IFS= read -r s; do
    echo "$saved" | tr ',' '\n' | grep -qxF "$s" || sessions="${sessions}${sessions:+$'\n'}${s}"
  done <<< "$actual"
  # Persist synced order
  tmux set -g @session_order "$(echo "$sessions" | tr '\n' ',' | sed 's/,$//')"
else
  sessions="$actual"
  tmux set -g @session_order "$(echo "$actual" | tr '\n' ',' | sed 's/,$//')"
fi

idx=0
echo "$sessions" | while IFS= read -r session; do
  # Skip dead sessions
  echo "$actual" | grep -qxF "$session" || continue
  idx=$((idx + 1))

  if [ "$session" = "$current" ]; then
    # Active: grey index | mauve name
    printf "#[fg=#9399b2,bg=#181825]"
    printf "#[fg=#11111b,bg=#9399b2] %s " "$idx"
    printf "#[fg=#cba6f7,bg=#9399b2]"
    printf "#[fg=#11111b,bg=#cba6f7,bold] %s " "$session"
    printf "#[fg=#cba6f7,bg=#181825,nobold]"
  else
    # Inactive: grey index | grey name (same color both halves)
    printf "#[fg=#9399b2,bg=#181825]"
    printf "#[fg=#11111b,bg=#9399b2] %s  %s " "$idx" "$session"
    printf "#[fg=#9399b2,bg=#181825]"
  fi
  printf "#[default,bg=#181825] "
done
