#!/usr/bin/env bash
# Session order manager — maintains custom ordering for the sessionbar.
# Order is stored in tmux variable @session_order (comma-separated session names).
#
# Usage:
#   session-order.sh get       — prints ordered session names, one per line
#   session-order.sh swap N    — swaps current session with position N, refreshes sessionbar

get_order() {
  local saved actual
  saved=$(tmux show-option -gqv @session_order)
  actual=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

  if [ -z "$saved" ]; then
    # No custom order — initialize from current sessions
    tmux set -g @session_order "$(echo "$actual" | paste -sd ',')"
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

  # Persist cleaned order
  tmux set -g @session_order "$(IFS=','; echo "${result[*]}")"
  printf '%s\n' "${result[@]}"
}

swap() {
  local pos="$1"
  local current
  current=$(tmux display-message -p '#{session_name}')

  # Read current order into array
  local -a arr=()
  while IFS= read -r s; do arr+=("$s"); done <<< "$(get_order)"

  # Find current session's index
  local cur_idx=-1
  for i in "${!arr[@]}"; do
    [ "${arr[$i]}" = "$current" ] && cur_idx=$i && break
  done

  # Validate
  local target=$((pos - 1))
  if [ "$cur_idx" -lt 0 ] || [ "$target" -lt 0 ] || [ "$target" -ge "${#arr[@]}" ] || [ "$cur_idx" -eq "$target" ]; then
    return
  fi

  # Swap and save
  local tmp="${arr[$cur_idx]}"
  arr[$cur_idx]="${arr[$target]}"
  arr[$target]="$tmp"

  tmux set -g @session_order "$(IFS=','; echo "${arr[*]}")"
  tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)"
  tmux refresh-client -S
}

case "$1" in
  get)  get_order ;;
  swap) swap "$2" ;;
  *)    echo "Usage: $0 {get|swap N}" >&2; exit 1 ;;
esac
