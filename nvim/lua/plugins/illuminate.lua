return {
  'RRethy/vim-illuminate',
  config = function()
    require('illuminate').configure {
      -- providers: provider used to get references in the buffer, ordered by priority
      providers = {
        'lsp',
        'treesitter',
        'regex',
      },

      delay = 100,
      under_cursor = true,

      -- large_file_cutoff: number of lines at which to use large_file_config
      -- The `under_cursor` option is disabled when this cutoff is hit
      large_file_cutoff = 500,
      -- case_insensitive_regex: sets regex case sensitivity
      case_insensitive_regex = true,
    }

    -- keymaps to jump between matches
    vim.keymap.set('n', '<A-n>', require('illuminate').goto_next_reference, { desc = 'Next Reference' })
    vim.keymap.set('n', '<A-p>', require('illuminate').goto_prev_reference, { desc = 'Previous Reference' })
  end,
}
