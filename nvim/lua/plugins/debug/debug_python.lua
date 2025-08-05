-- python.lua
-- Python debugging configuration

local M = {}

function M.setup(dap)
  -- Setup Python debugger
  require('dap-python').setup()
end

-- Python specific keymaps (if any)
function M.get_keymaps()
  return {
    -- Add Python-specific keymaps here if needed
    -- For now, using the general debug keymaps
  }
end

-- Dependencies specific to Python debugging
function M.get_dependencies()
  return {
    'mfussenegger/nvim-dap-python',
  }
end

-- Mason ensure_installed entries
function M.get_mason_ensure_installed()
  return { 'python' }
end

return M