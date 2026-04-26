#!/usr/bin/env bash
# Sessionbar — renders session pills with positional indices for the tmux status line.
# Called via hooks (event-driven). Reads custom order from @session_order variable.
#
# Catppuccin mocha palette:
#   mantle=#181825  crust=#11111b  mauve=#cba6f7  overlay_2=#9399b2
#   green=#a6e3a1  yellow=#f9e2af

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

  # Check opencode state: busy (green ●) or attention (yellow 󰂞)
  agent_state=$(tmux show-option -gqv "@agent_state_${session}")

  # Resolve icon and color based on state
  oc_icon=""
  oc_color=""
  if [ "$agent_state" = "attention" ]; then
    oc_icon="󰂞"
    oc_color="#f9e2af"
  elif [ "$agent_state" = "busy" ]; then
    oc_icon="●"
    oc_color="#a6e3a1"
  elif [ "$agent_state" = "done" ]; then
    oc_icon="●"
    oc_color="#585b70"
  fi

  if [ "$session" = "$current" ]; then
    # Active: grey index | mauve name (with optional status icon)
    printf "#[fg=#9399b2,bg=#181825]"
    printf "#[fg=#11111b,bg=#9399b2] %s " "$idx"
    printf "#[fg=#cba6f7,bg=#9399b2]"
    if [ -n "$oc_icon" ]; then
      printf "#[fg=%s,bg=#cba6f7,bold]%s #[fg=#11111b,bg=#cba6f7,bold]%s " "$oc_color" "$oc_icon" "$session"
    else
      printf "#[fg=#11111b,bg=#cba6f7,bold] %s " "$session"
    fi
    printf "#[fg=#cba6f7,bg=#181825,nobold]"
  else
    # Inactive: grey pill (with optional status icon)
    printf "#[fg=#9399b2,bg=#181825]"
    if [ -n "$oc_icon" ]; then
      printf "#[fg=#11111b,bg=#9399b2] %s #[fg=%s,bg=#9399b2]%s #[fg=#11111b,bg=#9399b2]%s " "$idx" "$oc_color" "$oc_icon" "$session"
    else
      printf "#[fg=#11111b,bg=#9399b2] %s  %s " "$idx" "$session"
    fi
    printf "#[fg=#9399b2,bg=#181825]"
  fi
  printf "#[default,bg=#181825] "
done
