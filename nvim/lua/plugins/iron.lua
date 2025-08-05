return {
  'hkupty/iron.nvim',
  config = function()
    require('iron.core').setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          sh = {
            command = { 'zsh' },
          },
          python = {
            command = { 'ipython', '--no-autoindent' },
            format = require('iron.fts.common').bracketed_paste,
            block_dividers = { '# %%', '#%%' },
          },
        },
        repl_open_cmd = 'vertical botright 50 split',
      },
      keymaps = {
        send_motion = '<leader>isc',
        visual_send = '<leader>isc',
        send_file = '<leader>isf',
        send_line = '<leader>isl',
        send_mark = '<leader>ism',
        mark_motion = '<leader>imc',
        mark_visual = '<leader>imc',
        remove_mark = '<leader>imd',
        -- cr = '<leader>s<cr>',
        interrupt = '<leader>ii',
        exit = '<leader>isq',
        clear = '<leader>icl',
        send_code_block = '<space>isb',
      },
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true,
    }
    -- Custom keymap for toggling REPL
    vim.keymap.set('n', '<leader>it', ':IronRepl<CR>', { desc = 'Toggle Iron REPL' })
  end,
}
