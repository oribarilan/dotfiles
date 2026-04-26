#!/usr/bin/env bash
# Refreshes the sessionbar — single source of truth for the refresh command.
# Called from tmux hooks (status.conf), opencode plugin (tmux-status.ts),
# and session-order.sh.
tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)"
tmux refresh-client -S
