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
      desc = '[H]unk [R]eview',
    },
  },
  opts = {
    keymaps = {
      view = {
        discard_hunk = '<leader>hd',
      },
    },
  },
}
