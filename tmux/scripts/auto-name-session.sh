#!/usr/bin/env bash
# Auto-name unnamed (numeric) tmux sessions based on the current pane's CWD.
# Called from zsh chpwd hook when inside tmux.

# Must be inside tmux
[[ -n "$TMUX" ]] || exit 0

session=$(tmux display-message -p '#{session_name}')

# Only rename sessions with purely numeric names (unnamed sessions)
[[ "$session" =~ ^[0-9]+$ ]] || exit 0

cwd=$(tmux display-message -p '#{pane_current_path}')
[[ -n "$cwd" ]] || exit 0

name=$(basename "$cwd")
[[ -n "$name" && "$name" != "/" ]] || exit 0

# Don't rename to home directory basename (too generic)
[[ "$cwd" != "$HOME" ]] || exit 0

# Avoid collision with existing session names
if tmux has-session -t "=$name" 2>/dev/null; then
  i=2
  while tmux has-session -t "=${name}-${i}" 2>/dev/null; do
    ((i++))
  done
  name="${name}-${i}"
fi

tmux rename-session -t "$session" "$name"
