alias n='nvim'
alias lg='lazygit'
alias tkill='tmux ls | grep -E "^[0-9]+:" | cut -d: -f1 | xargs -n1 tmux kill-session -t'
alias tattach='tmux attach-session -t "$(tmux ls | awk -F: '\''!($1 ~ /^[0-9]+$/) {print $1}'\'' | fzf)"'
alias t='tattach'
alias y='yazi'
alias nvim-nightly='~/.local/share/bob/nightly/bin/nvim'

# Quick directory back navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# # zoxide jump with fuzzy matching of path 
# alias z='zoxide jump'
# cd into any folder with zoxide and fzf
unalias zi 2>/dev/null
zi() {
  local dest
  dest=$(zoxide query --interactive) || return
  cd "$dest"
}

# alias to re-source oribi.zsh
alias resource='source "${HOME}/.config/dotfiles/zsh/oribi.zsh" && echo "[oribi.zsh reloaded]"'
# alias to update opencode via brew
alias opencode-update='brew update && brew upgrade opencode && brew cleanup opencode'
