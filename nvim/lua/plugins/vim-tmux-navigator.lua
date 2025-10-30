return {
  -- navigate between tmux and vim splits
  -- make sure tmux side is also set-up
  'christoomey/vim-tmux-navigator',
  init = function()
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
  config = function()
    vim.keymap.set({ 'n', 't' }, '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { silent = true, desc = 'Navigate Pane Left' })
    vim.keymap.set({ 'n', 't' }, '<C-j>', '<cmd>TmuxNavigateDown<cr>', { silent = true, desc = 'Navigate Pane Down' })
    vim.keymap.set({ 'n', 't' }, '<C-k>', '<cmd>TmuxNavigateUp<cr>', { silent = true, desc = 'Navigate Pane Up' })
    vim.keymap.set({ 'n', 't' }, '<C-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = 'Tmux Navigate Right' })

    -- Special handling for sidekick terminal windows
    -- Sidekick's terminal may need buffer-local mappings to work with tmux navigation
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'sidekick_terminal',
      callback = function()
        vim.keymap.set('t', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { buffer = true, silent = true, desc = 'Navigate Pane Left' })
        vim.keymap.set('t', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { buffer = true, silent = true, desc = 'Navigate Pane Down' })
        vim.keymap.set('t', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { buffer = true, silent = true, desc = 'Navigate Pane Up' })
        vim.keymap.set('t', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { buffer = true, silent = true, desc = 'Tmux Navigate Right' })
      end,
    })
  end,
}
