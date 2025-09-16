return {

  -- dev multi
  dir = '~/repos/personal/lensline.nvim',
  dev = true, -- Enables development mode
  event = 'LspAttach',
  config = function()
    require('lensline').setup {
      profiles = {
        {
          name = 'minimal',
          providers = { { name = 'references' } },
          style = {
            placement = 'inline',
            prefix = '',
          },
        },
        {
          name = 'detailed',
          providers = { { name = 'last_author' } , { name = 'references' } },
          style = {
            placement = 'above',
          },
        },
      },
      debug_mode = true,
    }
  end,

  -- prod
  -- 'oribarilan/lensline.nvim',
  -- branch = 'release/1.x',
  -- event = 'LspAttach',
  -- config = function()
  --   require('lensline').setup {
  --     style = {
  --       placement = 'inline',
  --       prefix = '',
  --     },
  --     debug_mode = true,
  --   }
  -- end,
}
