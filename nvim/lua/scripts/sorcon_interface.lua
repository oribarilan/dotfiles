-- Interface definition for Sorcon backend
local M = {}

---@class SorconBackend
---@field fetch_prs function(): table[] # Fetches pull requests
---@field fetch_first_change function(pr: table): table # Fetches first change for a PR
---@field fetch_file_content function(path: string, ref: string): string # Fetches file content at ref
---@field get_latest_iteration function(pr: table): number # Gets latest iteration ID for a PR
---@field get_threads function(pr: table): table[] # Gets comment threads for a PR

return M