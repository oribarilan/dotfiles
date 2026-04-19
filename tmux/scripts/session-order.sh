#!/usr/bin/env bash
# Session order manager — maintains custom ordering for the sessionbar.
# Order is stored in tmux variable @session_order (comma-separated session names).
#
# Usage:
#   session-order.sh get       — prints ordered session names, one per line
#   session-order.sh sort      — reorder by most recently used, refreshes sessionbar

get_order() {
  local saved actual
  saved=$(tmux show-option -gqv @session_order)
  actual=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

  if [ -z "$saved" ]; then
    tmux set -g @session_order "$(echo "$actual" | tr '\n' ',' | sed 's/,$//')"
    echo "$actual"
    return
  fi

  # Build ordered list: saved entries that still exist, then any new sessions
  local result=()
  while IFS= read -r s; do
    echo "$actual" | grep -qxF "$s" && result+=("$s")
  done <<< "$(echo "$saved" | tr ',' '\n')"

  while IFS= read -r s; do
    echo "$saved" | tr ',' '\n' | grep -qxF "$s" || result+=("$s")
  done <<< "$actual"

  tmux set -g @session_order "$(IFS=','; echo "${result[*]}")"
  printf '%s\n' "${result[@]}"
}

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

  local -a arr=()
  while IFS= read -r s; do arr+=("$s"); done <<< "$(get_order)"

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
  get)  get_order ;;
  sort) sort_by_recency ;;
  next) navigate next ;;
  prev) navigate prev ;;
  *)    echo "Usage: $0 {get|sort|next|prev}" >&2; exit 1 ;;
esac
