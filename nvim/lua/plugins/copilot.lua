return {
  'github/copilot.vim',
  config = function()
    -- Set Copilot ghost text highlight
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

    -- :CopilotDisable command
    -- Disables GitHub Copilot inline suggestions and Sidekick NES.
    vim.api.nvim_create_user_command('CopilotDisable', function()
      pcall(vim.cmd, 'Copilot disable')
      pcall(vim.cmd, 'Sidekick nes disable')
      vim.notify('AI Disabled', vim.log.levels.INFO)
    end, { desc = 'Disable Copilot suggestions and Sidekick NES' })

    -- :CopilotEnable command
    -- Re-enables GitHub Copilot inline suggestions and Sidekick NES.
    vim.api.nvim_create_user_command('CopilotEnable', function()
      pcall(vim.cmd, 'Copilot enable')
      pcall(vim.cmd, 'Sidekick nes enable')
      vim.notify('AI Enabled', vim.log.levels.INFO)
    end, { desc = 'Enable Copilot suggestions and Sidekick NES' })
  end,
}
