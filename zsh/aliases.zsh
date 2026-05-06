alias n='nvim'
alias oc='opencode'
alias c='copilot'
alias lg='lazygit'
alias tkill='tmux ls | grep -E "^[0-9]+:" | cut -d: -f1 | xargs -n1 tmux kill-session -t'
alias tattach='tmux attach-session -t "$(tmux ls | awk -F: '\''!($1 ~ /^[0-9]+$/) {print $1}'\'' | fzf)"'
alias t='tattach'
alias y='yazi'
alias nvim-nightly='~/.local/share/bob/nightly/bin/nvim'
alias pt='presenterm'
alias bk='brainkit'
# `cc` / `claude` — run the standalone `claude` CLI against a local
# copilot-api proxy (https://github.com/ericc-ch/copilot-api), which exposes
# GitHub Copilot as an Anthropic-compatible API. This lets `claude` run on a
# Copilot subscription instead of the Anthropic API.
#
# Note: opencode does NOT need this — it talks to Copilot natively. The proxy
# exists purely so the standalone `claude` CLI works.
#
# Behavior:
#   - Auto-launches `npx copilot-api@latest start` on default port 4141 if
#     nothing is already listening, backgrounded with logs at
#     ~/.local/share/copilot-api/proxy.log
#   - Points `claude` at http://localhost:4141 with a dummy API key (real auth
#     is handled by the proxy via your GitHub account, token cached at
#     ~/.local/share/copilot-api/).
#   - `command claude` bypasses the `claude=cc` alias below to avoid recursion.
#
# First run: device-flow auth needs a TTY, so run it interactively once:
#     npx copilot-api@latest start
# Approve the code in the browser, Ctrl-C, then `cc` will auto-launch from then on.
cc() {
  local port=4141
  if ! lsof -iTCP:${port} -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    local log_dir="${HOME}/.local/share/copilot-api"
    mkdir -p "${log_dir}"
    echo "[cc] starting copilot-api proxy on :${port}..."
    nohup npx -y copilot-api@latest start >"${log_dir}/proxy.log" 2>&1 &
    disown
    local i
    for i in {1..40}; do
      sleep 0.25
      lsof -iTCP:${port} -sTCP:LISTEN -n -P >/dev/null 2>&1 && break
    done
    if ! lsof -iTCP:${port} -sTCP:LISTEN -n -P >/dev/null 2>&1; then
      echo "[cc] proxy not ready after 10s."
      echo "[cc] first run? auth interactively: npx copilot-api@latest start"
      echo "[cc] log: ${log_dir}/proxy.log"
      return 1
    fi
  fi
  ANTHROPIC_BASE_URL="http://localhost:${port}" ANTHROPIC_API_KEY=dummy command claude "$@"
}
alias claude='cc'

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
alias resource='source "${HOME}/.config/dotfiles/zsh/oribi.zsh" && tmux source-file ~/.tmux.conf 2>/dev/null; echo "[zsh + tmux reloaded]"'
# alias to update opencode via brew
alias opencode-update='brew update && brew upgrade opencode && brew cleanup opencode'

# Quick inline question to opencode (no TUI)
q() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: q <question>"
    return 1
  fi
  opencode run "$*"
}
