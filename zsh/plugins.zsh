## Load zinit
source "${ZINIT_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git}/zinit.zsh"

zlight() {
  # Use shallow clone (only latest commit) to speed up plugin install
  zinit ice depth=1
  zinit light "$@"
}

# vi mode
# i prefer to set up my own vi-mode (see /vi_mode.zsh)
# but this plugin is also nice
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

# direnv
# activate direnv (auto load and unload .envrc files in directories)
# for python projects, add `layout python .venv` to .envrc
eval "$(direnv hook zsh)"
# force direnv to run on shell startup, otherwise it only takes effect on cd (for this setup, important for tmux/sesh)
if [[ -n "$PWD" ]]; then
  direnv export zsh > /dev/null
fi

# yazi config
export YAZI_CONFIG_HOME=~/.config/dotfiles/yazi/

# sesh (outside tmux)
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c --icons | fzf \
      --height 40% --reverse --ansi \
      --border-label ' sesh ' --prompt '⚡  ' \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -t -c --icons)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list -t -c --icons)' \
      --preview-window 'right:55%' \
      --preview 'sesh preview {}')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect "$session"
  }
}

zle -N sesh-sessions
bindkey -M emacs '^A' sesh-sessions
bindkey -M vicmd '^A' sesh-sessions
bindkey -M viins '^A' sesh-sessions
