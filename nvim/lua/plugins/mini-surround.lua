-- Add surrounding with sa (in visual mode or on motion).
-- Delete surrounding with sd.
-- Replace surrounding with sr.
-- Find surrounding with sf or sF (move cursor right or left).
-- Highlight surrounding with sh.
return {
  'echasnovski/mini.surround',
  version = '*',
  opts = {
    custom_surroundings = {
      -- Brackets: flipped spacing
      ['('] = { output = { left = '(', right = ')' } },
      [')'] = { output = { left = '( ', right = ' )' } },
      ['['] = { output = { left = '[', right = ']' } },
      [']'] = { output = { left = '[ ', right = ' ]' } },
      ['{'] = { output = { left = '{', right = '}' } },
      ['}'] = { output = { left = '{ ', right = ' }' } },

      -- Quotes: flipped spacing
      ['"'] = { output = { left = '"', right = '"' } },
      ["'"] = { output = { left = "'", right = "'" } },
      ['`'] = { output = { left = '`', right = '`' } },
      ['”'] = { output = { left = '“ ', right = ' ”' } },
    },
  },
}
