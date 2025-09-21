## Load zinit
source "${ZINIT_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git}/zinit.zsh"

zlight() {
  # Use shallow clone (only latest commit) to speed up plugin install
  zinit ice depth=1
  zinit light "$@"
}

# vi mode
# zlight jeffreytse/zsh-vi-mode

# eagerly load the following plugins
zlight ajeetdsouza/zoxide
zlight zsh-users/zsh-completions

# fzf-tab for fzf picker for every completion across zsh
# this must happen before plugins that wrap widgets (e.g., zsh-autosuggestions, fast-syntax-highlighting)
# completions must happen before this
autoload -Uz compinit
compinit
zlight Aloxaf/fzf-tab

# lazy load the following plugins
zinit wait lucid for \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting

# fzf
# Loads interactive key bindings for fzf
# Ctrl+R - fuzzy search history
# Ctrl+T - fuzzy search files
[[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# activate direnv (auto load and unload .envrc files in directories)
# for python projects, add `layout python .venv` to .envrc
eval "$(direnv hook zsh)"

# yazi config
export YAZI_CONFIG_HOME=~/.config/dotfiles/yazi/

