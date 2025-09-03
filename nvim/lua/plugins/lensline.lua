return {

  -- dev
  dir = '~/repos/personal/lensline.nvim',
  dev = true, -- Enables development mode
  event = 'LspAttach',
  config = function()
    require('lensline').setup {
      style = {
        placement = 'inline',
        prefix = '',
      },
      debug_mode = true,
    }
  end,

  -- prod
  -- 'oribarilan/lensline.nvim',
  -- tag = '1.0.0', -- or: branch = 'release/1.x' for latest non-breaking updates
  -- event = 'LspAttach',
  -- config = function()
  --   require("lensline").setup()
  -- end,
}
