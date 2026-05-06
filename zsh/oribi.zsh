# first time should first run `zsh setup.zsh` to set up the environment

# auto-start tmux for interactive shells
if command -v tmux &>/dev/null && [[ "$TERM_PROGRAM" == "ghostty" && -z "$TMUX" && $- == *i* ]]; then
  # Ghostty quick terminal: dedicated `brain-qt` session, no status bar
  if [[ -n "$GHOSTTY_QUICK_TERMINAL" ]]; then
    exec tmux new-session -A -s brain-qt -c "$HOME/repos/personal/brain" \; set status off
  fi
  exec tmux new-session
fi

# use `ZSH_PROF=1 zsh` to debug load times
if [[ $ZSH_PROF == 1 ]]; then
  zmodload zsh/zprof
fi

# basic setup
export EDITOR=nvim
export OPENCODE_CONFIG="${HOME}/.config/dotfiles/opencode/opencode.jsonc"
export OPENCODE_CONFIG_DIR="${HOME}/.config/dotfiles/opencode/"
# copilot - keep all state inside the dotfiles repo
export COPILOT_HOME="${HOME}/.config/dotfiles/copilot"
# shared agent instructions (loaded by copilot in addition to its built-in lookups).
# Copilot CLI 1.0.42 does NOT auto-load AGENTS.md from this env var, so the
# functional channel is copilot/copilot-instructions.md (symlinked to
# ../agents/AGENTS.md). Env var stays set for forward compatibility.
export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="${HOME}/.config/dotfiles/agents"
export PRESENTERM_CONFIG_FILE="${HOME}/.config/dotfiles/presenterm/config.yaml"
export PI_CODING_AGENT_DIR="${HOME}/.config/dotfiles/pi"
export PATH="$PATH:/Users/orbarila/go/bin"
# end - basic setup

source "${0:A:h}/theme.zsh"
source "${0:A:h}/plugins.zsh"
source "${0:A:h}/aliases.zsh"
source "${0:A:h}/vi_mode.zsh"

# auto-name unnamed tmux sessions based on CWD
_auto_name_tmux_session() { ~/.config/dotfiles/tmux/scripts/auto-name-session.sh }
chpwd_functions=(${chpwd_functions:#_auto_name_tmux_session} _auto_name_tmux_session)

if [[ $ZSH_PROF == 1 ]]; then
  zprof
fi
