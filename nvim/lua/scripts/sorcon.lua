-- Initialize backend (change to sorcon_be_mock for testing)
local backend = require('scripts.sorcon_be_ado')

-- Helper function to format author name
local function format_author(name)
  if #name > 15 then
    return name:sub(1, 12) .. "..."
  end
  return name
end

-- Show PR comments with virtual text
local function show_pr_comments(pr, bufnr)
  -- Check if get_threads function exists in backend
  if not backend.get_threads then
    -- Function not implemented yet, skip showing comments
    return
  end
  
  local threads = backend.get_threads(pr)
  if not threads or #threads == 0 then return end

  -- Create namespace for comment extmarks
  local ns_id = vim.api.nvim_create_namespace('sorcon_comments')

  -- Add highlight groups
  vim.api.nvim_set_hl(0, 'SorconCommentIndicator', { fg = '#61afef', bold = true })
  vim.api.nvim_set_hl(0, 'SorconCommentAuthor', { fg = '#98c379', bold = true })
  vim.api.nvim_set_hl(0, 'SorconCommentDate', { fg = '#888888', italic = true })
  vim.api.nvim_set_hl(0, 'SorconCommentState', { fg = '#d19a66', bold = true })

  -- Store thread data globally for access in toggle function
  _G.sorcon_thread_data = _G.sorcon_thread_data or {}
  _G.sorcon_thread_data[bufnr] = {}
  
  -- Store floating window state
  _G.sorcon_float_wins = _G.sorcon_float_wins or {}

  -- Collect threads with invalid line numbers
  local invalid_threads = {}
  
  -- Add comment thread indicators and hover handlers
  for _, thread in ipairs(threads) do
    local line_num = thread.threadContext.rightFileStart.line - 1  -- Convert to 0-based
    
    -- Check if line number is valid for the current buffer
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_num < 0 or line_num >= buf_line_count then
      -- Collect invalid threads to display at bottom
      table.insert(invalid_threads, thread)
      goto continue
    end
    
    -- Store thread data
    _G.sorcon_thread_data[bufnr][line_num] = thread
    
    -- Create the metadata line
    local comment_count = #thread.comments
    local latest_comment = thread.comments[#thread.comments]
    local metadata = string.format(
      "💬 %d message%s | Last: @%s | State: %s",
      comment_count,
      comment_count > 1 and "s" or "",
      format_author(latest_comment.author.displayName),
      thread.status or "Active"
    )
    
    -- Create extmark with metadata
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_num, 0, {
      virt_text = {
        { metadata, "SorconCommentIndicator" }
      },
      virt_text_pos = "overlay",
      hl_mode = "combine"
    })
    
    ::continue::
  end
  
  -- Display invalid threads at the bottom of the buffer
  if #invalid_threads > 0 then
    local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
    local bottom_line = buf_line_count - 1  -- 0-based
    
    -- Add a separator line
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, bottom_line, 0, {
      virt_text = {
        { string.format("─── %d comment thread%s with invalid line numbers ───",
          #invalid_threads, #invalid_threads > 1 and "s" or ""), "SorconCommentDate" }
      },
      virt_text_pos = "eol"
    })
    
    -- Display each invalid thread
    for i, thread in ipairs(invalid_threads) do
      local original_line = thread.threadContext.rightFileStart.line
      local comment_count = #thread.comments
      local latest_comment = thread.comments[#thread.comments]
      local metadata = string.format(
        "💬 Line %d: %d message%s | Last: @%s | State: %s",
        original_line,
        comment_count,
        comment_count > 1 and "s" or "",
        format_author(latest_comment.author.displayName),
        thread.status or "Active"
      )
      
      -- Store thread data using a special key for invalid threads
      local invalid_key = string.format("invalid_%d", i)
      _G.sorcon_thread_data[bufnr][invalid_key] = thread
      
      -- Create extmark at bottom
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, bottom_line, 0, {
        virt_text = {
          { metadata, "SorconCommentIndicator" }
        },
        virt_text_pos = "eol"
      })
    end
  end

  -- Clean up when buffer is unloaded
  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = bufnr,
    callback = function()
      vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    end,
    once = true
  })
end

