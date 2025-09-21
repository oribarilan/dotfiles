# dotfiles

## tmux

<details>
<summary>Installation</summary>

1. Install tmux
2. Install tmux package manager (`tpm`) from https://github.com/tmux-plugins/tpm

</details>

<details>
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

</details>
</details>

<details>
<summary>Non-functionals</summary>

- Super fast loading (lazy loading what's possible)
- Lightweight prompt theme (with git support)
- Auto-suggestions
- Syntax hightlighting

</details>
