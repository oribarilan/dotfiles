-- debug.lua
-- Language-agnostic DAP configuration that loads language-specific setups

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',
    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    -- Language-specific dependencies (static list)
    'mfussenegger/nvim-dap-python',
    {
      "Cliffback/netcoredbg-macOS-arm64.nvim",
      dependencies = { "mfussenegger/nvim-dap" }
    },
  },
  
  keys = {
    -- Core debugging keymaps
    {
      '<M-d>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<M-l>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<M-j>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<M-h>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<M-b>',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<M-B>',
      function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end,
      desc = 'Debug: Set Conditional Breakpoint',
    },
    {
      '<M-o>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<M-r>',
      function()
        local cwd = vim.fn.getcwd()
        vim.notify('Building .NET project...', vim.log.levels.INFO)
        vim.fn.jobstart({'dotnet', 'build', '--configuration', 'Debug'}, {
          cwd = cwd,
          on_exit = function(_, exit_code)
            if exit_code == 0 then
              vim.notify('Build successful!', vim.log.levels.INFO)
            else
              vim.notify('Build failed!', vim.log.levels.ERROR)
            end
          end,
          on_stdout = function(_, data)
            if data and #data > 0 then
              for _, line in ipairs(data) do
                if line ~= '' then
                  print(line)
                end
              end
            end
          end,
        })
      end,
      desc = 'Debug: Build .NET project',
    },
  },
  
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Collect Mason ensure_installed from all language modules
    local ensure_installed = { 'python', 'netcoredbg' }
    local debug_modules = {}
    local debug_path = vim.fn.stdpath('config') .. '/lua/plugins/debug'
    
    if vim.fn.isdirectory(debug_path) == 1 then
      local files = vim.fn.glob(debug_path .. '/debug_*.lua', false, true)
      for _, file in ipairs(files) do
        local module_name = vim.fn.fnamemodify(file, ':t:r')
        local ok, module = pcall(require, 'plugins.debug.' .. module_name)
        if ok then
          debug_modules[module_name] = module
        end
      end
    end

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,
      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},
      -- Dynamically collected from language modules
      ensure_installed = ensure_installed,
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Configure breakpoint icons and highlights
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#888888' })
    
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or (type == 'BreakpointRejected') and 'DapBreakpointRejected' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    -- Additional DAP configuration to ensure proper breakpoint handling
    dap.defaults.fallback.external_terminal = {
      command = '/usr/bin/open',
      args = {'-a', 'Terminal'},
    }
    
    -- Ensure breakpoints are properly set and validated
    dap.listeners.after.event_breakpoint['dap_breakpoint'] = function(session, body)
      vim.notify('Breakpoint validated: ' .. vim.inspect(body), vim.log.levels.DEBUG)
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Setup language-specific debug configurations
    for module_name, module in pairs(debug_modules) do
      if type(module.setup) == 'function' then
        vim.notify('Loading debug config for: ' .. module_name, vim.log.levels.INFO)
        module.setup(dap)
      end
    end
  end,
}
