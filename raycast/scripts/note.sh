#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title New Note
# @raycast.mode fullOutput
# @raycast.packageName NotesVault
# @raycast.icon 📝
# @raycast.argument1 { "type": "dropdown", "placeholder": "Choose mode", "data":[ { "title":"Scratch","value":"scratch" }, { "title":"Work","value":"work" }, { "title":"Personal","value":"personal" } ], "required": true }
# @raycast.argument2 { "type": "text", "placeholder": "Optional title (without extension)", "required": false }

# --- Config ---
VAULT_BASE_WORK="/Users/orbarila/Library/CloudStorage/OneDrive-Microsoft/notes_vault"
VAULT_BASE_PERSONAL="/Users/orbarila/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal"
NVIM_BIN="/opt/homebrew/bin/nvim"  # adjust if different
SHELL_BIN="${SHELL:-/bin/zsh}"
DATE_STR="$(date '+%Y-%m-%d %H:%M')"
DATE_FILE="$(date +%Y-%m-%d_%H%M%S)"

# --- Helper to open file in Ghostty ---
open_in_ghostty() {
  local args="$1"
  open -na "Ghostty" --args -e "$SHELL_BIN" "-c" "exec \"$NVIM_BIN\" $args" >/dev/null 2>&1
}

# --- Function to create Obsidian-friendly note ---
create_note() {
  local dir="$1"
  local title_input="$2"

  mkdir -p "$dir"

  if [[ -n "$title_input" ]]; then
    SAFE_TITLE="$(echo "$title_input" | sed 's/[^A-Za-z0-9 _-]/_/g')"
    FILE_NAME="${DATE_FILE}_${SAFE_TITLE// /_}.md"
    TITLE_LINE="$title_input"
  else
    FILE_NAME="${DATE_FILE}.md"
    TITLE_LINE="${DATE_FILE}"
  fi

  local file_path="$dir/$FILE_NAME"

  # YAML frontmatter + title header
  cat > "$file_path" <<EOF
---
title: "${TITLE_LINE}"
date: ${DATE_STR}
tags: []
---

# ${TITLE_LINE}

EOF

  echo "📓 Created new note: $file_path"
  open_in_ghostty "\"$file_path\""
}

# --- Main logic ---
case "$1" in
  work)
    create_note "$VAULT_BASE_WORK" "$2"
    ;;
  personal)
    create_note "$VAULT_BASE_PERSONAL" "$2"
    ;;
  scratch)
    # true in-memory scratch buffer
    open_in_ghostty "-c ':enew | set filetype=markdown'"
    echo "🧠 Opened a true scratch buffer (unsaved, in-memory)."
    ;;
  *)
    echo "Invalid selection"
    exit 1
    ;;
esac

exit 0
