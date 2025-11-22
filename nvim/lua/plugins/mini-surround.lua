-- Example plugin config for mini.surround
return {
  'echasnovski/mini.surround',
  version = '*',
  config = function()
    local ms = require('mini.surround')

    ms.setup({
      mappings = {
        add            = 'sa',  -- add surrounding (visual/motion)
        delete         = 'sd',  -- delete surrounding
        replace        = 'sr',  -- replace surrounding
        find           = 'sf',  -- find right surrounding
        find_left      = 'sF',  -- find left surrounding
        highlight      = 'sh',  -- highlight surrounding
      },
      custom_surroundings = {
        -- Brackets: flipped spacing
        ['('] = { output = { left  = '(',   right = ')'   } },
        [')'] = { output = { left  = '( ',  right = ' )'  } },
        ['['] = { output = { left  = '[',   right = ']'   } },
        [']'] = { output = { left  = '[ ',  right = ' ]'  } },
        ['{'] = { output = { left  = '{',   right = '}'   } },
        ['}'] = { output = { left  = '{ ',  right = ' }'  } },

        -- Quotes: flipped spacing for visual style
        ['"']  = { output = { left = '"',   right = '"'   } },
        ["'"]  = { output = { left = "'",   right = "'"   } },
        ['`']  = { output = { left = '`',   right = '`'   } },
        ['”']  = { output = { left = '“ ',  right = ' ”'  } },

        -- Interactive custom input; `'?'` triggers the prompt
        ['?'] = {
          output = function()
            local left  = ms.user_input('Left part: ')
            if not left then  return nil  end
            local right = ms.user_input('Right part: ')
            if not right then return nil  end
            return { left = left, right = right }
          end,
        },
      },
    })
  end,
}
