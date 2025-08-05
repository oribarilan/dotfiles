return {
  'echasnovski/mini.ai',
  version = '*',
  event = 'VeryLazy',
  opts = {},
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function(_, opts)
    local MiniAi = require 'mini.ai'

    MiniAi.setup {
      -- No need to copy this inside `setup()`. Will be used automatically.
      -- Table with textobject id as fields, textobject specification as values.
      -- Also use this to disable builtin textobjects. See |MiniAi.config|.
      custom_textobjects = {
        f = MiniAi.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = MiniAi.gen_spec.treesitter { a = '@comment.outer', i = '@comment.inner' },
        -- default ones:
        -- q for quotes
        -- b for brackets
        -- t for tags
        -- a for argument
      },

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Main textobject prefixes
        around = 'a',
        inside = 'i',

        -- Next/last variants
        -- around_next = 'an',
        -- inside_next = 'in',
        -- around_last = 'al',
        -- inside_last = 'il',
        -- Move cursor to corresponding edge of `a` textobject
        goto_left = 'g[',
        goto_right = 'g]',
      },

      -- Number of lines within which textobject is searched
      n_lines = 50,

      -- How to search for object (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
      search_method = 'cover_or_next',

      -- Whether to disable showing non-error feedback
      -- This also affects (purely informational) helper messages shown after
      -- idle time if user input is required.
      silent = false,
    }
  end,
}
