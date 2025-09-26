alias n='nvim'
alias lg='lazygit'
alias tkill='tmux ls | grep -E "^[0-9]+:" | cut -d: -f1 | xargs -n1 tmux kill-session -t'
alias tattach='tmux attach-session -t "$(tmux ls | awk -F: '\''!($1 ~ /^[0-9]+$/) {print $1}'\'' | fzf)"'
alias t='tattach'
alias y='yazi'

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
