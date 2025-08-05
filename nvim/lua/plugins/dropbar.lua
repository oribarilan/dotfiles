-- lua/plugins/dropbar.lua
return {
  {
    'Bekaboo/dropbar.nvim',
    -- Optional dependency for enhanced fuzzy finder support
    dependencies = {
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
      local dropbar_api = require 'dropbar.api'

      -- Key mappings for dropbar functionalities
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
}
