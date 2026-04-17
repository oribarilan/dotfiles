return {

  -- dev: per-highlight feature testing
  -- dir = '~/repos/personal/lensline.nvim',
  -- dev = true,
  -- event = 'LspAttach',
  -- config = function()
  --   require('lensline').setup {
  --     profiles = {
  --       {
  --         name = 'per-highlight-demo',
  --         providers = {
  --           { name = 'usages', enabled = true, highlight = 'Function' },
  --           { name = 'last_author', enabled = true, highlight = 'String' },
  --         },
  --         style = {
  --           placement = 'inline',
  --           prefix = '',
  --           highlight = 'Comment',
  --         },
  --       },
  --     },
  --     debug_mode = true,
  --     limits = {
  --       exclude = {},
  --     },
  --   }
  -- end,

  -- prod
  'oribarilan/lensline.nvim',
  branch = 'release/2.x',
  event = 'LspAttach',
  config = function()
    require('lensline').setup {
      profiles = {
        {
          name = 'per-highlight-demo',
          providers = {
            { name = 'usages', enabled = true, highlight = 'Function' },
            { name = 'last_author', enabled = true, highlight = 'String' },
          },
          style = {
            placement = 'inline',
            prefix = '',
            highlight = 'Comment',
          },
        },
      },
      debug_mode = false,
    }
  end,
}