-- Show diff for first changed file
local function show_pr_diff(pr)
  local file_info = backend.fetch_first_change(pr)
  if not file_info then return end

  -- Get source branch content
  local source_ref = string.format('origin/%s', pr.sourceRefName:gsub('^refs/heads/', ''))
  local pr_content = backend.fetch_file_content(file_info.path, source_ref)
  
  if not pr_content then
    vim.notify('Failed to fetch PR file content', vim.log.levels.ERROR)
    return
  end
  
  -- Get main branch content (may be nil for new files)
  local main_content = backend.fetch_file_content(file_info.path, 'origin/main')
  
  -- If file doesn't exist in main branch, it's a new file - use empty content
  if not main_content then
    main_content = ""
    vim.notify(string.format('File %s is new (not in main branch)', file_info.path), vim.log.levels.INFO)
  end
  
  -- Create temporary files
  local tmp_pr = os.tmpname()
  local tmp_main = os.tmpname()
  
  local f = io.open(tmp_pr, 'w')
  f:write(pr_content)
  f:close()
  
  f = io.open(tmp_main, 'w')
  f:write(main_content)
  f:close()
  
  -- Open diff view
  vim.cmd('tabnew ' .. tmp_main)
  local main_bufnr = vim.api.nvim_get_current_buf()
  vim.cmd('vertical diffsplit ' .. tmp_pr)
  local pr_bufnr = vim.api.nvim_get_current_buf()
  
  -- Show comments on the PR buffer (right side) since that's where the content is
  show_pr_comments(pr, pr_bufnr)
  
  -- Clean up temp files when buffers are closed
  vim.api.nvim_create_autocmd('BufUnload', {
    pattern = {tmp_main, tmp_pr},
    callback = function()
      os.remove(tmp_main)
      os.remove(tmp_pr)
    end,
    once = true
  })
end

-- Format PR for display
local function format_pr(pr)
  local author = format_author(pr.createdBy.displayName)
  return string.format('[%s]\t\t\t%s', author, pr.title)
end

-- Show PR picker
local function pick_pr()
  local prs = backend.fetch_prs()
  if not prs then
    return
  end

  local items = {}
  local display_to_pr = {}

  for _, pr in ipairs(prs) do
    local display = format_pr(pr)
    table.insert(items, display)
    display_to_pr[display] = pr
  end

  -- Configure the picker
  vim.ui.select(items, {
    prompt = 'Select PR:',
    format_item = function(display) return display end
  }, function(choice)
    if choice then
      local selected_pr = display_to_pr[choice]
      -- Show more detailed information about the selected PR
      local details = string.format(
        '\nPR #%d: %s\nAuthor: %s\nCreated: %s\nSource: %s → %s\nURL: %s',
        selected_pr.pullRequestId,
        selected_pr.title,
        selected_pr.createdBy.displayName,
        selected_pr.creationDate:sub(1, 10),
        selected_pr.sourceRefName:gsub('refs/heads/', ''),
        selected_pr.targetRefName:gsub('refs/heads/', ''),
        selected_pr.url
      )
      print(details)
      
      -- Store current PR globally for panel access
      _G.current_pr = selected_pr
      
      -- Open PR review panel instead of diff
      open_pr_review_panel(selected_pr)
    end
  end)
end

-- Define the command and mapping
-- Toggle comment thread display
local function toggle_thread()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local thread = _G.sorcon_thread_data[bufnr] and _G.sorcon_thread_data[bufnr][line]
  
  if not thread then return end
  
  -- Close existing float window if it exists
  if _G.sorcon_float_wins[line] then
    local win_valid = vim.api.nvim_win_is_valid(_G.sorcon_float_wins[line])
    if win_valid then
      vim.api.nvim_win_close(_G.sorcon_float_wins[line], true)
      _G.sorcon_float_wins[line] = nil
      return
    end
  end

  local content = {}
  
  -- Format each comment in the thread
  for _, comment in ipairs(thread.comments) do
    local author = format_author(comment.author and comment.author.displayName or "Unknown")
    local date = comment.createdDate and comment.createdDate:sub(1, 10) or "Unknown date"
    
    table.insert(content, string.format("@%s", author))
    table.insert(content, string.format("Posted on %s", date))
    table.insert(content, "")
    
    -- Add comment content, preserving line breaks
    local comment_text = comment.content or "No content"
    for _, line in ipairs(vim.split(comment_text, "\n", { plain = true })) do
      table.insert(content, line)
    end
    table.insert(content, string.rep("─", 30))
  end
  
  -- Remove last separator
  if #content > 0 then
    table.remove(content)
  end

  -- Show floating window with comments
  local popup_bufnr, winnr = vim.lsp.util.open_floating_preview(content, 'markdown', {
    border = 'rounded',
    max_width = 80,
    max_height = 20,
    focus = false
  })

  _G.sorcon_float_wins[line] = winnr
  
  -- Explicitly set focus to the floating window
  vim.api.nvim_set_current_win(winnr)
  
  -- Add keybindings to close the floating window
  local function close_float()
    if vim.api.nvim_win_is_valid(winnr) then
      vim.api.nvim_win_close(winnr, true)
      _G.sorcon_float_wins[line] = nil
    end
  end
  
  -- Set keybindings for the floating window buffer
  vim.keymap.set('n', 'q', close_float, { buffer = popup_bufnr, desc = 'Close comment thread' })
  vim.keymap.set('n', '<Esc>', close_float, { buffer = popup_bufnr, desc = 'Close comment thread' })

  -- Add highlights to the popup
  for i, line in ipairs(content) do
    if line:match("^@") then
      vim.api.nvim_buf_add_highlight(popup_bufnr, 0, 'SorconCommentAuthor', i-1, 0, -1)
    elseif line:match("^Posted on") then
      vim.api.nvim_buf_add_highlight(popup_bufnr, 0, 'SorconCommentDate', i-1, 0, -1)
    end
  end
