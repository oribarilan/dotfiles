return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    local function open_project(dir, mode)
      vim.fn.chdir(dir)
      -- Attempt to source direnv via JSON export
      if vim.fn.filereadable(dir .. '/.envrc') == 1 then
        local handle = io.popen('cd ' .. dir .. ' && direnv export json')
        if handle then
          local output = handle:read '*a'
          handle:close()
          local ok, data = pcall(vim.fn.json_decode, output)
          if ok and type(data) == 'table' then
            for k, v in pairs(data) do
              vim.env[k] = v
            end
            vim.notify('direnv env applied for: ' .. dir)
          else
            vim.notify('direnv failed to load env for ' .. dir, vim.log.levels.WARN)
          end
        end
      end
      -- open in desired explorer
      if mode == 'mini' then
        require('mini.files').open(dir)
      else
        require('telescope.builtin').find_files { cwd = dir }
      end
    end
    require('dashboard').setup {
      theme = 'hyper',
      config = {
        -- week_header = {
        --   enable = true,
        -- },
        header = {
          '────────────────────────────────',
          '───────────────██████████───────',
          '──────────────████████████──────',
          '──────────────██────────██──────',
          '──────────────██▄▄▄▄▄▄▄▄▄█──────',
          '──────────────██▀███─███▀█──────',
          '█─────────────▀█────────█▀──────',
          '██──────────────────█───────────',
          '─█──────────────██──────────────',
          '█▄────────────████─██──████─────',
          '─▄███████████████──██──██████ ──',
          '────█████████████──██──█████████',
          '─────────────████──██─█████──███',
          '──────────────███──██─█████──███',
          '──────────────███─────█████████─',
          '──────────────██─────████████▀──',
          '────────────────██████████──────',
          '────────────────██████████──────',
          '─────────────────████████───────',
          '──────────────────██████████▄▄──',
          '────────────────────█████████▀──',
          '─────────────────────████──███──',
          '────────────────────▄████▄──██──',
          '────────────────────██████───▀──',
          '────────────────────▀▄▄▄▄▀──────',
        },
        shortcut = {
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Files',
            group = 'Label',
            action = 'Telescope find_files',
            key = 'f',
          },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Nvim config',
            group = 'Label',
            action = function()
              open_project(vim.fn.expand '~/.config/nvim', 'tele')
            end,
            key = 'c',
          },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'zshrc',
            group = 'Label',
            action = function()
              open_project(vim.fn.expand 'edit ~/.config/zsh/', 'tele')
            end,
            key = 'z',
          },
          {
            icon = '󱀺',
            icon_hl = '@variable',
            desc = 'dotfiles',
            group = 'Label',
            action = function()
              open_project(vim.fn.expand '~/.config/dotfiles/', 'tele')
            end,

            key = 'd',
          },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Port.Inference',
            group = 'Label',
            action = function()
              open_project(vim.fn.expand '~/repos/mde/Port.Inference', 'tele')
            end,
            key = 'i',
          },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Port.Runner',
            group = 'Label',
            action = function()
              open_project(vim.fn.expand '~/repos/mde/Port.Runner', 'tele')
            end,
            key = 'r',
          },
        },
        packages = { enable = true },
        project = { enable = true, limit = 6, icon = '󰉋', label = ' Projects', action = 'Telescope find_files cwd=' },
        mru = { enable = true, limit = 10, icon = '󰈔', label = ' Recent Files', cwd_only = false },
        footer = {
          '',
          '',
          '"Everybody has a plan, until they get hit in the face." - Mike Tyson 🥊',
        },
      },
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
