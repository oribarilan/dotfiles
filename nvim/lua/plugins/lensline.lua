return {
  dir = '~/repos/personal/lensline.nvim',
  dev = true, -- Enables development mode
  event = 'BufReadPre',
  config = function()
    require('lensline').setup {
      providers = { -- Array format: order determines display sequence
        {
          name = 'ref_count',
          enabled = true,
        },
        {
          name = 'last_author',
          enabled = true,
        },
        -- {
        --   name = 'complexity',
        --   enabled = true,
        -- },
      },
      debug_mode = true,
    }
  end,
}
