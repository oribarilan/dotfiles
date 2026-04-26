#!/usr/bin/env bash
# Session order manager — maintains custom ordering for the sessionbar.
# Order is stored in tmux variable @session_order (comma-separated session names).
#
# Usage:
#   session-order.sh sort           — reorder by most recently used, refreshes sessionbar
#   session-order.sh next/prev      — navigate to next/prev session in custom order
#   session-order.sh move-left/move-right — swap focused session with its neighbor

sort_by_recency() {
  local sorted
  sorted=$(tmux list-sessions -F '#{session_activity} #{session_name}' | sort -rn | awk '{print $2}')

  tmux set -g @session_order "$(echo "$sorted" | tr '\n' ',' | sed 's/,$//')"
  ~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh
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

move() {
  local direction="$1"
  local current
  current=$(tmux display-message -p '#{session_name}')

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

  # Calculate swap target (no wrap — stop at edges)
  local target
  if [ "$direction" = "right" ]; then
    target=$(( cur_idx + 1 ))
    [ "$target" -ge "$total" ] && return
  else
    target=$(( cur_idx - 1 ))
    [ "$target" -lt 0 ] && return
  fi

  # Swap
  local tmp="${arr[$cur_idx]}"
  arr[$cur_idx]="${arr[$target]}"
  arr[$target]="$tmp"

  # Save and refresh
  local IFS=','
  tmux set -g @session_order "${arr[*]}"
  ~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh
}

swap_to() {
  local target_idx=$(( $1 - 1 ))  # 1-indexed input → 0-indexed array
  local current
  current=$(tmux display-message -p '#{session_name}')

  local saved
  saved=$(tmux show-option -gqv @session_order)
  [ -z "$saved" ] && return

  local -a arr=()
  while IFS= read -r s; do arr+=("$s"); done <<< "$(echo "$saved" | tr ',' '\n')"

  local total=${#arr[@]}
  [ "$target_idx" -ge "$total" ] && return
  [ "$target_idx" -lt 0 ] && return

  # Find current position
  local cur_idx=-1
  for i in "${!arr[@]}"; do
    [ "${arr[$i]}" = "$current" ] && cur_idx=$i && break
  done
  [ "$cur_idx" -lt 0 ] && return
  [ "$cur_idx" -eq "$target_idx" ] && return

  # Swap
  local tmp="${arr[$cur_idx]}"
  arr[$cur_idx]="${arr[$target_idx]}"
  arr[$target_idx]="$tmp"

  # Save and refresh
  local IFS=','
  tmux set -g @session_order "${arr[*]}"
  ~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh
}

case "$1" in
  sort) sort_by_recency ;;
  next) navigate next ;;
  prev) navigate prev ;;
  move-left)  move left ;;
  move-right) move right ;;
  swap-to)    swap_to "$2" ;;
  *)    echo "Usage: $0 {sort|next|prev|move-left|move-right|swap-to N}" >&2; exit 1 ;;
esac
