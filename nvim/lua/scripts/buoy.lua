-- Floating terminal based on tjdevries
-- https://github.com/tjdevries/advent-of-nvim/blob/master/nvim/plugin/floaterminal.lua

--[[ State Configuration ]]
local state = {
  floating = {
    win = -1,
    current_buf = 1,
    bufs = {
      { buf = -1 }, -- Terminal buffer 1
      { buf = -1 }, -- Terminal buffer 2
      { buf = -1 }, -- Terminal buffer 3
      { buf = -1, command = 'lazygit' }, -- Lazygit buffer
    },
  },
}

--[[ Helper Functions ]]
local function get_window_title()
  local current_buf = state.floating.bufs[state.floating.current_buf]
  local command_str = current_buf.command and (' ' .. current_buf.command) or ''
  local mode = vim.api.nvim_get_mode().mode
  local mode_str = mode:match '^t' and ' [TERM]' or ' [NORM]'
  return string.format(' Buoy [%d/%d]%s%s ', state.floating.current_buf, #state.floating.bufs, mode_str, command_str)
end

local function update_window_title()
  if vim.api.nvim_win_is_valid(state.floating.win) then
    vim.api.nvim_win_set_config(state.floating.win, {
      title = get_window_title(),
      title_pos = 'left',
      zindex = 600,
      focusable = false,
    })
  end
end

--[[ Window Management ]]
local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate center position
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = {
      { '╭', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '╮', 'FloatBorder' },
      { '│', 'FloatBorder' },
      { '╯', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '╰', 'FloatBorder' },
      { '│', 'FloatBorder' },
    },
    zindex = 150,
    title = get_window_title(),
    title_pos = 'left',
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { win = win, buf = buf }
end

--[[ Terminal Management ]]
local function init_terminal_buffer(buf_index)
  local buf_config = state.floating.bufs[buf_index]

  if not vim.api.nvim_buf_is_valid(buf_config.buf) or vim.bo[buf_config.buf].buftype ~= 'terminal' then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    if buf_config.command then
      buf_config.buf = buf
      vim.fn.termopen(buf_config.command)
    else
      vim.cmd.terminal()
      buf_config.buf = buf
    end
  end

  return buf_config.buf
end

local function switch_to_buffer(buf_number)
  if buf_number >= 1 and buf_number <= #state.floating.bufs then
    state.floating.current_buf = buf_number
    if not vim.api.nvim_win_is_valid(state.floating.win) then
      local result = create_floating_window()
      state.floating.win = result.win
    end
    local buf = init_terminal_buffer(buf_number)
    vim.api.nvim_win_set_buf(state.floating.win, buf)
    vim.cmd 'startinsert' -- Automatically switch to terminal mode
    update_window_title()
  end
end

local function toggle_terminal()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    local result = create_floating_window()
    state.floating.win = result.win
    local buf = init_terminal_buffer(state.floating.current_buf)
    vim.api.nvim_win_set_buf(state.floating.win, buf)
    vim.cmd 'startinsert' -- Automatically switch to terminal mode
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

local function kill_current_buffer()
  if vim.api.nvim_win_is_valid(state.floating.win) then
    local current_buf_config = state.floating.bufs[state.floating.current_buf]
    local buf_to_delete = current_buf_config.buf

    vim.api.nvim_win_hide(state.floating.win)

    if vim.api.nvim_buf_is_valid(buf_to_delete) then
      vim.api.nvim_buf_delete(buf_to_delete, { force = true })
    end
    current_buf_config.buf = -1
  end
end

--[[ Key Mappings and Commands ]]
-- Terminal mode escape
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

-- Close Buoy with esc-esc in normal mode
vim.keymap.set('n', '<esc><esc>', function()
  if vim.api.nvim_get_current_win() == state.floating.win then
    vim.api.nvim_win_hide(state.floating.win)
  end
end, { desc = 'Close Buoy window' })

-- Toggle terminal
vim.api.nvim_create_user_command('Buoy', toggle_terminal, {})
vim.keymap.set('n', '<leader>bb', toggle_terminal, { desc = 'Toggle Buoy terminal' })

-- Buffer switching
vim.keymap.set('n', '<leader>b1', function()
  switch_to_buffer(1)
end, { desc = 'Switch to terminal buffer 1' })
vim.keymap.set('n', '<leader>b2', function()
  switch_to_buffer(2)
end, { desc = 'Switch to terminal buffer 2' })
vim.keymap.set('n', '<leader>b3', function()
  switch_to_buffer(3)
end, { desc = 'Switch to terminal buffer 3' })
vim.keymap.set('n', '<leader>bg', function()
  switch_to_buffer(4)
end, { desc = 'Switch to Lazygit' })

-- Buffer management
vim.keymap.set('n', '<leader>bk', kill_current_buffer, { desc = 'Kill current buoy buffer' })

--[[ Autocommands ]]
-- Function to show mode notification
local function show_mode_notification()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    return -- Do not show notification if Buoy window is not visible
  end

  local mode = vim.api.nvim_get_mode().mode
  local mode_str = mode:match '^t' and '[ TERM ]' or '[ NORM ]'

  local width = 20
  local height = 1
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep(' ', math.floor((width - #mode_str) / 2)) .. mode_str })

  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'single',
    zindex = 700, -- Ensure notification appears above the Buoy window
  })

  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 2000) -- Close after 2 seconds
end

local buoy_visible = false

vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  callback = function()
    -- Only update title and show notification if Buoy window is visible and not just entered
    if vim.api.nvim_win_is_valid(state.floating.win) and vim.api.nvim_get_current_win() == state.floating.win then
      if buoy_visible then
        update_window_title()
        show_mode_notification()
      end
      buoy_visible = true
    else
      buoy_visible = false
    end
  end,
})
