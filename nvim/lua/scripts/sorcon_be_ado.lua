local M = {}

-- Token cache
local cached_token = nil
local token_expiry = nil

-- Azure info cache
local cached_azure_info = nil

-- PR list cache
local cached_prs = nil
local prs_cache_expiry = nil
local PR_CACHE_DURATION = 60 -- Cache PRs for 60 seconds

-- Get Azure DevOps token using Azure CLI
local function get_azure_token()
  local cmd = 'az account get-access-token --resource https://microsoft.visualstudio.com/ --query accessToken --output tsv'
  local handle = io.popen(cmd)
  if not handle then
    error 'Failed to execute az cli command'
    return nil
  end

  local token = handle:read('*a'):gsub('%s+', '') -- Remove whitespace/newlines
  handle:close()

  if token and token ~= '' then
    cached_token = token
    -- Set expiry to 55 minutes from now (tokens usually valid for 1 hour)
    token_expiry = os.time() + (55 * 60)
    return token
  end

  return nil
end

-- Ensure we have a valid token
local function ensure_token()
  if not cached_token or not token_expiry or os.time() > token_expiry then
    return get_azure_token()
  end
  return cached_token
end

-- Get organization and project from git remote
local function get_azure_info()
  -- Return cached info if available
  if cached_azure_info then
    return cached_azure_info.org, cached_azure_info.project, cached_azure_info.repo
  end
  
  local handle = io.popen('git remote get-url origin')
  if not handle then
    vim.notify('Failed to execute git remote command', vim.log.levels.ERROR)
    return nil
  end
  
  local url = handle:read('*a')
  handle:close()
  
  if not url then
    vim.notify('No URL returned from git remote', vim.log.levels.ERROR)
    return nil
  end
  
  -- Try different URL formats
  local org, project, repo
  
  -- First, get the repository name which is common across all formats
  repo = url:match('/_git/([^/\n]+)')
  if not repo then
    vim.notify('Failed to extract repository name from URL', vim.log.levels.ERROR)
    return nil
  end
  repo = repo:gsub('\n', '') -- Remove any trailing newline
  
  -- Format: https://dev.azure.com/microsoft/WDATP/_git/Port.Runner
  org = url:match('dev%.azure%.com/([^/]+)/')
  if org then
    project = url:match('dev%.azure%.com/[^/]+/([^/]+)/_git/')
    if project then
      -- Cache the result
      cached_azure_info = {org = org, project = project, repo = repo}
      return org, project, repo
    end
  end

  -- Format: https://microsoft.visualstudio.com/DefaultCollection/WDATP/_git/Port.Runner
  org = url:match('visualstudio%.com/DefaultCollection/([^/]+)/')
  if org then
    -- Cache the result
    cached_azure_info = {org = "microsoft", project = org, repo = repo}
    return "microsoft", org, repo
  end

  -- Format: https://microsoft.visualstudio.com/WDATP/_git/Port.Runner
  org = url:match('visualstudio%.com/([^/]+)/_git/')
  if org then
    -- Cache the result
    cached_azure_info = {org = "microsoft", project = org, repo = repo}
    return "microsoft", org, repo
  end
  
  -- Remove any trailing newline and return
  if repo then repo = repo:gsub('\n', '') end
  return org, project, repo
end

-- Implementation of the interface
function M.fetch_prs()
  -- Check if we have cached PRs that are still valid
  if cached_prs and prs_cache_expiry and os.time() < prs_cache_expiry then
    return cached_prs
  end
  
  local token = ensure_token()
  if not token then
    vim.notify('Failed to get Azure token. Is az cli logged in?', vim.log.levels.ERROR)
    return nil
  end

  local organization, project, repo = get_azure_info()
  if not organization or not project or not repo then
    vim.notify('Failed to extract organization/project/repo from git remote URL', vim.log.levels.ERROR)
    return nil
  end
  
  local api_version = '7.1-preview.1'
  local url = string.format('https://dev.azure.com/%s/%s/_apis/git/repositories/%s/pullrequests?api-version=%s',
    organization, project, repo, api_version)
    
  local cmd = string.format('curl -s -H "Authorization: Bearer %s" "%s"', token, url)
  local handle = io.popen(cmd)
  
  if not handle then
    vim.notify('Failed to execute curl command', vim.log.levels.ERROR)
    return nil
  end

  local response = handle:read('*a')
  handle:close()

  -- Try to clean any BOM or whitespace
  response = response:gsub("^%s*", ""):gsub("^%z+", "")

  -- Parse JSON response
  local ok, parsed = pcall(vim.json.decode, response)
  if not ok then
    vim.notify('JSON parse error: ' .. tostring(parsed), vim.log.levels.ERROR)
    return nil
  end
  
  if not parsed.value then
    vim.notify('API response missing value field', vim.log.levels.ERROR)
    return nil
  end

  -- Cache the result
  cached_prs = parsed.value
  prs_cache_expiry = os.time() + PR_CACHE_DURATION
  
  return parsed.value
