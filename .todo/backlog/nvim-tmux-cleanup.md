# nvim-tmux-cleanup

## Context
Accumulated stale/duplicate code across nvim and tmux configs after 623 commits.

**Value delivered**: Cleaner, non-conflicting configs with accurate documentation.

## Related Files
- `nvim/lua/vim-options.lua` (lines ~100-135, duplicate LSP highlight)
- `nvim/lua/plugins/lsp-config.lua` (lines ~148-167, Kickstart highlight boilerplate + ~50 lines of educational comments)
- `tmux/.tmux.conf` (lines 38-41 dead pane select binds, line 58+82 duplicate kill-pane)
- `README.md` (TODOs listing flash.nvim and surround.nvim as missing — both exist)

## Dependencies
- None

## Acceptance Criteria
- [ ] Remove duplicate LSP document_highlight — keep one approach (CursorHold or CursorMoved), delete the other
- [ ] Remove stale Kickstart educational comments from `lsp-config.lua` (~50 lines of "what is LSP?" prose)
- [ ] Remove dead `bind-key h/j/k/l select-pane` lines in tmux (vim-tmux-navigator handles this)
- [ ] Remove duplicate `bind-key x kill-pane` in tmux (lines 58 and 82)
- [ ] Update README TODOs — mark flash.nvim and surround.nvim as done or remove from TODO list

## Verification
- **Ad-hoc**: Open nvim, confirm LSP highlighting still works on a file with an LSP server
- **Ad-hoc**: Open tmux, confirm `C-h/j/k/l` navigation and `prefix+x` kill-pane still work
- **Ad-hoc**: Check README no longer lists implemented features as TODO

## Notes
- For the LSP highlight decision: CursorHold (Kickstart) triggers after idle delay, CursorMoved triggers on every cursor move. CursorHold is more standard and less noisy — likely the one to keep.