end

vim.api.nvim_create_user_command('AzurePRs', function(_)
  pick_pr()
end, {})

-- Key mappings
vim.keymap.set('n', '<leader>pr', function()
  pick_pr()
end, { desc = 'List Azure PRs' })

-- PR Review Panel state
local review_panel_state = {
  threads_winnr = nil,
  threads_bufnr = nil,
  files_winnr = nil,
  files_bufnr = nil,
  current_threads = {},
  current_files = {},
  active_panel = 'threads' -- 'threads' or 'files'
}

-- Create a simplified thread popup (reusable from panel)
local function show_thread_popup(thread)
  local content = {}
  
  -- Format each comment in the thread
  for _, comment in ipairs(thread.comments) do
    local author = format_author(comment.author and comment.author.displayName or "Unknown")
    local date = comment.createdDate and comment.createdDate:sub(1, 10) or "Unknown date"
    
    table.insert(content, string.format("@%s", author))
    table.insert(content, string.format("Posted on %s", date))
    table.insert(content, "")
    
    -- Add comment content, preserving line breaks
    local comment_text = comment.content or "No content"
    for _, line in ipairs(vim.split(comment_text, "\n", { plain = true })) do
      table.insert(content, line)
    end
    table.insert(content, string.rep("─", 30))
  end
  
  -- Remove last separator
  if #content > 0 then
    table.remove(content)
  end
  
  table.insert(content, "")
  table.insert(content, "Press 'q' to close")

  -- Show floating window with comments
  local popup_bufnr, winnr = vim.lsp.util.open_floating_preview(content, 'markdown', {
    border = 'rounded',
    max_width = 80,
    max_height = 20,
    focus = true
  })
  
  -- Add keybindings to close the floating window
  local function close_float()
    if vim.api.nvim_win_is_valid(winnr) then
      vim.api.nvim_win_close(winnr, true)
    end
  end
  
  vim.keymap.set('n', 'q', close_float, { buffer = popup_bufnr, desc = 'Close comment thread' })
  vim.keymap.set('n', '<Esc>', close_float, { buffer = popup_bufnr, desc = 'Close comment thread' })

  -- Add highlights to the popup
  for i, line in ipairs(content) do
    if line:match("^@") then
      vim.api.nvim_buf_add_highlight(popup_bufnr, 0, 'SorconCommentAuthor', i-1, 0, -1)
    elseif line:match("^Posted on") then
      vim.api.nvim_buf_add_highlight(popup_bufnr, 0, 'SorconCommentDate', i-1, 0, -1)
    end
  end
end

-- Get list of changed files in PR (placeholder - would need backend implementation)
local function get_pr_files(pr)
  -- This is a placeholder - in real implementation, you'd fetch from Azure DevOps API
  -- For now, return a sample list
  return {
    { path = "/src/eligible_pop_calculation/classes/inference_metrics.py", status = "added" },
    { path = "/src/projects/metrics_efficacy/efficacy_metric_handler.py", status = "modified" },
    { path = "/tests/test_inference.py", status = "modified" },
    { path = "/docs/readme.md", status = "modified" }
  }
end

