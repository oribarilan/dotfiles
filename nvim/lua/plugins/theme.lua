return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    style = 'night',
    cache = false, -- avoid stale results while iterating
    -- styles = { comments = { italic = true } },
    on_highlights = function(hl, c)
      local subtle = '#8c98b3'  -- subtle color for comments and line numbers
      hl.Comment      = { fg = subtle, italic = true }
      hl.LineNr       = { fg = subtle }
      hl.LineNrAbove  = { fg = subtle }
      hl.LineNrBelow  = { fg = subtle }
      hl.Visual       = { bg = '#445b9b' }
    end,
  },
  init = function()
    vim.cmd.colorscheme('tokyonight')
  end,
}
