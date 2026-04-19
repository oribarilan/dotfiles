#!/usr/bin/env bash
# Session order manager — maintains custom ordering for the sessionbar.
# Order is stored in tmux variable @session_order (comma-separated session names).
#
# Usage:
#   session-order.sh sort      — reorder by most recently used, refreshes sessionbar
#   session-order.sh next/prev — navigate to next/prev session in custom order

sort_by_recency() {
  local sorted
  sorted=$(tmux list-sessions -F '#{session_activity} #{session_name}' | sort -rn | awk '{print $2}')

  tmux set -g @session_order "$(echo "$sorted" | tr '\n' ',' | sed 's/,$//')"
  tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)"
  tmux refresh-client -S
}

navigate() {
  local direction="$1"
  local current
  current=$(tmux display-message -p '#{session_name}')

  # Read directly from cached variable (fast path — no validation)
  local saved
  saved=$(tmux show-option -gqv @session_order)
  [ -z "$saved" ] && return

  local -a arr=()
  while IFS= read -r s; do arr+=("$s"); done <<< "$(echo "$saved" | tr ',' '\n')"

  local total=${#arr[@]}
  [ "$total" -le 1 ] && return

  # Find current position
  local cur_idx=-1
  for i in "${!arr[@]}"; do
    [ "${arr[$i]}" = "$current" ] && cur_idx=$i && break
  done
  [ "$cur_idx" -lt 0 ] && return

  # Wrap around
  local target
  if [ "$direction" = "next" ]; then
    target=$(( (cur_idx + 1) % total ))
  else
    target=$(( (cur_idx - 1 + total) % total ))
  fi

  tmux switch-client -t "${arr[$target]}"
}

case "$1" in
  sort) sort_by_recency ;;
  next) navigate next ;;
  prev) navigate prev ;;
  *)    echo "Usage: $0 {sort|next|prev}" >&2; exit 1 ;;
esac
