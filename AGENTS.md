# Agent Guidelines for Dotfiles Repository

## Overview
This is a personal dotfiles configuration repository for neovim, tmux, zsh, ghostty, yazi, raycast, and sesh.

## Testing
- **Neovim Tests**: Use neotest plugin
  - Run nearest test: `<leader>tn` or `:lua require('neotest').run.run()`
  - Run file tests: `<leader>tf` or `:lua require('neotest').run.run(vim.fn.expand '%')`
  - Debug test: `<leader>td` (uses DAP)
- **Manual Testing**: Use sample projects in `nvim/samples/` (python, dotnet)

## Code Style

### Lua (Neovim config)
- **Indentation**: 2 spaces (enforced by stylua)
- **Quotes**: Auto-prefer single quotes
- **Line width**: 160 characters
- **Call parentheses**: None (stylua config)
- **Formatter**: `stylua` - Format with `<leader>f`
- **Naming**: snake_case for functions/variables, PascalCase for classes
- **Requires**: Use single quotes, no parentheses: `require 'module'`
- **Plugin structure**: Return table with lazy.nvim spec, use `keys`/`config`/`opts` fields
- **Comments**: Use `--` for single line, document complex logic inline

### Shell Scripts (zsh, bash)
- **Indentation**: 2 spaces
- **Use local functions** where possible
- **Quote variables** to prevent word splitting

## LSP & Tooling
- **Python**: pyright (types only), ruff (linting/formatting/imports)
- **Lua**: lua_ls, stylua
- **C#/.NET**: roslyn
- **JSON/YAML/Markdown**: jsonls, yamlls, marksman + respective linters
