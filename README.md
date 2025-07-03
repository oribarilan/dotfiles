# dotfiles

## Key Features

### tmux

- <C-h/j/k/l> pane navigation in tmux & nvim
- <C-a> leader for tmux
- <C-a>F for tmux fzf (session management)
- <C-a>- split horizontally
- <C-a>\ split vertically
- <C-a>x kill pane
- <C-a>z zoom pane (default)
- <C-a>h/j/k/l resize current pane (repeatable)
- <C-a>Escpae - enter copy mode, q to exit, v to start selection, y to copy (vi mode enabled)

### nvim

- <space> leader for nvim

## todo

### general

- [ ] move zsh here
- [ ] move nvim here
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
