# OpenCode Status Indicator in Tmux Sessionbar

## Goal

Show a green dot (`●`) inside tmux session pills when OpenCode is actively working in that session. The dot appears instantly on state change and disappears when idle. No API port required — uses OpenCode's plugin hook system.

## Architecture

```
OpenCode plugin (event hook)
  │
  ├─ session.status → busy  ──► tmux set -g @oc_busy_<session> 1
  │                            ──► trigger sessionbar refresh
  │
  └─ session.status → idle  ──► tmux set -gu @oc_busy_<session>
                               ──► trigger sessionbar refresh

sessionbar.sh (per-session render loop)
  │
  └─ check @oc_busy_<session> ──► if set, prepend green ● before name
```

## Components

### 1. OpenCode Plugin: `opencode/plugins/tmux-status.ts`

A new plugin file alongside the existing `copilot-1m.ts`.

**Responsibilities:**
- Hook into `event` — listen for `session.status` events
- On `busy`: set tmux global variable `@oc_busy_<tmux_session_name>` to `1`
- On `idle`: unset the variable with `tmux set -gu`
- After each state change, trigger a sessionbar refresh by running:
  ```bash
  tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)" && tmux refresh-client -S
  ```

**Tmux session detection:**
- Read `$TMUX_PANE` from the environment (inherited by the OpenCode process)
- Query `tmux display-message -t $TMUX_PANE -p '#{session_name}'` to resolve the tmux session name
- Cache the session name on first lookup (it won't change during the process lifetime)

**Sub-agent filtering:**
- OpenCode spawns child sessions (sub-agents) that emit their own `session.status` events
- The plugin should only track the root session's status — the root stays `busy` while any child is working, and transitions to `idle` only when everything is done
- Filter by checking that the event's session has no `parentID`

**Edge cases:**
- If `$TMUX_PANE` is not set (opencode running outside tmux), the plugin is a no-op
- If the tmux command fails, silently skip (don't break opencode)
- If multiple opencode instances run in the same tmux session (different panes), the variable reflects the union — any busy instance keeps it set. This is acceptable for v1.

### 2. Sessionbar Script: `tmux/scripts/sessionbar.sh`

Modify the per-session rendering loop (lines 30-50) to check for the status variable.

**Logic per session:**
```bash
oc_busy=$(tmux show-option -gqv "@oc_busy_${session}")
if [ -n "$oc_busy" ]; then
  dot="● "
else
  dot=""
fi
```

**Active pill with dot:**
```
[ 1  ● dotfiles ]
      ↑ green (#a6e3a1) dot, then session name in mauve
```

The dot is rendered in `#a6e3a1` (Catppuccin Mocha green) on the same background as the session name segment:
- Active pill: green dot on `#cba6f7` (mauve) background
- Inactive pill: green dot on `#9399b2` (overlay) background

**Active pill format (with dot):**
```
#[fg=#a6e3a1,bg=#cba6f7,bold]●#[fg=#11111b,bg=#cba6f7,bold] session_name
```

**Inactive pill format (with dot):**

The inactive pill is a single segment with index and name together. The dot goes between the index and the session name:
```
#[fg=#11111b,bg=#9399b2] idx #[fg=#a6e3a1,bg=#9399b2]● #[fg=#11111b,bg=#9399b2]session_name
```
Renders as: `[ 1 ● dotfiles ]`

### 3. Stale State Cleanup: `tmux/status.conf`

Add a `pane-exited` hook that clears any `@oc_busy_` variable for the session the pane belonged to. This handles the case where opencode crashes or is killed without triggering its idle event.

```tmux
set-hook -g pane-exited "run-shell 'tmux set -gu @oc_busy_#{session_name} 2>/dev/null; $SESSIONBAR_CMD'"
```

This hook fires when any pane exits, not just opencode panes. The `set -gu` (unset global) is a no-op if the variable doesn't exist, so it's safe to run unconditionally.

## Files Changed

| File | Change |
|------|--------|
| `opencode/plugins/tmux-status.ts` | **New** — OpenCode plugin that pushes state to tmux variables |
| `tmux/scripts/sessionbar.sh` | **Modified** — read `@oc_busy_` per session, render dot if set |
| `tmux/status.conf` | **Modified** — add `pane-exited` hook for cleanup |

## What Doesn't Change

- Session ordering, navigation, colors, pill shape — all unchanged
- `status-interval` stays at 10 seconds
- Right-side stats (CPU/memory/disk) unaffected
- No new dependencies, no API port needed

## Future Extensions (Not in V1)

- **Animated pulse**: alternate `●`/`○` while busy (~1s interval via plugin-driven timer)
- **Question tool indicator**: show `?` or `❓` when opencode is waiting for user input via the question tool (hook `tool.execute.before` where `input.tool === "question"`)
- **Copilot CLI support**: detect copilot-cli state (would need a different detection mechanism)
- **Error state**: show red dot on `session.error` events
