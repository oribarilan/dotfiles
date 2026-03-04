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
  config = function(_, opts)
    require('codediff').setup(opts)

    -- Re-equalize codediff splits on Neovim pane resize (e.g. tmux zoom)
    local layout = require 'codediff.ui.layout'
    local lifecycle = require 'codediff.ui.lifecycle'
    vim.api.nvim_create_autocmd('VimResized', {
      group = vim.api.nvim_create_augroup('codediff_auto_resize', { clear = true }),
      callback = function()
        local tabpage = vim.api.nvim_get_current_tabpage()
        if lifecycle.get_session(tabpage) then
          layout.arrange(tabpage)
        end
      end,
    })
  end,
}
