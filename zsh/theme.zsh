# Enable Powerlevel10k instant prompt. Should stay at the very top of zsh config.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# Only enable instant prompt for real interactive shells (not for -c commands)
if [[ -o interactive ]] && [[ -z "$ZSH_SCRIPT" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# cache brew prefix to avoid slow subprocess calls (if not already set)
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"

# if p10k installed via homebrew, follow the installation
source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
