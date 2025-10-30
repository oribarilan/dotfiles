#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Open Notes
# @raycast.mode fullOutput
# @raycast.packageName NotesVault
# @raycast.icon 📝
# @raycast.argument1 { "type": "dropdown", "placeholder": "Choose vault", "data":[ { "title":"Work","value":"work" }, { "title":"Personal","value":"personal" } ], "required": true }

# --- Config ---
VAULT_BASE_WORK="/Users/orbarila/Library/CloudStorage/OneDrive-Microsoft/notes_vault"
VAULT_BASE_PERSONAL="/Users/orbarila/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal"
NVIM_BIN="/opt/homebrew/bin/nvim"
SHELL_BIN="${SHELL:-/bin/zsh}"

# --- Helper to open directory in Ghostty ---
open_in_ghostty() {
  local dir="$1"
  open -na "Ghostty" --args -e "$SHELL_BIN" "-c" "cd \"$dir\" && exec \"$NVIM_BIN\" ." >/dev/null 2>&1
}

# --- Main logic ---
case "$1" in
  work)
    echo "📓 Opening work vault in nvim: $VAULT_BASE_WORK"
    open_in_ghostty "$VAULT_BASE_WORK"
    ;;
  personal)
    echo "📓 Opening personal vault in nvim: $VAULT_BASE_PERSONAL"
    open_in_ghostty "$VAULT_BASE_PERSONAL"
    ;;
  *)
    echo "Invalid selection"
    exit 1
    ;;
esac

exit 0
