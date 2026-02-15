# Agent Guidelines for Dotfiles Repository

## Overview
This is a personal dotfiles configuration repository for neovim, tmux, zsh, ghostty, yazi, raycast, keyd, and sesh.

**This is a public repository. Never commit sensitive information** (passwords, API keys, tokens, private paths, etc.).

## Dotfiles Management Principles

### Single Source of Truth
All configuration files live in this repository (`~/.dotfiles`). They are linked to their expected system locations via **symlinks**. Never copy config files from this repo to their target locations — always symlink so that edits to the dotfile are immediately reflected system-wide.

### Adding a New Tool Config
1. Create a directory in this repo named after the tool (e.g., `keyd/`).
2. Place the config file(s) inside that directory.
3. Symlink from the system's expected config path to the file in this repo.
4. Document the symlink command in both `README.md` (under the tool's section) and `machine_setup.md` (under the relevant OS section).

### Platform-Specific vs Cross-Platform
- Most tools here are **cross-platform** (nvim, tmux, zsh, ghostty, yazi, sesh). Their configs are shared across macOS and Linux.
- **Platform-specific tools** (e.g., keyd for Linux, Raycast for macOS) still get their own top-level directory — do not nest them under an OS-specific folder.
- Platform-specific notes and setup instructions go in `machine_setup.md` under the relevant OS heading (`## Mac`, `## Linux (Ubuntu)`, `## Windows`).

### Linux Compatibility
The zsh/tmux configs were originally written for macOS with Homebrew. On Linux, **do not modify the shared configs** to add Linux support. Instead:
- Use the `~/.zshrc` on the Linux machine as an override layer that shims Homebrew paths and aliases (e.g., `pbcopy` → `xclip`, `fd` → `fdfind`) before sourcing the dotfiles config.
- A symlink `~/.config/dotfiles` → `~/.dotfiles` exists to bridge path differences.
- keyd runs as a systemd service (root). It **cannot launch GUI apps** via `command()`. Instead, have keyd emit key combos and bind those in GNOME shortcuts.
- On Ubuntu, `fd` is packaged as `fd-find` (binary: `fdfind`), and fzf shell integrations live at `/usr/share/doc/fzf/examples/`.
- Neovim is installed as an AppImage at `~/.local/bin/nvim` (Ubuntu's apt version is too old).

### GNOME Wayland Focus-or-Launch
On GNOME Wayland, external processes cannot focus existing windows — X11 tools (`wmctrl`, `xdotool`) can't see Wayland windows, and GNOME's `FocusApp` D-Bus method is permission-locked. The workaround is a custom GNOME Shell extension (`focus-or-launch@dotfiles` in `keyd/gnome-extension/`) that:
- Exposes a D-Bus method callable from scripts
- Runs inside GNOME Shell, so it has access to `Shell.AppSystem` and `activate_with_focus()`
- Is called by `keyd/scripts/focus-or-launch` which GNOME shortcuts invoke

When adding a new Hyper+key hotkey for an app:
1. Find the app's `.desktop` file ID (e.g., `com.mitchellh.ghostty`, `firefox_firefox`)
2. Add a GNOME custom shortcut that runs `~/.dotfiles/keyd/scripts/focus-or-launch <desktop-id>`
3. No changes to keyd config or the extension are needed — only a new `gsettings` entry
4. Document the new binding in `machine_setup.md` under GNOME Hotkeys

## Testing
- **Neovim Tests**: Use neotest plugin
  - Run nearest test: `<leader>tn` or `:lua require('neotest').run.run()`
  - Run file tests: `<leader>tf` or `:lua require('neotest').run.run(vim.fn.expand '%')`
  - Debug test: `<leader>td` (uses DAP)
- **Manual Testing**: Use sample projects in `nvim/samples/` (python, dotnet)

## Code Style

### Lua (Neovim config)
- **Indentation**: 2 spaces (enforced by stylua)
- **Quotes**: Auto-prefer single quotes
- **Line width**: 160 characters
- **Call parentheses**: None (stylua config)
- **Formatter**: `stylua` - Format with `<leader>f`
- **Naming**: snake_case for functions/variables, PascalCase for classes
- **Requires**: Use single quotes, no parentheses: `require 'module'`
- **Plugin structure**: Return table with lazy.nvim spec, use `keys`/`config`/`opts` fields
- **Comments**: Use `--` for single line, document complex logic inline

### Shell Scripts (zsh, bash)
- **Indentation**: 2 spaces
- **Use local functions** where possible
- **Quote variables** to prevent word splitting

## LSP & Tooling
- **Python**: pyright (types only), ruff (linting/formatting/imports)
- **Lua**: lua_ls, stylua
- **C#/.NET**: roslyn
- **JSON/YAML/Markdown**: jsonls, yamlls, marksman + respective linters
