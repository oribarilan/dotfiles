return {

  -- dev
  dir = '~/repos/personal/devcontainers.nvim',
  dev = true, -- Enables development mode
  -- event = 'LspAttach',
  config = function()
    require('devcontainers').setup {
      dev_path = '~/repos/personal/devcontainers.nvim',
      debug = true,
    }
  end,

  -- prod
  -- 'oribarilan/devcontainers.nvim',
  -- -- tag = '1.0.0', -- or: branch = 'release/1.x' for latest non-breaking updates
  -- -- event = 'LspAttach',
  -- config = function()
  --   require("devcontainers").setup{
  --     enter_mode = 'nested',
  --   }
  -- end,
}
