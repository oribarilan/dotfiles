return {
  'esmuellert/codediff.nvim',
  cmd = 'CodeDiff',
  keys = {
    {
      '<leader>hr',
      function()
        vim.cmd 'checktime'
        vim.cmd 'CodeDiff'
      end,
      desc = '[H]unk [R]eview (toggle)',
    },
  },
  opts = {
    keymaps = {
      view = {
        quit = '<leader>hr',
        discard_hunk = '<leader>hd',
      },
    },
  },
}
