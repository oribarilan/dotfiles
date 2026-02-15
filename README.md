# dotfiles

## tmux

<details>
<summary>Installation</summary>

1. Install tmux
2. Install tmux package manager (`tpm`) from https://github.com/tmux-plugins/tpm
3. Install `sesh` (using brew) and set up its own config using symlink (`ln -s /path/to/dotfiles/sesh ~/.config/sesh`)
</details>

<details>

<summary>Session Management</summary>

- `<C-a>` (Ctrl-a) in zsh - open sesh session manager and jump into selected session
- `<leader>a` (Ctrl-a + a) in tmux - open sesh session manager to switch sessions

<summary>Core Features</summary>

- <C-h/j/k/l> pane navigation in tmux & nvim
- <C-a> leader for tmux
- <C-a>F for tmux fzf (session management)
- <C-a>- split horizontally
- <C-a>\ split vertically
- <C-a>x kill pane
- <C-a>z zoom pane (default)
- <C-a>h/j/k/l resize current pane (repeatable)
- <C-a>Escpae - enter copy mode, q to exit, v to start selection, y to copy (vi mode enabled)

</details>

<details>
<summary>TODOs</summary>

- [x] easier keymap for creating and deleting splits
- [ ] session management and navigation
- [ ] omerxx/tmux-sessionx

</details>

## nvim

<details>
<summary>Installation</summary>

- create a symlink between default nvim config (e.g., `~/.config/nvim`) and this repo's nvim config:

```bash
ln -s ~/path/to/dotfiles/nvim ~/.config/nvim
```

Note: we are using symlink (instead of bootstrapping like other tools here) for nvim specifically
because of tools like lazy.nvim that will create a lazy-lock.json file in the nvim config directory.

</details>

<details>
<summary>Core Features</summary>

<details>
<summary>General</summary>

- <space> leader for nvim
- autoread

- Copilot:
  - italic with distinct subtle color
  - using option key for managing suggestions:
  - opt-y : accept suggestion
  - opt-l : accept word
  - opt-n : dismiss suggestion
  - opt-j : next suggestion
  - opt-k : previous suggestion
  - Commands:
    - `:CopilotDisable` - disable Copilot and Sidekick NES
    - `:CopilotEnable` - enable Copilot and Sidekick NES

</details>

<details>
<summary>Language Support (LSPs, formatters, linters)</summary>

Using the "old" nvim-lspconfig lsp setup

- python - pyright, ruff
- dotnet - roslyn

- lua - lua_ls, stylua
- json - jsonls, jsonlint
- yaml - yamlls, yamllint
- markdown - markdownlint

</details>

<details>
<summary>Navigation & Search</summary>

- <leader>e/E - toggle file explorer / open current file in explorer (mini.files). edit as buffer, use `=` to save changes
- <leader>s - telescope find
- <C-j/k> - for up/down in pickers (telescope/cmp)
- s - search using flash
- S - treesitter highlight search using flash

</details>

<details>
<summary>Completions</summary>

- <M-j/k> - switch between copilot suggestions
- <M-l> - accept copilot next word
- <M-y/n> - accept/dismiss copilot suggestion
- K - show LSP hover (click again for focus)
- <leader>k - show diagnostics hover (click again for focus)

</details>

<details>
<summary>Search</summary>


</details>

</details>

<details>
<summary>TODOs</summary>

- [ ] `n .` and then opening a project with the dashboard, should also make telescope search this
      dir (e.g., cd into that dir?)
- [ ] consider telescope-file-browser as alternative to mini.files:
      https://github.com/nvim-telescope/telescope-file-browser.nvim
- [ ] jumplist to navigate between files
- [ ] obsidian.nvim + github integration to a private repo
- [ ] flash.nvim for navigation
- [ ] surround.nvim for surrounding text objects
- [ ] quicklist (understand more deeply and use)?
- [ ] vim tips from https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text

</details>

## ghostty

<details>
<summary>Installation</summary>

in your ghostty config file (usually `~/.config/ghostty/config`), have only the following line:

```ini
config-file = "/absolute/path/to/this/file"
```

</details>

<details>
<summary>Core Features</summary>

- setup for macost (option as alt)
- theme catppuccin
- font fira code
- cmd + 0 - reset zoom
- cmd + =/- - zoom in/out

</details>

## zsh

<details>
<summary>Installation</summary>

- in your `~/.zshrc` file, have only the following line:

```zsh
source `~/path/to/dotfiles/zsh/oribi.zsh`
```

- run `zsh setup.zsh

</details>

<details>
<summary>Core Features</summary>

- Fuzzy search on completions (press `Tab` to search)
- Ctrl-r - Search history
- Ctrl-t - Search files
- z - fuzzy jump to directory using zoxide
- zi - Search and jump to directory

- fc - fix command (edit, wq, auto run)

- direnv - load .envrc files automatically in directories

- sesh - tmux session management (outside tmux)

## yazi

<details>
<summary>Installation</summary>

- in your `~/.zshrc` file, add the following line:

```zsh
export PATH="~/path/to/dotfiles/yazi/"
```

</details>

<details>
<summary>Default Configurations</summary>

- showing dotfiles by default
- `g` shortcuts

</details>
</details>

<details>
<summary>Non-functionals</summary>

- Super fast loading (lazy loading what's possible)
- Lightweight prompt theme (with git support)
- Auto-suggestions
- Syntax hightlighting

</details>

## Raycast

<details>

<summary>Installation</summary>

- Install Raycast from https://raycast.com/
- Add the script directory to `~/path/to/dotfiles/raycast/scripts` in Raycast preferences

</details>

## keyd (Linux only)

<details>
<summary>Installation</summary>

1. Install keyd from source:
   ```bash
   git clone https://github.com/rvaiya/keyd
   cd keyd
   make && sudo make install
   sudo systemctl enable keyd
   ```
2. Symlink the config:
   ```bash
   sudo ln -sf ~/.dotfiles/keyd/default.conf /etc/keyd/default.conf
   sudo systemctl restart keyd
   ```
3. Install the focus-or-launch GNOME Shell extension:
   ```bash
   ln -s ~/.dotfiles/keyd/gnome-extension \
     ~/.local/share/gnome-shell/extensions/focus-or-launch@dotfiles
   ```
   Log out/in, then: `gnome-extensions enable focus-or-launch@dotfiles`

4. Set up GNOME hotkeys — see `machine_setup.md` for full `gsettings` commands.

</details>

<details>
<summary>Core Features</summary>

Linux equivalent of [HyperKey](https://hyperkey.app/) on macOS.

- Caps Lock tap → Escape
- Caps Lock hold → Hyper (Meta/Super modifier)

Hyper+key bindings (focus existing window or launch if not running):
- Hyper+T → Ghostty
- Hyper+B → Firefox
- Hyper+A → Switch between windows of the same app

</details>

<details>
<summary>Architecture</summary>

Three layers work together:
1. **keyd** — kernel-level key remapping, Caps hold emits Super modifier
2. **GNOME custom shortcuts** — maps Super+key to run `focus-or-launch` script
3. **GNOME Shell extension** (`focus-or-launch@dotfiles`) — runs inside GNOME Shell to focus Wayland windows via D-Bus

This architecture is needed because:
- keyd runs as root (systemd) and can't launch GUI apps
- External tools (`wmctrl`, `xdotool`) can't see Wayland windows
- GNOME's built-in `FocusApp` D-Bus method is permission-locked
- Only code running inside GNOME Shell can call `activate_with_focus()` on window objects

</details>
