#!/usr/bin/env bash
# Sets the agent state tmux variable for the current session.
# Usage: set-state.sh <busy|attention|idle|clear>
#
# Resolves the tmux session from $TMUX_PANE. If not in tmux, exits silently.

STATE="${1:-idle}"
PANE="$TMUX_PANE"

# Not in tmux — nothing to do
[ -z "$PANE" ] && exit 0

# Resolve tmux session name
SESSION=$(tmux display-message -t "$PANE" -p '#{session_name}' 2>/dev/null) || exit 0
[ -z "$SESSION" ] && exit 0

case "$STATE" in
  busy|attention)
    tmux set -g "@agent_state_${SESSION}" "$STATE" 2>/dev/null
    ;;
  idle)
    # If user is in another session, mark as "done" (unread indicator)
    ACTIVE=$(tmux display-message -p '#{client_session}' 2>/dev/null)
    if [ "$ACTIVE" = "$SESSION" ]; then
      tmux set -gu "@agent_state_${SESSION}" 2>/dev/null
    else
      tmux set -g "@agent_state_${SESSION}" "done" 2>/dev/null
    fi
    ;;
  clear)
    tmux set -gu "@agent_state_${SESSION}" 2>/dev/null
    ;;
esac

# Refresh the sessionbar
~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh 2>/dev/null

exit 0
