return {
  'github/copilot.vim',
  config = function()
    vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
      fg = '#d4b48c',
      italic = true,
      nocombine = true,
    })

    vim.g.copilot_no_tab_map = true
    local map = function(lhs, rhs)
      vim.keymap.set('i', lhs, rhs, { expr = true, replace_keycodes = false, silent = true })
    end

    map('<M-y>', 'copilot#Accept("<CR>")')  -- accept all
    map('<M-j>', 'copilot#Next()')          -- next suggestion
    map('<M-k>', 'copilot#Previous()')      -- previous suggestion
    map('<M-n>', 'copilot#Dismiss()')       -- dismiss
    map('<M-l>', 'copilot#AcceptWord()')    -- accept word
  end,
}
