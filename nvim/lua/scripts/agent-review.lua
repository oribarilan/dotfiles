-- agent-review.lua
-- Review external file changes (e.g. from coding agents) hunk by hunk.
-- See agent-review-spec.md for the full design spec.
--
-- Uses git stash create as a read-only snapshot on FocusLost. On FocusGained,
-- diffs against that snapshot to detect changes. Uses mini.diff for
-- visualization, hunk navigation, and approve/reject per hunk.
--
-- Git repos only — completely inert outside a git repo.

local M = {}

-- ============================================================================
-- State
-- ============================================================================

M._snapshot = nil -- { ref = string, untracked = string[] }
M._git_root = nil -- cached repo root (absolute path)
M._changed_files = {} -- abs paths of tracked files changed by agent (open buffers)
M._pending_files = {} -- abs paths of tracked files changed by agent (not yet opened)
M._new_files = {} -- abs paths of new untracked files created by agent
M._reviews = {} -- { [buf_id] = { ref_text = string, original_ref = string|nil } }

-- ============================================================================
-- Highlight groups
-- ============================================================================

local ns = vim.api.nvim_create_namespace 'agent_review'

--- Run callback after mini.diff has finished recomputing hunks for buf_id.
--- Hooks into the MiniDiffUpdated User event which mini.diff fires after
--- each buffer's diff is recomputed. Since we only call set_ref_text on one
--- buffer at a time during review, the next event is reliably ours.
--- Includes a timer fallback in case the event doesn't fire.
local function after_diff_update(buf_id, fn)
  local fired = false

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniDiffUpdated',
    once = true,
    callback = function()
      if fired then
        return
      end
      fired = true
      fn()
    end,
  })

  -- Safety fallback: if the event never fires (e.g., no actual diff change),
  -- run after 200ms
  vim.defer_fn(function()
    if not fired then
      fired = true
      fn()
    end
  end, 200)
end

vim.api.nvim_set_hl(0, 'AgentReviewHint', { fg = '#89b4fa', italic = true })
vim.api.nvim_set_hl(0, 'AgentReviewKey', { fg = '#f9e2af', bold = true })
vim.api.nvim_set_hl(0, 'AgentReviewSep', { fg = '#585b70' })
vim.api.nvim_set_hl(0, 'AgentReviewCount', { fg = '#a6e3a1', bold = true })

-- ============================================================================
-- Git helpers
-- ============================================================================

--- Run a git command synchronously, return trimmed stdout or nil on failure.
--- All git commands run with -C <git_root> to ensure correct repo context
--- regardless of Neovim's CWD.
local function git(args)
  local root = M._git_root
  local cmd
  if root then
    cmd = vim.list_extend({ 'git', '-C', root }, args)
  else
    cmd = vim.list_extend({ 'git' }, args)
  end
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(result)
end

--- Run a git command, return lines (split on newline), empty table on failure.
local function git_lines(args)
  local out = git(args)
  if not out or out == '' then
    return {}
  end
  return vim.split(out, '\n', { plain = true, trimempty = true })
end

--- Get the git repo root. Cached after first call. Returns nil if not in a repo.
--- Uses the current buffer's directory to find the right repo, not Neovim's CWD.
function M._get_git_root()
  if M._git_root then
    return M._git_root
  end
  -- Use current buffer's directory to find the repo root
  local buf_dir = vim.fn.expand '%:p:h'
  if buf_dir == '' then
    buf_dir = vim.fn.getcwd()
  end
  local result = vim.fn.system { 'git', '-C', buf_dir, 'rev-parse', '--show-toplevel' }
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local root = vim.trim(result)
  if root and root ~= '' then
    M._git_root = root
  end
  return M._git_root
end

--- Convert a git-relative path to an absolute path.
local function to_abs(git_path)
  local root = M._get_git_root()
  if not root then
    return nil
  end
  return root .. '/' .. git_path
end

