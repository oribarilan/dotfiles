-- dotnet.lua
-- .NET Core debugging configuration

local M = {}

function M.setup(dap)
  -- Setup .NET Core debugger for macOS ARM64
  require('netcoredbg-macOS-arm64').setup(dap)
  
  -- .NET debug configurations
  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "launch - auto build & run",
      request = "launch",
      program = function()
        local current_file = vim.fn.expand('%:p')
        local current_dir = vim.fn.fnamemodify(current_file, ':p:h')
        
        -- Find the directory containing .csproj or .sln
        local project_dir = current_dir
        while project_dir ~= '/' do
          if vim.fn.glob(project_dir .. '/*.csproj') ~= '' or vim.fn.glob(project_dir .. '/*.sln') ~= '' then
            break
          end
          project_dir = vim.fn.fnamemodify(project_dir, ':h')
        end
        
        if project_dir == '/' then
          vim.notify('No .csproj or .sln file found in parent directories', vim.log.levels.ERROR)
          return nil
        end
        
        local project_name = vim.fn.fnamemodify(project_dir, ':t')
        
        -- Build the project first
        local build_cmd = 'cd "' .. project_dir .. '" && dotnet build --configuration Debug'
        vim.notify('Building: ' .. build_cmd, vim.log.levels.INFO)
        local build_result = vim.fn.system(build_cmd)
        
        if vim.v.shell_error ~= 0 then
          vim.notify('Build failed:\n' .. build_result, vim.log.levels.ERROR)
          return nil
        end
        
        -- Find any DLL in the bin/Debug directories
        local search_dirs = {
          project_dir .. '/bin/Debug/net8.0/',
          project_dir .. '/bin/Debug/net6.0/',
          project_dir .. '/bin/Debug/net5.0/',
        }
        
        for _, search_dir in ipairs(search_dirs) do
          if vim.fn.isdirectory(search_dir) == 1 then
            local dll_files = vim.fn.glob(search_dir .. '*.dll', false, true)
            for _, dll_path in ipairs(dll_files) do
              -- Skip ref assemblies and other non-executable DLLs
              if not string.match(dll_path, '/ref/') and not string.match(dll_path, '/refint/') then
                return dll_path
              end
            end
          end
        end
        
        -- If auto-detection fails, show error and fallback
        vim.notify('Could not auto-detect DLL. Build may have failed.', vim.log.levels.WARN)
        return nil
      end,
      cwd = vim.fn.getcwd(),
      stopAtEntry = false,
      console = 'integratedTerminal',
      env = {},
      args = {},
    },
    {
      type = "coreclr",
      name = "launch - netcoredbg (manual dll)",
      request = "launch",
      program = function()
        local cwd = vim.fn.getcwd()
        
        -- Use Telescope to pick DLL file
        return coroutine.create(function(dap_run_co)
          require('telescope.builtin').find_files({
            prompt_title = 'Select DLL to debug',
            cwd = cwd,
            find_command = { 'find', '.', '-name', '*.dll', '-type', 'f' },
            previewer = false,  -- Disable preview for DLL selection
            layout_config = {
              height = 0.4,  -- Smaller height since no preview
              width = 0.6,
            },
            attach_mappings = function(prompt_bufnr, map)
              local actions = require('telescope.actions')
              local action_state = require('telescope.actions.state')
              
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                  coroutine.resume(dap_run_co, cwd .. '/' .. selection.value)
                else
                  coroutine.resume(dap_run_co, nil)
                end
              end)
              
              return true
            end,
          })
        end)
      end,
      cwd = vim.fn.getcwd(),
      stopAtEntry = false,
      console = 'integratedTerminal',
      env = {},
      args = {},
    },
    {
      type = "coreclr",
      name = "attach - netcoredbg",
      request = "attach",
      processId = function()
        return require('dap.utils').pick_process()
      end,
      cwd = vim.fn.getcwd(),
    }
  }
end

-- .NET specific keymaps
function M.get_keymaps()
  return {
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
  }
end

-- Dependencies specific to .NET debugging
function M.get_dependencies()
  return {
    {
      "Cliffback/netcoredbg-macOS-arm64.nvim",
      dependencies = { "mfussenegger/nvim-dap" }
    },
  }
end

-- Mason ensure_installed entries
function M.get_mason_ensure_installed()
  return { 'netcoredbg' }
end

return M