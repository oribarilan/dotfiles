# Install zinit plugin manager if needed
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Install fzf if not available
if ! command -v fzf >/dev/null; then
  echo "Installing fzf..."
  brew install fzf
fi

# Install direnv if not available 
if ! command -v direnv &>/dev/null; then
  echo "Installing direnv..."
  brew install direnv
fi
