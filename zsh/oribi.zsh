# first time should first run `zsh setup.zsh` to set up the environment

# use `ZSH_PROF=1 zsh` to debug load times
if [[ $ZSH_PROF == 1 ]]; then
  zmodload zsh/zprof
fi

# basic setup
export EDITOR=nvim
export OPENCODE_CONFIG="${HOME}/.config/dotfiles/opencode/opencode.jsonc"
# end - basic setup

source "${0:A:h}/theme.zsh"
source "${0:A:h}/plugins.zsh"
source "${0:A:h}/aliases.zsh"
source "${0:A:h}/vi_mode.zsh"

if [[ $ZSH_PROF == 1 ]]; then
  zprof
fi
