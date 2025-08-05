return {
  'echasnovski/mini.files',
  version = '*', -- latest stable
  config = function()
    require('mini.files').setup {
      options = {
        use_as_default_explorer = false,
      },
    }

    -- Optional: Key mappings to open mini.files
    vim.keymap.set('n', '<leader>E', function()
      require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
    end, { desc = "Open mini.files (current file's directory)" })

    vim.keymap.set('n', '<leader>e', function()
      require('mini.files').open(vim.uv.cwd(), true)
    end, { desc = 'Open mini.files (current working directory)' })
  end,
}
