# Agent Review — Design Spec

## Overview

A neovim script that enables hunk-by-hunk review of external file changes
(e.g. from coding agents running in a separate terminal). Built on top of
mini.diff for visualization and hunk management.

**Scope**: Git repositories only. The plugin is completely inert (no
autocommands, no keymaps, no UI) when the working directory is not inside
a git repo.

---

## Core Mechanism

Uses `git stash create` as a read-only snapshot of the working tree. This
creates a commit object without modifying the index or working tree — zero
side effects on git state.

### Snapshot Lifecycle

```
FocusLost
  ├── git stash create → M._snapshot.ref (SHA, in-memory)
  └── git ls-files --others --exclude-standard → M._snapshot.untracked

FocusGained
  ├── git diff <ref> --name-only → changed tracked files
  ├── git ls-files --others --exclude-standard → diff with snapshot → new files
  ├── Open buffers: mark for review, checktime reloads them
  ├── Unopened files: store in M._pending_files
  ├── Populate quickfix list with all changes
  └── checktime triggers FileChangedShellPost per reloaded buffer

Review complete (last buffer exits review)
  └── git add -A (stage approved state, respects .gitignore)
```

### In-Memory State

```lua
M._snapshot = {
  ref = 'abc123...',                  -- git stash create output (or 'HEAD' if clean)
  untracked = { 'file_c.py', ... },  -- untracked non-ignored files at FocusLost
}

M._changed_files = { '/abs/path/file_a.py', ... }  -- detected on FocusGained
M._pending_files = { '/abs/path/file_b.py', ... }  -- changed but not yet opened
M._new_files = { '/abs/path/file_c.py', ... }       -- agent-created untracked files

M._reviews = {
  [buf_id] = { ref_text = '...', original_ref = '...' },
}
```

