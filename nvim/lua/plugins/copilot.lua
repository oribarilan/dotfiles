return {
  'github/copilot.vim',
  config = function()
    vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#999999', italic = true })
  end,
}
