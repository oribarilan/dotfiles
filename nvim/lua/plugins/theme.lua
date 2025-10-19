return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    style = 'night',
    cache = false, -- avoid stale results while iterating
    on_highlights = function(hl, c)
    -- copilot ghost text will use italic (+ a diff color), to diffrentiate it from comments
      local subtle = '#8c98b3'  -- subtle color for comments and line numbers
      hl.Comment      = { fg = subtle, italic = false }
      hl.Docstring    = { fg = subtle, italic = false }
      hl.LineNr       = { fg = subtle }
      hl.LineNrAbove  = { fg = subtle }
      hl.LineNrBelow  = { fg = subtle }
      hl.Visual       = { bg = '#445b9b' }

      -- Global docstring style
      hl.Docstring    = { fg = subtle, italic = false }
      hl['@string.documentation']  = { link = 'Docstring' }
      hl['@comment.documentation'] = { link = 'Docstring' }
      hl['@lsp.mod.documentation'] = { link = 'Docstring' }
      hl['@lsp.typemod.comment.documentation'] = { link = 'Docstring' }
      hl['@lsp.typemod.string.documentation']  = { link = 'Docstring' }

      -- Flash.nvim – softer, better contrast
      hl.FlashBackdrop = { link = 'Comment' }                          -- dim background
      hl.FlashMatch    = { bg = c.bg_highlight, fg = c.fg, bold = true }
      hl.FlashCurrent  = { bg = c.blue,         fg = c.fg, bold = true }
      hl.FlashLabel    = { bg = c.yellow,       fg = c.bg, bold = true }

      -- Unused variables/parameters, make them stand out
      hl['@lsp.typemod.variable.unused'] = { fg = c.red }
      hl['@lsp.typemod.parameter.unused'] = { fg = c.red }
      hl.DiagnosticUnnecessary = { fg = c.red }

      -- Punctuation, make it more subtle
      hl['@punctuation.bracket'] = { fg = subtle }
      hl['@punctuation.delimiter'] = { fg = subtle }
      hl['@punctuation.special'] = { fg = subtle }
      hl['@operator'] = { fg = subtle }

      -- Variables and function calls - make more subtle
      hl['@variable'] = { fg = c.fg }
      hl['@variable.builtin'] = { fg = c.fg }
      hl['@variable.member'] = { fg = c.fg }
      hl['@function.call'] = { fg = c.fg }
      hl['@function.method.call'] = { fg = c.fg }

      -- Constants (numbers, booleans) use same color as strings
      hl['@number'] = { link = 'String' }
      hl['@number.float'] = { link = 'String' }
      hl['@boolean'] = { link = 'String' }

    end,
  },
  init = function()
    vim.cmd.colorscheme('tokyonight-night')
  end,
}
