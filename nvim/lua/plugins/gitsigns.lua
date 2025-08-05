-- Global git keymaps (independent of gitsigns)
vim.keymap.set('n', '<leader>gc', function()
  require('telescope.builtin').git_bcommits {
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- Get the commit hash
        local commit_hash = selection.value
        local current_file = vim.fn.expand '%:p'

        -- Open vertical split and show the file at that commit
        vim.cmd 'vsplit'
        vim.cmd 'enew'

        -- Show the file content at the specific commit
        local cmd = string.format('git show %s:%s', commit_hash, vim.fn.fnamemodify(current_file, ':~:.'))
        local content = vim.fn.systemlist(cmd)

        if vim.v.shell_error == 0 then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
          -- Set a descriptive buffer name first
          vim.api.nvim_buf_set_name(0, string.format('%s@%s', vim.fn.fnamemodify(current_file, ':t'), commit_hash:sub(1, 8)))
          -- Detect filetype from the original file extension
          local original_filetype = vim.filetype.match { filename = current_file } or vim.bo[vim.fn.bufnr(current_file)].filetype
          if original_filetype and original_filetype ~= '' then
            vim.bo.filetype = original_filetype
          end
          -- Set buffer options for readonly
          vim.bo.readonly = true
          vim.bo.modifiable = false
          vim.bo.buftype = 'nofile'
        else
          vim.notify('Error retrieving file content for commit: ' .. commit_hash, vim.log.levels.ERROR)
          vim.cmd 'close'
        end
      end)
      return true
    end,
  }
end, { desc = 'git buffer [c]ommits' })

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame = true, -- Enable blame by default
      current_line_blame_opts = {
        delay = 300,
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Hunk-specific operations
        map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'hunk [s]tage' })
        map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'hunk [r]eset' })
        -- Note: undo_stage_hunk is deprecated, use stage_hunk on staged signs instead
        map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = 'hunk [p]review' })

        -- Buffer-wide git operations
        map('n', '<leader>gs', gitsigns.stage_buffer, { desc = 'git [s]tage buffer' })
        map('n', '<leader>gr', gitsigns.reset_buffer, { desc = 'git [r]eset buffer' })
        map('n', '<leader>gd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
      end,
    },
  },
}
