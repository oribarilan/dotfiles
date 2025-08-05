# dotfiles

## tmux

- <C-h/j/k/l> pane navigation in tmux & nvim
- <C-a> leader for tmux
- <C-a>F for tmux fzf (session management)
- <C-a>- split horizontally
- <C-a>\ split vertically
- <C-a>x kill pane
- <C-a>z zoom pane (default)
- <C-a>h/j/k/l resize current pane (repeatable)
- <C-a>Escpae - enter copy mode, q to exit, v to start selection, y to copy (vi mode enabled)

## nvim

### Installation

- create a symlink between default nvim config (e.g., `~/.config/nvim`) and this repo's nvim config:
```bash
ln -s ~/path/to/dotfiles/nvim ~/.config/nvim
```

Note: we are using symlink (instead of bootstrapping like other tools here) for nvim specifically because of tools like lazy.nvim that will create a lazy-lock.json file in the nvim config directory.

### Core Features

- <space> leader for nvim
- autoread

#### Language Support (LSPs, formatters, linters)
Using the "old" nvim-lspconfig lsp setup

- python - pyright, ruff
- dotnet - roslyn

- lua - lua_ls, stylua
- json - jsonls, jsonlint
- yaml - yamlls, yamllint
- markdown - markdownlint



## ghostty

### Installation
in your ghostty config file (usually `~/.config/ghostty/config`), have only the following line:
```ini
config-file = "/absolute/path/to/this/file"
```

### Core Features
- setup for macost (option as alt)
- theme catppuccin
- font fira code
- cmd + 0 - reset zoom
- cmd + =/- - zoom in/out

## zsh

### Installation
- in your `~/.zshrc` file, have only the following line:

```zsh
source `~/path/to/dotfiles/zsh/oribi.zsh`
```

- run `zsh setup.zsh

### Core Features

- Fuzzy search on completions (press `Tab` to search)
- Ctrl-r - Search history
- Ctrl-t - Search files
- z - fuzzy jump to directory using zoxide
- zi - Search and jump to directory

- fc - fix command (edit, wq, auto run)

- direnv - load .envrc files automatically in directories

## Non-functionals

- Super fast loading (lazy loading what's possible)
- Lightweight prompt theme (with git support)
- Auto-suggestions
- Syntax hightlighting

### general

- [x] move zsh here
- [x] move ghostty here
- [x] move nvim here
- [ ] move docs from individual repos here

### tmux

- [x] easier keymap for creating and deleting splits
- [ ] session management and navigation
- [ ] omerxx/tmux-sessionx

### vim

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



