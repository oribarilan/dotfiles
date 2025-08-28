local subtle_color = '#8c98b3' -- default comment and line numbers for tokyo-nights is too faded

return {
  'folke/tokyonight.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup {
      on_colors = function(colors)
        colors.comment = subtle_color
      end,
      on_highlights = function(hl, colors)
        hl.LineNr = { fg = subtle_color }
        hl.LineNrAbove = { fg = subtle_color }
        hl.LineNrBelow = { fg = subtle_color }

        -- Make Visual mode stand out more
        hl.Visual = { bg = '#445b9b' }
      end,
      styles = {
        comments = { italic = false }, -- copilot ghost text will use italic, to diffrentiate it from comments
      },
    }

    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
