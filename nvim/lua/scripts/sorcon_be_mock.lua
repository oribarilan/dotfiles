local M = {}

-- Mock data formatted as if from README.md
local mock_data = {
  prs = {
    {
      pullRequestId = 1234,
      title = "Update project documentation",
      createdBy = { displayName = "John Doe" },
      creationDate = "2025-05-24T10:30:00Z",
      sourceRefName = "refs/heads/feature/docs",
      targetRefName = "refs/heads/main",
      url = "https://dev.azure.com/mock/project/_git/repo/pullrequest/1234"
    },
    {
      pullRequestId = 1235,
      title = "Fix README formatting",
      createdBy = { displayName = "Jane Smith" },
      creationDate = "2025-05-24T11:00:00Z",
      sourceRefName = "refs/heads/bugfix/docs",
      targetRefName = "refs/heads/main",
      url = "https://dev.azure.com/mock/project/_git/repo/pullrequest/1235"
    }
  },
  changes = {
    path = "README.md",
    new_id = "abc123",
    old_id = "def456"
  },
  threads = {
    {
      id = 1,
      status = "active",
      threadContext = {
        filePath = "README.md",
        rightFileStart = { line = 4 }, -- Points to Description section
        rightFileEnd = { line = 4 }
      },
      comments = {
        {
          id = 1,
          content = "Could you expand this section with more details?",
          author = { displayName = "Jane Smith" },
          createdDate = "2025-05-24T11:00:00Z"
        },
        {
          id = 2,
          content = "Sure, I'll add more information about the project's goals.",
          author = { displayName = "John Doe" },
          createdDate = "2025-05-24T11:05:00Z"
        }
      }
    }
  },
  pr_content = [[# Project Title

## Description
An awesome project that does amazing things.

## Installation
```bash
npm install my-project
```

## Usage
```javascript
const myProject = require('my-project');
myProject.doAwesome();
```

## Contributing
PRs are welcome! Please read our contributing guidelines.

## License
MIT]]
}

-- Helper to read local file content
local function read_local_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

function M.fetch_prs()
  return mock_data.prs
end

function M.fetch_first_change(_)
  return mock_data.changes
end

function M.get_latest_iteration(_)
  return 1
end

function M.get_threads(_)
  return mock_data.threads
end

function M.fetch_file_content(path, ref)
  -- For mock PR content (source branch)
  if ref:match("feature/") or ref:match("bugfix/") then
    return mock_data.pr_content
  end
  
  -- For main branch, read the actual local file
  path = path:gsub("^/", "") -- Remove leading slash if present
  local content = read_local_file(path)
  if not content then
    -- Fallback to empty content if file doesn't exist
    return "# Empty File\n\nThis file does not exist in the local repository."
  end
  return content
end

return M