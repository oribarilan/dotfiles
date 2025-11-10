return {

  -- dev multi
  -- dir = '~/repos/personal/lensline.nvim',
  -- dev = true, -- Enables development mode
  -- event = 'LspAttach',
  -- config = function()
  --   require('lensline').setup {
  --     profiles = {
  --       {
  --         name = 'minimal',
  --         style = {
  --           placement = 'inline',
  --           prefix = '',
  --         },
  --       },
  --     },
  --     debug_mode = true,
  --     limits = {
  --       exclude = {}, -- use gitignore instead
  --     }
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
      debug_mode = false,
    }
  end,
}
