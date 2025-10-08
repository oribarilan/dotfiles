return {

  -- dev multi
  -- dir = '~/repos/personal/lensline.nvim',
  -- dev = true, -- Enables development mode
  -- event = 'LspAttach',
  -- config = function()
  --   require('lensline').setup {
  --     profiles = {
  --       {
  --         name = 'default',
  --         providers = {
  --           {
  --             name = 'usages',
  --             include = { 'refs', 'defs', 'impls' },
  --             breakdown = true,
  --           },
  --           { name = 'last_author' },
  --         },
  --         style = {
  --           placement = 'inline',
  --           prefix = '',
  --         },
  --       },
  --       {
  --         name = 'short',
  --         providers = {
  --           {
  --             name = 'usages',
  --             include = { 'refs', 'defs', 'impls' },
  --             breakdown = false,
  --           },
  --           { name = 'last_author' },
  --         },
  --       },
  --     },
  --     debug_mode = true,
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
          name = 'minimal',
          style = {
            placement = 'inline',
            prefix = '',
          },
        },
      },
      debug_mode = true,
    }
  end,
}
