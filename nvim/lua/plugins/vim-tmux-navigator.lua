return {
  -- navigate between tmux and vim splits
  -- make sure tmux side is also set-up
  'christoomey/vim-tmux-navigator',
  vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { silent = true, desc = 'Navigate Pane Left' }),
  vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { silent = true, desc = 'Navigate Pane Down' }),
  vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { silent = true, desc = 'Navigate Pane Up' }),
  vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = 'Tmux Navigate Right' }),
}
