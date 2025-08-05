return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local function recording_macro()
      local rec = vim.fn.reg_recording()
      return rec ~= '' and 'Recording @' .. rec or ''
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
      },
    }

    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function()
        require('lualine').refresh()
      end,
    })
  end,
}
