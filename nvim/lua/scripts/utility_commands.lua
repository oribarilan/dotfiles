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

-- Close current buffer and switch to another or create empty buffer
local function close_buffer()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo { buflisted = 1 }
  
  -- If this is the only buffer, create a new empty one first
  if #buffers <= 1 then
    vim.cmd 'enew'
  else
    -- Switch to alternate buffer or next buffer
    vim.cmd 'bp'
  end
  
  -- Delete the original buffer
  vim.api.nvim_buf_delete(current_buf, { force = false })
end

-- Keymaps for utility group (<leader>u)
vim.keymap.set('n', '<leader>ul', '<cmd>LineNumbersToggle<cr>', { desc = '[L]ine numbers toggle' })
vim.keymap.set('n', '<leader>ur', '<cmd>e!<cr>', { desc = '[R]eload file from disk' })
vim.keymap.set('n', '<leader>ub', close_buffer, { desc = '[B]uffer close' })
vim.keymap.set('n', '<leader>uce', '<cmd>CopilotEnable<cr>', { desc = '[C]opilot [E]enable' })
vim.keymap.set('n', '<leader>ucd', '<cmd>CopilotDisable<cr>', { desc = '[C]opilot [D]isable' })
