-- Utility commands and keymaps

-- Toggle between relative and absolute line numbers
local function LineNumbersToggle()
  local opts = vim.opt
  if opts.relativenumber:get() then
    -- currently relative → switch to absolute
    opts.relativenumber = false
    opts.number = true
  else
    -- currently absolute or off → switch to relative
    opts.relativenumber = true
    opts.number = true
  end
end

vim.api.nvim_create_user_command('LineNumbersToggle', LineNumbersToggle, { desc = 'Toggle between absolute and relative line numbers' })

-- Keymaps for utility group (<leader>u)
vim.keymap.set('n', '<leader>ul', '<cmd>LineNumbersToggle<cr>', { desc = '[L]ine numbers toggle' })
vim.keymap.set('n', '<leader>ur', '<cmd>e!<cr>', { desc = '[R]eload file from disk' })
vim.keymap.set('n', '<leader>uce', '<cmd>CopilotEnable<cr>', { desc = '[C]opilot [E]enable' })
vim.keymap.set('n', '<leader>ucd', '<cmd>CopilotDisable<cr>', { desc = '[C]opilot [D]isable' })
