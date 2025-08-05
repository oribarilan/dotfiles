-- LSP diagnostic script for testing Roslyn
-- Run this in Neovim with :luafile test-lsp.lua

print("=== LSP Diagnostic Report ===")
print()

-- Check if roslyn.nvim is loaded
local roslyn_ok, roslyn = pcall(require, "roslyn")
if roslyn_ok then
    print("✅ roslyn.nvim plugin is loaded")
else
    print("❌ roslyn.nvim plugin failed to load:", roslyn)
end

print()

-- Check active LSP clients
local clients = vim.lsp.get_active_clients()
print("Active LSP clients:", #clients)
for _, client in ipairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
    if client.name:match("roslyn") then
        print("    ✅ Roslyn client found!")
        print("    Server capabilities:")
        local caps = client.server_capabilities
        if caps then
            print("      - references:", caps.referencesProvider or false)
            print("      - definition:", caps.definitionProvider or false)
            print("      - hover:", caps.hoverProvider or false)
            print("      - completion:", caps.completionProvider and true or false)
        end
    end
end

print()

-- Check buffer filetype
local ft = vim.bo.filetype
print("Current buffer filetype:", ft)

if ft == "cs" then
    print("✅ C# filetype detected")
else
    print("❌ Expected 'cs' filetype for C# files")
end

print()

-- Check for .csproj file
local csproj_files = vim.fn.glob("*.csproj", false, true)
if #csproj_files > 0 then
    print("✅ Found .csproj files:", table.concat(csproj_files, ", "))
else
    print("⚠️  No .csproj files found in current directory")
end

print()
print("=== Recommendations ===")
print("1. Make sure you're in the test-csharp directory")
print("2. Open Program.cs: :e Program.cs")
print("3. Check LSP status: :LspInfo")
print("4. Restart LSP if needed: :LspRestart")
print("5. Check for errors: :messages")