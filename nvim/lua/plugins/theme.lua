return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  opts = {
    flavour = 'mocha',
    no_italic = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      telescope = true,
      treesitter = true,
      which_key = true,
    },
    highlight_overrides = {
      mocha = function(C)
        local subtle = C.overlay2
        local bright_white = '#ffffff'
        return {
          Normal = { fg = bright_white, bg = C.base },
          Comment = { fg = subtle },
          Docstring = { fg = subtle },
          LineNr = { fg = subtle },
          LineNrAbove = { fg = subtle },
          LineNrBelow = { fg = subtle },
          Visual = { bg = '#445b9b' },

          -- Global docstring style
          ['@string.documentation'] = { link = 'Docstring' },
          ['@comment.documentation'] = { link = 'Docstring' },
          ['@lsp.mod.documentation'] = { link = 'Docstring' },
          ['@lsp.typemod.comment.documentation'] = { link = 'Docstring' },
          ['@lsp.typemod.string.documentation'] = { link = 'Docstring' },

          -- Flash.nvim – softer, better contrast
          FlashBackdrop = { link = 'Comment' },
          FlashMatch = { bg = C.surface1, fg = bright_white, bold = true },
          FlashCurrent = { bg = C.blue, fg = C.base, bold = true },
          FlashLabel = { bg = C.yellow, fg = C.base, bold = true },

          -- Unused variables/parameters, make them stand out
          ['@lsp.typemod.variable.unused'] = { fg = C.red },
          ['@lsp.typemod.parameter.unused'] = { fg = C.red },
          DiagnosticUnnecessary = { fg = C.red },

          -- Punctuation, make it more subtle
          ['@punctuation.bracket'] = { fg = subtle },
          ['@punctuation.delimiter'] = { fg = subtle },
          ['@punctuation.special'] = { fg = subtle },
          ['@operator'] = { fg = subtle },

          -- Variables and function calls - use bright white
          ['@variable'] = { fg = bright_white },
          ['@variable.builtin'] = { fg = bright_white },
          ['@variable.member'] = { fg = bright_white },
          ['@function.call'] = { fg = bright_white },
          -- Function calls - subtle hint of blue
          ['@function.call'] = { fg = '#a0b8d0' },
          ['@function.method.call'] = { fg = '#a0b8d0' },

          -- Constants (numbers, booleans) use same color as strings
          ['@constant.builtin'] = { link = 'String' },
          ['@number'] = { link = 'String' },
          ['@number.float'] = { link = 'String' },
          ['@boolean'] = { link = 'String' },
        }
      end,
    },
  },
  init = function()
    vim.cmd.colorscheme('catppuccin')
  end,
}
-- return {
--   'folke/tokyonight.nvim',
--   lazy = false,
--   priority = 1000,
--   opts = {
--     style = 'night',
--     cache = false, -- avoid stale results while iterating
--     on_highlights = function(hl, c)
--     -- copilot ghost text will use italic (+ a diff color), to diffrentiate it from comments
--       local subtle = '#8c98b3'  -- subtle color for comments and line numbers
--       hl.Comment      = { fg = subtle, italic = false }
--       hl.Docstring    = { fg = subtle, italic = false }
--       hl.LineNr       = { fg = subtle }
--       hl.LineNrAbove  = { fg = subtle }
--       hl.LineNrBelow  = { fg = subtle }
--       hl.Visual       = { bg = '#445b9b' }
--
--       -- Global docstring style
--       hl.Docstring    = { fg = subtle, italic = false }
--       hl['@string.documentation']  = { link = 'Docstring' }
--       hl['@comment.documentation'] = { link = 'Docstring' }
--       hl['@lsp.mod.documentation'] = { link = 'Docstring' }
--       hl['@lsp.typemod.comment.documentation'] = { link = 'Docstring' }
--       hl['@lsp.typemod.string.documentation']  = { link = 'Docstring' }
--
--       -- Flash.nvim – softer, better contrast
--       hl.FlashBackdrop = { link = 'Comment' }                          -- dim background
--       hl.FlashMatch    = { bg = c.bg_highlight, fg = c.fg, bold = true }
--       hl.FlashCurrent  = { bg = c.blue,         fg = c.fg, bold = true }
--       hl.FlashLabel    = { bg = c.yellow,       fg = c.bg, bold = true }
--
--       -- Unused variables/parameters, make them stand out
--       hl['@lsp.typemod.variable.unused'] = { fg = c.red }
--       hl['@lsp.typemod.parameter.unused'] = { fg = c.red }
--       hl.DiagnosticUnnecessary = { fg = c.red }
--
--       -- Punctuation, make it more subtle
--       hl['@punctuation.bracket'] = { fg = subtle }
--       hl['@punctuation.delimiter'] = { fg = subtle }
--       hl['@punctuation.special'] = { fg = subtle }
--       hl['@operator'] = { fg = subtle }
--
--       -- Variables and function calls - make more subtle
--       hl['@variable'] = { fg = c.fg }
--       hl['@variable.builtin'] = { fg = c.fg }
--       hl['@variable.member'] = { fg = c.fg }
--       hl['@function.call'] = { fg = c.fg }
--       hl['@function.method.call'] = { fg = c.fg }
--
--       -- Constants (numbers, booleans) use same color as strings
--       hl['@number'] = { link = 'String' }
--       hl['@number.float'] = { link = 'String' }
--       hl['@boolean'] = { link = 'String' }
--
--     end,
--   },
--   init = function()
--     vim.cmd.colorscheme('tokyonight-night')
--   end,
-- }