-- Create PR review panel with threads and files using real vim splits
local function open_pr_review_panel(pr)
  -- Get threads and files
  local threads = backend.get_threads and backend.get_threads(pr) or {}
  local files = get_pr_files(pr)
  
  review_panel_state.current_threads = threads
  review_panel_state.current_files = files
  
  -- Open a new tab for the PR review
  vim.cmd('tabnew')
  
  -- Create vertical split for panel on the right
  vim.cmd('vnew')
  
  -- Create threads buffer (upper split)
  review_panel_state.threads_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(review_panel_state.threads_bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(review_panel_state.threads_bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_name(review_panel_state.threads_bufnr, 'PR-Threads')
  
  -- Format threads content
  local threads_content = {}
  table.insert(threads_content, "PR Comment Threads")
  table.insert(threads_content, string.rep("─", 50))
  table.insert(threads_content, "")
  
  if #threads > 0 then
    for i, thread in ipairs(threads) do
      local file_path = thread.threadContext and thread.threadContext.filePath or "Unknown file"
      local line_num = thread.threadContext and thread.threadContext.rightFileStart and thread.threadContext.rightFileStart.line or "?"
      local comment_count = #thread.comments
      local latest_comment = thread.comments[#thread.comments]
      local author = latest_comment and latest_comment.author and latest_comment.author.displayName or "Unknown"
      
      local short_file = file_path:match("([^/]+)$") or file_path
      local thread_line = string.format("%d. %s:%s - %d comment%s by @%s",
        i,
        short_file,
        line_num,
        comment_count,
        comment_count > 1 and "s" or "",
        format_author(author)
      )
      table.insert(threads_content, thread_line)
    end
  else
    table.insert(threads_content, "No comment threads found")
  end
  
  table.insert(threads_content, "")
  table.insert(threads_content, "j/k - navigate | l - open thread | Ctrl+hjkl - switch windows")
  
  vim.api.nvim_buf_set_lines(review_panel_state.threads_bufnr, 0, -1, false, threads_content)
  vim.api.nvim_buf_set_option(review_panel_state.threads_bufnr, 'modifiable', false)
  
  -- Set threads buffer in current window
  vim.api.nvim_win_set_buf(0, review_panel_state.threads_bufnr)
  review_panel_state.threads_winnr = vim.api.nvim_get_current_win()
  
  -- Create horizontal split below for files
  vim.cmd('split')
  
  -- Create files buffer (lower split)
  review_panel_state.files_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(review_panel_state.files_bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(review_panel_state.files_bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_name(review_panel_state.files_bufnr, 'PR-Files')
  
  -- Format files content
  local files_content = {}
  table.insert(files_content, "Changed Files")
  table.insert(files_content, string.rep("─", 50))
  table.insert(files_content, "")
  
  for i, file in ipairs(files) do
    local status_icon = file.status == "added" and "+" or file.status == "modified" and "~" or "?"
    local short_path = file.path:match("([^/]+)$") or file.path
    local file_line = string.format("%d. [%s] %s", i, status_icon, short_path)
    table.insert(files_content, file_line)
  end
  
  table.insert(files_content, "")
  table.insert(files_content, "j/k - navigate | l - open diff | Ctrl+hjkl - switch windows")
  
  vim.api.nvim_buf_set_lines(review_panel_state.files_bufnr, 0, -1, false, files_content)
  vim.api.nvim_buf_set_option(review_panel_state.files_bufnr, 'modifiable', false)
  
  -- Set files buffer in current window
  vim.api.nvim_win_set_buf(0, review_panel_state.files_bufnr)
  review_panel_state.files_winnr = vim.api.nvim_get_current_win()
  
  -- Go back to threads window and set cursor
  vim.api.nvim_set_current_win(review_panel_state.threads_winnr)
  if #threads > 0 then
    vim.api.nvim_win_set_cursor(review_panel_state.threads_winnr, {4, 0})
  end
  
  -- Setup keybindings
  setup_review_panel_keybindings()
end

-- Setup keybindings for the review panel
local function setup_review_panel_keybindings()
  local function close_review_panel()
    -- Close the entire tab since we're using real vim splits
    vim.cmd('tabclose')
    review_panel_state = {
      threads_winnr = nil,
      threads_bufnr = nil,
      files_winnr = nil,
      files_bufnr = nil,
      current_threads = {},
      current_files = {},
      active_panel = 'threads'
    }
  end
  
  -- Threads panel keybindings
  if review_panel_state.threads_bufnr then
    vim.keymap.set('n', 'q', close_review_panel, { buffer = review_panel_state.threads_bufnr, desc = 'Close review panel' })
    
    vim.keymap.set('n', 'l', function()
      local cursor = vim.api.nvim_win_get_cursor(review_panel_state.threads_winnr)
      local thread_idx = cursor[1] - 3
      if thread_idx >= 1 and thread_idx <= #review_panel_state.current_threads then
        local selected_thread = review_panel_state.current_threads[thread_idx]
        show_thread_popup(selected_thread)
      end
    end, { buffer = review_panel_state.threads_bufnr, desc = 'Open selected thread' })
    
    vim.keymap.set('n', 'j', function()
      local cursor = vim.api.nvim_win_get_cursor(review_panel_state.threads_winnr)
      local max_line = 3 + #review_panel_state.current_threads
      if cursor[1] < max_line then
        vim.api.nvim_win_set_cursor(review_panel_state.threads_winnr, {cursor[1] + 1, 0})
      end
    end, { buffer = review_panel_state.threads_bufnr, desc = 'Next thread' })
    
    vim.keymap.set('n', 'k', function()
      local cursor = vim.api.nvim_win_get_cursor(review_panel_state.threads_winnr)
      if cursor[1] > 4 then
        vim.api.nvim_win_set_cursor(review_panel_state.threads_winnr, {cursor[1] - 1, 0})
      end
    end, { buffer = review_panel_state.threads_bufnr, desc = 'Previous thread' })
  end
  
  -- Files panel keybindings
  if review_panel_state.files_bufnr then
    vim.keymap.set('n', 'q', close_review_panel, { buffer = review_panel_state.files_bufnr, desc = 'Close review panel' })
    
    vim.keymap.set('n', 'l', function()
      local cursor = vim.api.nvim_win_get_cursor(review_panel_state.files_winnr)
      local file_idx = cursor[1] - 3
      if file_idx >= 1 and file_idx <= #review_panel_state.current_files then
        local selected_file = review_panel_state.current_files[file_idx]
        show_file_diff(selected_file, _G.current_pr)
      end
    end, { buffer = review_panel_state.files_bufnr, desc = 'Open selected file diff' })
    
    vim.keymap.set('n', 'j', function()
      local cursor = vim.api.nvim_win_get_cursor(review_panel_state.files_winnr)
      local max_line = 3 + #review_panel_state.current_files
      if cursor[1] < max_line then
        vim.api.nvim_win_set_cursor(review_panel_state.files_winnr, {cursor[1] + 1, 0})
      end
    end, { buffer = review_panel_state.files_bufnr, desc = 'Next file' })
    
    vim.keymap.set('n', 'k', function()
      local cursor = vim.api.nvim_win_get_cursor(review_panel_state.files_winnr)
      if cursor[1] > 4 then
        vim.api.nvim_win_set_cursor(review_panel_state.files_winnr, {cursor[1] - 1, 0})
      end
    end, { buffer = review_panel_state.files_bufnr, desc = 'Previous file' })
  end
end

-- Show diff for a specific file
local function show_file_diff(file, pr)
  -- Get source branch content
  local source_ref = string.format('origin/%s', pr.sourceRefName:gsub('^refs/heads/', ''))
  local pr_content = backend.fetch_file_content(file.path, source_ref)
  
  if not pr_content then
    vim.notify('Failed to fetch PR file content', vim.log.levels.ERROR)
    return
  end
  
  -- Get main branch content (may be nil for new files)
  local main_content = backend.fetch_file_content(file.path, 'origin/main')
  
  -- If file doesn't exist in main branch, it's a new file - use empty content
  if not main_content then
    main_content = ""
    vim.notify(string.format('File %s is new (not in main branch)', file.path), vim.log.levels.INFO)
  end
  
  -- Create temporary files
  local tmp_pr = os.tmpname()
  local tmp_main = os.tmpname()
  
  local f = io.open(tmp_pr, 'w')
  f:write(pr_content)
  f:close()
  
  f = io.open(tmp_main, 'w')
  f:write(main_content)
  f:close()
  
  -- Move to the left side of the split (where empty buffer should be)
  vim.cmd('wincmd h')
  
  -- Open diff view in the left area
  vim.cmd('edit ' .. tmp_main)
  local main_bufnr = vim.api.nvim_get_current_buf()
  vim.cmd('vertical diffsplit ' .. tmp_pr)
  local pr_bufnr = vim.api.nvim_get_current_buf()
  
  -- Show comments on the PR buffer (right side) since that's where the content is
  show_pr_comments(pr, pr_bufnr)
  
  -- Clean up temp files when buffers are closed
  vim.api.nvim_create_autocmd('BufUnload', {
    pattern = {tmp_main, tmp_pr},
    callback = function()
      os.remove(tmp_main)
      os.remove(tmp_pr)
    end,
    once = true
  })
end

vim.keymap.set('n', '<leader>pc', function()
  toggle_thread()
end, { desc = 'Toggle PR comment thread' })

vim.keymap.set('n', '<leader>pt', function()
  -- Get current PR
  if _G.current_pr then
    open_pr_review_panel(_G.current_pr)
  else
    vim.notify('No PR selected. Use <leader>pr to select a PR first.', vim.log.levels.WARN)
  end
end, { desc = 'Open PR review panel' })
