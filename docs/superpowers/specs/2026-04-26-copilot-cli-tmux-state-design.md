# Copilot CLI Tmux State Extension

Extends the agent-status sessionbar feature to Copilot CLI. When Copilot CLI is running in a tmux session, its state (busy/idle/attention) is shown as an icon inside the session pill — same visual treatment as OpenCode.

## Integration Contract

Same contract as OpenCode (defined in `tmux/agent-status.md`):

- Set tmux global variable `@agent_state_<session_name>` → `"busy"` | `"attention"` | unset (idle)
- Call `~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh` after each state change
- Sessionbar reads the variable and renders the icon — it doesn't know which agent set it

## Architecture

Single file: `copilot/extensions/tmux-state/extension.mjs`

Uses `@github/copilot-sdk/extension` (auto-resolved by Copilot CLI runtime, no npm install needed). The extension is user-scoped — it lives in `~/.copilot/extensions/` and applies to all Copilot CLI sessions regardless of project.

Symlink: `~/.copilot/extensions/tmux-state` → `~/.config/dotfiles/copilot/extensions/tmux-state`

## State Machine

Three states with priority: **attention > busy > idle**.

| Copilot CLI Event | State | Scope |
|---|---|---|
| `assistant.turn_start` | busy | Root session only |
| `tool.execution_start` | busy | Root session only |
| `session.idle` | idle | Root session only |
| `permission.requested` | attention | Any session (bubbles up from sub-agents) |
| `session.shutdown` | clear (unset variable) | Always |

### Priority rules

- `busy` cannot overwrite `attention` — prevents a sub-agent's busy event from hiding a pending permission prompt
- Only `idle` or the agent resuming work (next `assistant.turn_start` / `tool.execution_start` after permission is granted) clears attention
- When attention is cleared by resumed work, it transitions to `busy` with a force flag

### Sub-agent filtering

The `subagentStart` hook captures child session IDs into a `Set`. Busy/idle events check whether the event's session ID is in this set and ignore children. Attention events (permission requests) are surfaced regardless of source — the user needs to see them no matter which session triggered them.

## Tmux Session Resolution

Same approach as OpenCode plugin:

1. Read `$TMUX_PANE` env var at startup
2. Query tmux for the session name: `tmux display-message -t $TMUX_PANE -p '#{session_name}'`
3. Cache the result for the lifetime of the extension process

If `$TMUX_PANE` is not set (not running inside tmux), the extension is a no-op.

## Changes to Existing Files

### `tmux/status.conf` (line 47)

The `pane-exited` hook currently only checks for `opencode` processes. Add `copilot` to the grep so stale state is cleaned up when either agent exits:

```
Before: grep -qx opencode
After:  grep -qxE 'opencode|copilot'
```

### `tmux/agent-status.md`

Replace the "Copilot CLI Harness" section (currently "_Not yet implemented._") with documentation of the extension: file location, event mapping, symlink setup.

## File Layout

```
copilot/
└── extensions/
    └── tmux-state/
        └── extension.mjs
```
