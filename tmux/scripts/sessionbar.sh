#!/usr/bin/env bash
# Sessionbar — renders session pills with positional indices for the tmux status line.
# Called via hooks (event-driven). Reads custom order from session-order.sh.
#
# Catppuccin mocha palette:
#   mantle=#181825  crust=#11111b  mauve=#cba6f7  overlay_2=#9399b2

current=$(tmux display-message -p '#{client_session}')

idx=0
~/.config/dotfiles/tmux/scripts/session-order.sh get | while IFS= read -r session; do
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