--- Convert an absolute path to a git-relative path.
local function to_rel(abs_path)
  local root = M._get_git_root()
  if not root then
    return nil
  end
  if abs_path:sub(1, #root + 1) == root .. '/' then
    return abs_path:sub(#root + 2)
  end
  return nil
end

--- Check if mini.diff is available.
local function has_minidiff()
  local ok, _ = pcall(require, 'mini.diff')
  return ok
end

--- Find the buffer number for a file path, or nil if not loaded.
local function find_buf(abs_path)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == abs_path then
      return buf
    end
  end
  return nil
end

-- ============================================================================
-- Snapshot (FocusLost)
-- ============================================================================

--- Create a snapshot of the working tree state.
function M._take_snapshot()
  local root = M._get_git_root()
  if not root then
    return
  end

  -- Don't overwrite snapshot while reviews are active
  if vim.tbl_count(M._reviews) > 0 then
    return
  end

  -- git stash create: read-only snapshot, no side effects
  local ref = git { 'stash', 'create' }
  if not ref or ref == '' then
    ref = 'HEAD' -- clean tree
  end

  -- Record untracked non-ignored files
  local untracked = git_lines { 'ls-files', '--others', '--exclude-standard' }

  M._snapshot = {
    ref = ref,
    untracked = untracked,
  }
end

-- ============================================================================
-- Detection (FocusGained)
-- ============================================================================

--- Detect changes since the last snapshot.
function M._detect_changes()
  local root = M._get_git_root()
  if not root then
    return
  end

  if not M._snapshot then
    return
  end

  -- Find changed tracked files
  local changed = git_lines { 'diff', M._snapshot.ref, '--name-only' }

  -- Find new untracked files
  local current_untracked = git_lines { 'ls-files', '--others', '--exclude-standard' }
  local old_set = {}
  for _, f in ipairs(M._snapshot.untracked) do
    old_set[f] = true
  end
  local new_untracked = {}
  for _, f in ipairs(current_untracked) do
    if not old_set[f] then
      table.insert(new_untracked, f)
    end
  end

  -- Nothing changed
  if #changed == 0 and #new_untracked == 0 then
    return
  end

  -- Classify tracked changes: open buffer vs pending
  M._changed_files = {}
  M._pending_files = {}
  for _, rel_path in ipairs(changed) do
    local abs_path = to_abs(rel_path)
    if abs_path then
      local buf = find_buf(abs_path)
      if buf then
        -- Skip if already in review
        if not M._reviews[buf] then
          table.insert(M._changed_files, abs_path)
        end
      else
        table.insert(M._pending_files, abs_path)
      end
    end
  end

  -- Store new files
  M._new_files = {}
  for _, rel_path in ipairs(new_untracked) do
    local abs_path = to_abs(rel_path)
    if abs_path then
      table.insert(M._new_files, abs_path)
    end
  end

  -- Populate quickfix
  M._update_quickfix()

  -- Open quickfix window if there are entries
  local total = #M._changed_files + #M._pending_files + #M._new_files
  if total > 0 then
    vim.cmd 'silent! copen'
    -- Return focus to the previous window (not the quickfix)
    vim.cmd 'silent! wincmd p'
  end
end

-- ============================================================================
-- Review mode
-- ============================================================================

--- Start review mode for a buffer using git show <ref>:path as reference.
function M.start_review(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()

  if not has_minidiff() then
    vim.notify('agent-review: mini.diff is required', vim.log.levels.WARN)
    return
  end

  if not M._snapshot then
    return
  end

  local abs_path = vim.api.nvim_buf_get_name(buf_id)
  local rel_path = to_rel(abs_path)
  if not rel_path then
    return
  end

  -- Get the "before" content from the snapshot
  local ref_content = git { 'show', M._snapshot.ref .. ':' .. rel_path }
  if not ref_content then
    -- File didn't exist at snapshot time (new file), skip review
    return
  end
  -- Ensure trailing newline for proper diff
  if ref_content:sub(-1) ~= '\n' then
    ref_content = ref_content .. '\n'
  end

  local MiniDiff = require 'mini.diff'

  -- Save original reference text so we can restore later
  local buf_data = MiniDiff.get_buf_data(buf_id)
  local original_ref = buf_data and buf_data.ref_text or nil

  -- Store review state
  M._reviews[buf_id] = {
    ref_text = ref_content,
    original_ref = original_ref,
    original_autoread = vim.bo[buf_id].autoread,
  }

  -- Protect buffer from auto-reload during review
  vim.bo[buf_id].autoread = false

  -- Set the snapshot content as mini.diff reference
  MiniDiff.set_ref_text(buf_id, ref_content)

  -- Set up keymaps immediately (they don't depend on hunk positions)
  M._set_review_keymaps(buf_id)

  -- Defer overlay, hints, and navigation until mini.diff recomputes hunks
  after_diff_update(buf_id, function()
    -- Enable overlay
    buf_data = MiniDiff.get_buf_data(buf_id)
    if buf_data and not buf_data.overlay then
      MiniDiff.toggle_overlay(buf_id)
    end

    -- Jump to first hunk
    pcall(MiniDiff.goto_hunk, 'first')

    M._update_hints(buf_id)
    M._update_quickfix()

    -- Notify
    buf_data = MiniDiff.get_buf_data(buf_id)
    local n_hunks = buf_data and #buf_data.hunks or 0
    local n_files = vim.tbl_count(M._reviews) + #M._pending_files
    local file_msg = n_files > 1 and string.format(' (%d files total)', n_files) or ''
    vim.notify(
      string.format('Agent review: %d hunk(s) to review%s', n_hunks, file_msg),
      vim.log.levels.INFO
    )
  end)
end

--- Approve the hunk under cursor (keep the agent's change).
function M.approve_hunk(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()

  local review = M._reviews[buf_id]
  if not review then
    return
  end

  local MiniDiff = require 'mini.diff'
  local buf_data = MiniDiff.get_buf_data(buf_id)
  if not buf_data or #buf_data.hunks == 0 then
    vim.notify('agent-review: no hunks remaining', vim.log.levels.INFO)
    M.finish_review(buf_id)
    return
  end

  -- Find hunk at cursor
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local hunk = M._find_hunk_at_line(buf_data.hunks, cursor_line)
  if not hunk then
    vim.notify('agent-review: no hunk at cursor. use ]h/[h to navigate', vim.log.levels.WARN)
    return
  end

  -- Approve = update reference to match buffer for this hunk
  local ref_lines = vim.split(review.ref_text, '\n', { plain = true })
  if ref_lines[#ref_lines] == '' then
    table.remove(ref_lines)
  end

  local buf_lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  local new_ref_lines = {}

  if hunk.type == 'add' then
    for i = 1, hunk.ref_start do
      table.insert(new_ref_lines, ref_lines[i])
    end
    for i = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
      table.insert(new_ref_lines, buf_lines[i])
    end
    for i = hunk.ref_start + 1, #ref_lines do
      table.insert(new_ref_lines, ref_lines[i])
    end
  elseif hunk.type == 'delete' then
    for i = 1, hunk.ref_start - 1 do
      table.insert(new_ref_lines, ref_lines[i])
    end
    -- skip deleted ref lines (approve = keep them deleted)
    for i = hunk.ref_start + hunk.ref_count, #ref_lines do
      table.insert(new_ref_lines, ref_lines[i])
    end
  elseif hunk.type == 'change' then
    for i = 1, hunk.ref_start - 1 do
      table.insert(new_ref_lines, ref_lines[i])
    end
    for i = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
      table.insert(new_ref_lines, buf_lines[i])
    end
    for i = hunk.ref_start + hunk.ref_count, #ref_lines do
      table.insert(new_ref_lines, ref_lines[i])
    end
  end

  review.ref_text = table.concat(new_ref_lines, '\n') .. '\n'
  MiniDiff.set_ref_text(buf_id, review.ref_text)

  -- Defer until mini.diff recomputes hunks with new ref text
  after_diff_update(buf_id, function()
    local new_data = MiniDiff.get_buf_data(buf_id)
    local remaining = new_data and #new_data.hunks or 0

    if remaining == 0 then
      vim.notify('agent-review: all hunks approved', vim.log.levels.INFO)
      M.finish_review(buf_id)
    else
      vim.notify(string.format('agent-review: approved. %d remaining', remaining), vim.log.levels.INFO)
      M._update_hints(buf_id)
      M._update_quickfix()
      pcall(MiniDiff.goto_hunk, 'next')
    end
  end)
end

--- Reject the hunk under cursor (revert to the pre-change text).
function M.reject_hunk(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()

  local review = M._reviews[buf_id]
  if not review then
    return
  end

  local MiniDiff = require 'mini.diff'
  local buf_data = MiniDiff.get_buf_data(buf_id)
  if not buf_data or #buf_data.hunks == 0 then
    vim.notify('agent-review: no hunks remaining', vim.log.levels.INFO)
    M.finish_review(buf_id)
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local hunk = M._find_hunk_at_line(buf_data.hunks, cursor_line)
  if not hunk then
    vim.notify('agent-review: no hunk at cursor. use ]h/[h to navigate', vim.log.levels.WARN)
    return
  end

  -- Reset this hunk via mini.diff
  local line_start, line_end
  if hunk.buf_count > 0 then
    line_start = hunk.buf_start
    line_end = hunk.buf_start + hunk.buf_count - 1
  else
    line_start = math.max(1, hunk.buf_start)
    line_end = line_start
  end

  MiniDiff.do_hunks(buf_id, 'reset', { line_start = line_start, line_end = line_end })

  -- do_hunks('reset') changes buffer text, which triggers mini.diff's
  -- text_change debounce (200ms). Force an immediate re-diff by re-setting
  -- the same ref text — set_ref_text uses delay 0, which resets the timer.
  MiniDiff.set_ref_text(buf_id, review.ref_text)

  -- Defer until mini.diff recomputes hunks after buffer change
  after_diff_update(buf_id, function()
    local new_data = MiniDiff.get_buf_data(buf_id)
    local remaining = new_data and #new_data.hunks or 0
    if remaining == 0 then
      vim.notify('agent-review: all hunks reviewed', vim.log.levels.INFO)
      M.finish_review(buf_id)
    else
      vim.notify(string.format('agent-review: rejected. %d remaining', remaining), vim.log.levels.INFO)
      M._update_hints(buf_id)
      M._update_quickfix()
      pcall(MiniDiff.goto_hunk, 'next')
    end
  end)
end

--- Approve all remaining hunks.
function M.approve_all(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()

  local review = M._reviews[buf_id]
  if not review then
    return
  end

  local MiniDiff = require 'mini.diff'
  local buf_lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  review.ref_text = table.concat(buf_lines, '\n') .. '\n'
  MiniDiff.set_ref_text(buf_id, review.ref_text)

  vim.notify('agent-review: approved all changes', vim.log.levels.INFO)
  M.finish_review(buf_id)
end

--- Reject all remaining hunks.
function M.reject_all(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()

  local review = M._reviews[buf_id]
  if not review then
    return
  end

  local MiniDiff = require 'mini.diff'
  MiniDiff.do_hunks(buf_id, 'reset', { line_start = 1, line_end = vim.api.nvim_buf_line_count(buf_id) })

  -- Force immediate re-diff (same reason as reject_hunk)
  MiniDiff.set_ref_text(buf_id, review.ref_text)

  vim.notify('agent-review: rejected all changes', vim.log.levels.INFO)
  vim.schedule(function()
    M.finish_review(buf_id)
  end)
end

--- Exit review mode and restore normal git diff.
function M.finish_review(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()

  local review = M._reviews[buf_id]
  if not review then
    return
  end

  local MiniDiff = require 'mini.diff'

  -- Turn off overlay
  local buf_data = MiniDiff.get_buf_data(buf_id)
  if buf_data and buf_data.overlay then
    MiniDiff.toggle_overlay(buf_id)
  end

  -- Restore original reference (git index)
  if review.original_ref then
    MiniDiff.set_ref_text(buf_id, review.original_ref)
  else
    MiniDiff.disable(buf_id)
    MiniDiff.enable(buf_id)
  end

  -- Save if modified
  if vim.bo[buf_id].modified then
    vim.api.nvim_buf_call(buf_id, function()
      vim.cmd 'silent write'
    end)
  end

  -- Restore autoread
  if review.original_autoread ~= nil then
    vim.bo[buf_id].autoread = review.original_autoread
  end

  -- Clean up
  M._clear_review_keymaps(buf_id)
  M._clear_hints(buf_id)
  M._reviews[buf_id] = nil

  -- Remove from changed files list
  local abs_path = vim.api.nvim_buf_get_name(buf_id)
  M._remove_from_list(M._changed_files, abs_path)

  M._update_quickfix()

  -- If all reviews done and no pending files, finalize
  if vim.tbl_count(M._reviews) == 0 and #M._pending_files == 0 then
    M._finalize()
  end
end

--- Called when all reviews are complete.
function M._finalize()
  -- Stage approved state
  git { 'add', '-A' }

  -- Close quickfix
  vim.cmd 'silent! cclose'

  -- Clear state and take fresh snapshot for next detection cycle
  M._changed_files = {}
  M._pending_files = {}
  M._new_files = {}
  M._snapshot = nil
  M._take_snapshot()

  vim.notify('agent-review: all files reviewed. changes staged.', vim.log.levels.INFO)
end

-- ============================================================================
-- Manual trigger
-- ============================================================================

--- Manual trigger: snapshot current state, then detect changes.
--- If a snapshot already exists, detect against it. Otherwise diff against HEAD.
function M.trigger()
  local root = M._get_git_root()
  if not root then
    vim.notify('agent-review: not in a git repo', vim.log.levels.WARN)
    return
  end

  if not has_minidiff() then
    vim.notify('agent-review: mini.diff is required', vim.log.levels.WARN)
    return
  end

  -- If no snapshot yet, create one from HEAD as baseline
  if not M._snapshot then
    M._snapshot = {
      ref = 'HEAD',
      untracked = {},
    }
  end

  M._detect_changes()

  -- Reload open buffers that changed on disk
  if vim.fn.mode() ~= 'c' then
    vim.cmd 'silent! checktime'
  end

  -- Start review directly for open buffers that checktime didn't reload.
  -- This handles the case where Neovim opened the file after the agent
  -- already modified it (buffer matches disk, so no FileChangedShellPost).
  vim.schedule(function()
    local remaining = vim.list_extend({}, M._changed_files)
    for _, abs_path in ipairs(remaining) do
      local buf = find_buf(abs_path)
      if buf and not M._reviews[buf] then
        M._remove_from_list(M._changed_files, abs_path)
        M.start_review(buf)
      end
    end
  end)
end

-- ============================================================================
-- Hunk finding
-- ============================================================================

function M._find_hunk_at_line(hunks, line)
  for _, hunk in ipairs(hunks) do
    if hunk.buf_count > 0 then
      if line >= hunk.buf_start and line <= hunk.buf_start + hunk.buf_count - 1 then
        return hunk
      end
    else
      if line == hunk.buf_start or line == hunk.buf_start + 1 then
        return hunk
      end
    end
  end
  return nil
end

-- ============================================================================
-- Virtual text hints
-- ============================================================================

function M._update_hints(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)

  local review = M._reviews[buf_id]
  if not review then
    return
  end

  local MiniDiff = require 'mini.diff'
  local buf_data = MiniDiff.get_buf_data(buf_id)
  if not buf_data or #buf_data.hunks == 0 then
    return
  end

  local total = #buf_data.hunks

  for idx, hunk in ipairs(buf_data.hunks) do
    local hint_line = hunk.buf_count > 0 and (hunk.buf_start - 1) or math.max(0, hunk.buf_start - 1)

    -- build chunks: [idx/total]  SPC ra approve | rr reject  ...
    local chunks = {
      { '  ', '' },
      { string.format('[%d/%d]', idx, total), 'AgentReviewCount' },
      { '  ', '' },
      { ' ra ', 'AgentReviewKey' },
      { 'approve', 'AgentReviewHint' },
      { '  ', '' },
      { '|', 'AgentReviewSep' },
      { '  ', '' },
      { ' rr ', 'AgentReviewKey' },
      { 'reject', 'AgentReviewHint' },
    }

    -- Bulk actions on first hunk when multiple hunks exist
    if idx == 1 and total > 1 then
      vim.list_extend(chunks, {
        { '  ', '' },
        { '|', 'AgentReviewSep' },
        { '  ', '' },
        { ' rA ', 'AgentReviewKey' },
        { 'approve all', 'AgentReviewHint' },
        { '  ', '' },
        { '|', 'AgentReviewSep' },
        { '  ', '' },
        { ' rR ', 'AgentReviewKey' },
        { 'reject all', 'AgentReviewHint' },
      })
    end

    -- Quit hint on every hunk
    vim.list_extend(chunks, {
      { '  ', '' },
      { '|', 'AgentReviewSep' },
      { '  ', '' },
      { ' rq ', 'AgentReviewKey' },
      { 'quit', 'AgentReviewHint' },
    })

    pcall(vim.api.nvim_buf_set_extmark, buf_id, ns, hint_line, 0, {
      virt_text = chunks,
      virt_text_pos = 'eol',
      hl_mode = 'combine',
    })
  end
end

function M._clear_hints(buf_id)
  pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns, 0, -1)
end

-- ============================================================================
-- Quickfix list
-- ============================================================================

function M._update_quickfix()
  local items = {}

  -- 1. Hunks from active reviews (open buffers being reviewed)
  for buf_id, _ in pairs(M._reviews) do
    if vim.api.nvim_buf_is_valid(buf_id) then
      local MiniDiff = require 'mini.diff'
      local buf_data = MiniDiff.get_buf_data(buf_id)
      if buf_data and #buf_data.hunks > 0 then
        local filename = vim.api.nvim_buf_get_name(buf_id)
        for _, hunk in ipairs(buf_data.hunks) do
          local lnum = hunk.buf_count > 0 and hunk.buf_start or math.max(1, hunk.buf_start)
          local icon = ({ add = '+', change = '~', delete = '-' })[hunk.type] or '?'
          table.insert(items, {
            filename = filename,
            lnum = lnum,
            col = 1,
            text = string.format('[%s] %d line(s)', icon, math.max(hunk.buf_count, hunk.ref_count)),
          })
        end
      end
    end
  end

  -- 2. Pending files (not yet opened)
  for _, abs_path in ipairs(M._pending_files) do
    table.insert(items, {
      filename = abs_path,
      lnum = 1,
      col = 1,
      text = '[pending] file not yet opened',
    })
  end

  -- 3. New untracked files
  for _, abs_path in ipairs(M._new_files) do
    table.insert(items, {
      filename = abs_path,
      lnum = 1,
      col = 1,
      text = '[new file] created by agent',
    })
  end

  if #items > 0 then
    vim.fn.setqflist(items, 'r')
    local reviewed = 0
    local total = #items
    for buf_id, _ in pairs(M._reviews) do
      if vim.api.nvim_buf_is_valid(buf_id) then
        local MiniDiff = require 'mini.diff'
        local buf_data = MiniDiff.get_buf_data(buf_id)
        if buf_data then
          reviewed = reviewed + #buf_data.hunks
        end
      end
    end
    vim.fn.setqflist({}, 'a', {
      title = string.format(
        'Agent Review  |  %d item(s)  |  ]q/[q navigate  |  <CR> jump to file',
        #items
      ),
    })
  else
    vim.fn.setqflist({}, 'r')
    vim.fn.setqflist({}, 'a', { title = 'Agent Review  |  all done' })
  end

  -- Set up quickfix-local keymaps for navigation hints
  M._set_quickfix_keymaps()
end

-- ============================================================================
-- Quickfix keymaps and hints
-- ============================================================================

--- Set global quickfix navigation keymaps (only while reviews are active).
function M._set_quickfix_keymaps()
  if vim.tbl_count(M._reviews) == 0 and #M._pending_files == 0 and #M._new_files == 0 then
    M._clear_quickfix_keymaps()
    return
  end

  -- Only set once
  if M._qf_keymaps_set then
    return
  end

  vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'review: next quickfix item', silent = true })
  vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'review: prev quickfix item', silent = true })
  M._qf_keymaps_set = true
end

function M._clear_quickfix_keymaps()
  if not M._qf_keymaps_set then
    return
  end
  pcall(vim.keymap.del, 'n', ']q')
  pcall(vim.keymap.del, 'n', '[q')
  M._qf_keymaps_set = false
end

-- ============================================================================
-- Buffer keymaps
-- ============================================================================

function M._set_review_keymaps(buf_id)
  local opts = { buffer = buf_id, silent = true }

  vim.keymap.set('n', '<leader>ra', function()
    M.approve_hunk(buf_id)
  end, vim.tbl_extend('force', opts, { desc = 'review: [a]pprove hunk' }))

  vim.keymap.set('n', '<leader>rr', function()
    M.reject_hunk(buf_id)
  end, vim.tbl_extend('force', opts, { desc = 'review: [r]eject hunk' }))

  vim.keymap.set('n', '<leader>rA', function()
    M.approve_all(buf_id)
  end, vim.tbl_extend('force', opts, { desc = 'review: approve [A]ll' }))

  vim.keymap.set('n', '<leader>rR', function()
    M.reject_all(buf_id)
  end, vim.tbl_extend('force', opts, { desc = 'review: [R]eject all' }))

  vim.keymap.set('n', '<leader>rq', function()
    M.finish_review(buf_id)
  end, vim.tbl_extend('force', opts, { desc = 'review: [q]uit review' }))
end

function M._clear_review_keymaps(buf_id)
  local keys = { '<leader>ra', '<leader>rr', '<leader>rA', '<leader>rR', '<leader>rq' }
  for _, key in ipairs(keys) do
    pcall(vim.keymap.del, 'n', key, { buffer = buf_id })
  end
end

-- ============================================================================
-- Utility
-- ============================================================================

function M._remove_from_list(list, value)
  for i = #list, 1, -1 do
    if list[i] == value then
      table.remove(list, i)
    end
  end
end

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Only register autocommands if in a git repo
local root = M._get_git_root()
if not root then
  return M
end

local augroup = vim.api.nvim_create_augroup('AgentReview', { clear = true })

-- Command and keymap for manual trigger
vim.api.nvim_create_user_command('AgentReview', function()
  M.trigger()
end, { desc = 'Trigger agent review: detect and review external changes' })

vim.api.nvim_create_user_command('AgentReviewDebug', function()
  local root = M._get_git_root()
  local snapshot = M._snapshot
  local ref = snapshot and snapshot.ref or 'nil'
  local changed = snapshot and git_lines { 'diff', ref, '--name-only' } or {}
  local untracked = git_lines { 'ls-files', '--others', '--exclude-standard' }
  local cwd = vim.fn.getcwd()
  local buf_dir = vim.fn.expand '%:p:h'

  local lines = {
    'agent-review debug:',
    '  cwd:        ' .. cwd,
    '  buf_dir:    ' .. buf_dir,
    '  git_root:   ' .. (root or 'nil'),
    '  snapshot:   ' .. (snapshot and ('ref=' .. ref) or 'nil'),
    '  changed:    ' .. vim.inspect(changed),
    '  untracked:  ' .. vim.inspect(untracked),
    '  reviews:    ' .. tostring(vim.tbl_count(M._reviews)),
    '  changed_f:  ' .. vim.inspect(M._changed_files),
    '  pending_f:  ' .. vim.inspect(M._pending_files),
    '  new_f:      ' .. vim.inspect(M._new_files),
  }
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end, { desc = 'Debug agent review state' })

vim.keymap.set('n', '<leader>rn', function()
  M.trigger()
end, { desc = 'review: [n]ew review (detect changes)' })

vim.api.nvim_create_user_command('AgentReviewTest', function()
  local git_root = M._get_git_root()
  if not git_root then
    vim.notify('agent-review: not in a git repo', vim.log.levels.WARN)
    return
  end

  -- Take a snapshot of the current state first
  M._take_snapshot()

  -- Simulate agent edits: modify README.md
  local readme = git_root .. '/README.md'
  local f = io.open(readme, 'r')
  if f then
    local content = f:read '*a'
    f:close()
    -- Prepend a description line after the title
    content = content:gsub('^(# dotfiles)\n', '%1\n\nPersonal dotfiles managed with care.\n', 1)
    -- Fix a typo if present
    content = content:gsub('macost', 'macOS', 1)
    f = io.open(readme, 'w')
    if f then
      f:write(content)
      f:close()
    end
  end

  -- Simulate agent creating a new file
  local testfile = git_root .. '/agent-test-file.txt'
  f = io.open(testfile, 'w')
  if f then
    f:write('This file was created by AgentReviewTest.\nIt should appear as [new file] in the quickfix list.\n')
    f:close()
  end

  vim.notify('agent-review: test changes written. triggering review...', vim.log.levels.INFO)

  -- Now trigger detection
  vim.schedule(function()
    M.trigger()
  end)
end, { desc = 'Simulate agent changes and trigger review (for testing)' })

-- FocusLost: take a snapshot of the working tree
vim.api.nvim_create_autocmd('FocusLost', {
  group = augroup,
  callback = function()
    M._take_snapshot()
  end,
})

-- FocusGained: detect changes since snapshot
vim.api.nvim_create_autocmd('FocusGained', {
  group = augroup,
  callback = function()
    M._detect_changes()
    -- Run checktime to reload changed buffers
    if vim.fn.mode() ~= 'c' then
      vim.cmd 'silent! checktime'
    end
  end,
})

-- CursorHold: also run checktime (for changes while nvim has focus)
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  group = augroup,
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd 'silent! checktime'
    end
  end,
})

-- BufEnter: also run checktime
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd 'silent! checktime'
    end
  end,
})

-- FileChangedShellPost: start review for open buffers that were reloaded
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = augroup,
  callback = function(ev)
    local abs_path = vim.api.nvim_buf_get_name(ev.buf)

    -- Check if this file was in our changed list
    local found = false
    for _, path in ipairs(M._changed_files) do
      if path == abs_path then
        found = true
        break
      end
    end

    if found then
      M._remove_from_list(M._changed_files, abs_path)
      vim.schedule(function()
        M.start_review(ev.buf)
      end)
    end
  end,
})

-- BufReadPost: start review for pending files when opened
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function(ev)
    local abs_path = vim.api.nvim_buf_get_name(ev.buf)

    local found = false
    for _, path in ipairs(M._pending_files) do
      if path == abs_path then
        found = true
        break
      end
    end

    if found then
      M._remove_from_list(M._pending_files, abs_path)
      vim.schedule(function()
        M.start_review(ev.buf)
      end)
    end
  end,
})

-- BufDelete: clean up
vim.api.nvim_create_autocmd('BufDelete', {
  group = augroup,
  callback = function(ev)
    if M._reviews[ev.buf] then
      -- Restore autoread before cleanup
      if M._reviews[ev.buf].original_autoread ~= nil then
        pcall(function()
          vim.bo[ev.buf].autoread = M._reviews[ev.buf].original_autoread
        end)
      end
      M._clear_hints(ev.buf)
      M._clear_review_keymaps(ev.buf)
      M._reviews[ev.buf] = nil
    end
  end,
})

return M