The snapshot ref is overwritten on each FocusLost. If any reviews are
active, FocusLost is a no-op (don't overwrite the snapshot mid-review).

---

## Detection Flow

### FocusLost

1. If any reviews are active → skip (don't overwrite snapshot mid-review)
2. Check if in a git repo (`git rev-parse --show-toplevel`) → skip if not
3. `git stash create` → store ref (empty output = clean tree, use `HEAD`)
4. `git ls-files --others --exclude-standard` → store untracked list

### FocusGained

1. If no snapshot ref → skip
2. `git diff <ref> --name-only` → list of changed tracked files
3. `git ls-files --others --exclude-standard` → compare with snapshot
   untracked list → newly appeared files = agent-created
4. Resolve all paths to absolute (prepend git root from `git rev-parse --show-toplevel`)
5. For each changed tracked file:
   - If buffer is loaded → add to `M._changed_files` (review starts on FileChangedShellPost)
   - If buffer is not loaded → add to `M._pending_files`
6. For each new untracked file → add to `M._new_files`
7. Populate quickfix list
8. Run `checktime` (triggers reload of open buffers that changed)

### FileChangedShellPost

1. If the reloaded buffer's file is in `M._changed_files`:
   - Reference content = `git show <ref>:<repo-relative-path>`
   - Start review mode
   - Remove from `M._changed_files`

### BufReadPost (opening a new file)

1. If the opened file is in `M._pending_files`:
   - Reference content = `git show <ref>:<repo-relative-path>`
   - Start review mode
   - Remove from `M._pending_files`

---

## Review Mode

When review mode starts for a buffer:

1. Set reference text via `MiniDiff.set_ref_text(buf_id, ref_content)`
   where `ref_content` comes from `git show <ref>:path`
2. Enable mini.diff overlay (`MiniDiff.toggle_overlay`)
3. Jump to first hunk (`MiniDiff.goto_hunk('first')`)
4. Set buffer-local keymaps
5. Place virtual text hints at each hunk
6. Update quickfix list

### Keybindings (buffer-local, only during review)

| Key          | Action                          |
|--------------|---------------------------------|
| `<leader>ra` | Approve hunk (keep the change)  |
| `<leader>rr` | Reject hunk (revert to old)     |
| `<leader>rA` | Approve all remaining hunks     |
| `<leader>rR` | Reject all remaining hunks      |
| `<leader>rq` | Quit review mode                |
| `]h` / `[h`  | Navigate hunks (mini.diff)      |

### Approve Hunk

Updates the reference text to include the approved change (makes reference
match buffer for that hunk region). The hunk disappears from the diff.
Remaining hunks re-index. Hints update.

### Reject Hunk

Calls `MiniDiff.do_hunks(buf_id, 'reset', ...)` which replaces buffer text
with reference text for that region. The hunk disappears. Remaining hunks
re-index. Hints update.

### Finish Review

When all hunks are reviewed (or user quits):

1. Turn off overlay
2. Restore mini.diff to normal git source (re-enable)
3. Save the file if modified
4. Clear keymaps and virtual text hints
5. Remove buffer from `M._reviews`
6. If this was the last active review:
   - Run `git add -A` to stage the approved state
   - Close quickfix window

---

## Virtual Text Hints

Each hunk gets an inline virtual text annotation at end-of-line on the first
line of the hunk:

```
[1/3] <leader>ra approve | <leader>rr reject | <leader>rq quit
```

The first hunk additionally shows bulk actions when there are multiple hunks:

```
[1/3] <leader>ra approve | <leader>rr reject | <leader>rA all | <leader>rR reject all | <leader>rq quit
```

Hints are:
- Placed via extmarks in a dedicated namespace
- Styled with distinct highlight groups (keys bold/yellow, labels italic/blue, separators dim)
- Updated after every approve/reject (count updates, resolved hunks disappear)
- Cleared when review ends

---

## Quickfix List

On FocusGained, a quickfix list titled "Agent Review" is populated with all
detected changes:

```
file_a.py|42| [~] 3 line(s)
file_a.py|78| [+] 5 line(s)
file_b.py|12| [-] 2 line(s)          ← pending (file not yet opened)
file_c.py|1|  [new file]             ← agent-created, untracked
```

- Tracked file entries include hunk type (`+` add, `~` change, `-` delete)
  and line count
- New untracked files appear as `[new file]` — these are files that appeared
  in `git ls-files --others --exclude-standard` between FocusLost and
  FocusGained
- The list updates as hunks are approved/rejected
- The quickfix window auto-closes when all reviews are finished
- Navigate with `:cnext`/`:cprev` or whatever quickfix bindings are configured

---

## Path Resolution

Git commands output paths relative to the repo root. Buffer names are
absolute paths. Conversion:

```lua
local git_root = vim.fn.system('git rev-parse --show-toplevel'):gsub('\n', '')
-- git path → absolute: git_root .. '/' .. git_relative_path
-- absolute → git path: path:sub(#git_root + 2)
```

The git root is resolved once on first use and cached.

---

## Edge Cases

| Case | Behavior |
|------|----------|
| Clean tree at FocusLost | `git stash create` returns empty → use `HEAD` as ref |
| Rapid alt-tab (no agent) | `git diff <ref>` returns nothing → no review triggered |
| Agent deletes a file | Appears in `git diff` → quickfix entry noting deletion |
| Alt-tab during active review | FocusLost is a no-op (don't overwrite snapshot) |
| Not a git repo | Plugin is completely disabled, no autocommands registered |
| File in `.gitignore` | Not detected by any of the git commands → ignored |
| Unsaved buffer at FocusLost | `git stash create` captures disk state; unsaved content is lost on checktime reload regardless |
| Agent modifies file already in review | Skipped — review is already active for that buffer |

---

## Git Commands Reference

All commands are run synchronously. All are fast (<100ms typical).

| Command | When | Purpose |
|---------|------|---------|
| `git rev-parse --show-toplevel` | Once, cached | Get repo root for path resolution |
| `git stash create` | FocusLost | Read-only snapshot of working tree |
| `git diff <ref> --name-only` | FocusGained | Detect changed tracked files |
| `git ls-files --others --exclude-standard` | FocusLost + FocusGained | Detect new untracked files |
| `git show <ref>:<path>` | Review start per-file | Get "before" content for reference |
| `git add -A` | Last review finishes | Stage approved state |

---

## Requirements

### tmux

Auto-detection via FocusLost/FocusGained requires `focus-events` in tmux:

```tmux
set -g focus-events on
```

Without this, focus events are not forwarded to Neovim and auto-detection
will not work. The manual trigger (`:AgentReview` / `<leader>rn`) works
regardless.

### Manual Trigger

`:AgentReview` (or `<leader>rn`) performs snapshot + detect in one step.
Use this when:

- focus-events are not available
- The agent runs in a tmux pane (no focus change)
- You want to explicitly control when detection happens

If no prior snapshot exists, diffs against `HEAD`.

### Mid-Review Protection

Buffers in active review have `autoread` disabled to prevent Neovim from
reloading them if the agent makes further changes while you're reviewing.
The original `autoread` value is restored when review ends.

---

## File Structure

```
nvim/lua/scripts/agent-review.lua   -- the plugin
nvim/lua/scripts/agent-review-spec.md -- this spec
nvim/lua/plugins/whichkey.lua        -- <leader>r group registered
nvim/init.lua                        -- checktime/FileChangedShellPost moved to agent-review.lua
```
