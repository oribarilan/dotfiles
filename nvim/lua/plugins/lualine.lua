return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local function recording_macro()
      local rec = vim.fn.reg_recording()
      return rec ~= '' and 'Recording @' .. rec or ''
    end

    local function unsaved_changes()
      local modified_count = 0
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
          modified_count = modified_count + 1
        end
      end
      return modified_count > 0 and '[' .. modified_count .. '+]' or ''
    end

    require('lualine').setup {
      options = {
        theme = 'tokyonight-night',
      },
      sections = {
        lualine_c = {
          'filename',
          recording_macro,
        },
        lualine_x = {
          unsaved_changes,
          'encoding',
          'fileformat',
          'filetype',
        },
      },
    }

    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function()
        require('lualine').refresh()
      end,
    })

    vim.api.nvim_create_autocmd({ 'BufModifiedSet' }, {
      callback = function()
        require('lualine').refresh()
      end,
    })
  end,
}