end

function M.fetch_first_change(pr)
  local token = ensure_token()
  if not token then return nil end

  local organization, project, repo = get_azure_info()
  if not organization or not project or not repo then return nil end

  -- First get the latest iteration
  local iteration_id = M.get_latest_iteration(pr)
  if not iteration_id then return nil end

  local url = string.format(
    'https://dev.azure.com/%s/%s/_apis/git/repositories/%s/pullRequests/%d/iterations/%d/changes?api-version=7.1',
    organization, project, repo, pr.pullRequestId, iteration_id
  )
  
  local cmd = string.format('curl -s -H "Authorization: Bearer %s" "%s"', token, url)
  local handle = io.popen(cmd)
  if not handle then return nil end
  
  local response = handle:read('*a')
  handle:close()

  -- Try to clean any BOM or whitespace
  response = response:gsub("^%s*", ""):gsub("^%z+", "")
  
  local ok, parsed = pcall(vim.json.decode, response)
  if not ok then
    vim.notify('Failed to parse changes response: ' .. tostring(parsed), vim.log.levels.ERROR)
    return nil
  end

  if not parsed.changeEntries or #parsed.changeEntries == 0 then
    vim.notify('No changes found', vim.log.levels.ERROR)
    return nil
  end

  local first_change = parsed.changeEntries[1]
  return {
    path = first_change.item.path,
    new_id = first_change.item.objectId and string.lower(first_change.item.objectId) or nil,
    old_id = first_change.item.originalObjectId and string.lower(first_change.item.originalObjectId) or nil
  }
end

function M.get_latest_iteration(pr)
  local token = ensure_token()
  if not token then return nil end

  local organization, project, repo = get_azure_info()
  if not organization or not project or not repo then return nil end

  local url = string.format(
    'https://dev.azure.com/%s/%s/_apis/git/repositories/%s/pullRequests/%d/iterations?api-version=7.1',
    organization, project, repo, pr.pullRequestId
  )
  
  local cmd = string.format('curl -s -H "Authorization: Bearer %s" "%s"', token, url)
  local handle = io.popen(cmd)
  if not handle then return nil end
  
  local response = handle:read('*a')
  handle:close()

  -- Try to clean any BOM or whitespace
  response = response:gsub("^%s*", ""):gsub("^%z+", "")
  
  local ok, parsed = pcall(vim.json.decode, response)
  if not ok then
    vim.notify('Failed to parse iterations response: ' .. tostring(parsed), vim.log.levels.ERROR)
    return nil
  end

  if not parsed.value or #parsed.value == 0 then
    vim.notify('No iterations found', vim.log.levels.ERROR)
    return nil
  end

  return parsed.value[#parsed.value].id
end

function M.fetch_file_content(path, ref)
  -- First ensure we have latest changes
  local fetch_cmd = 'git fetch origin'
  local handle = io.popen(fetch_cmd)
  if not handle then
    vim.notify('Failed to fetch from origin', vim.log.levels.ERROR)
    return nil
  end
  handle:close()

  -- Strip leading slash and get file content from the ref
  local git_path = path:gsub("^/", "")
  local cmd = string.format('git show %s:%s 2>/dev/null', ref, git_path)
  
  handle = io.popen(cmd)
  if not handle then
    vim.notify('Failed to get file content', vim.log.levels.ERROR)
    return nil
  end
  
  local content = handle:read('*a')
  handle:close()

  if content == "" then
    -- Don't show error for missing files - let the caller handle it
    return nil
  end

  return content
end

function M.get_threads(pr)
  local token = ensure_token()
  if not token then return nil end

  local organization, project, repo = get_azure_info()
  if not organization or not project or not repo then return nil end

  local url = string.format(
    'https://dev.azure.com/%s/%s/_apis/git/repositories/%s/pullRequests/%d/threads?api-version=7.1',
    organization, project, repo, pr.pullRequestId
  )
  
  local cmd = string.format('curl -s -H "Authorization: Bearer %s" "%s"', token, url)
  local handle = io.popen(cmd)
  if not handle then return nil end
  
  local response = handle:read('*a')
  handle:close()

  -- Try to clean any BOM or whitespace
  response = response:gsub("^%s*", ""):gsub("^%z+", "")
  
  local ok, parsed = pcall(vim.json.decode, response)
  if not ok then
    vim.notify('Failed to parse threads response: ' .. tostring(parsed), vim.log.levels.ERROR)
    return nil
  end

  if not parsed.value then
    return {}  -- No threads found, return empty array
  end

  -- Filter threads that have threadContext (code comments) and are not deleted
  local code_threads = {}
  for _, thread in ipairs(parsed.value) do
    -- Check if threadContext exists and is not vim.NIL (null in JSON)
    if thread.threadContext and
       type(thread.threadContext) == "table" and
       thread.threadContext.rightFileStart and
       not thread.isDeleted then
      table.insert(code_threads, thread)
    end
  end

  return code_threads
end

return M