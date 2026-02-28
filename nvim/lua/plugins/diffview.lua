return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>gv',
      function()
        vim.cmd 'checktime'
        vim.cmd 'DiffviewOpen'
      end,
      desc = 'git diff[v]iew',
    },
    { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'git [f]ile history' },
    { '<leader>gF', '<cmd>DiffviewFileHistory<cr>', desc = 'git [F]ile history (all)' },
  },
}
