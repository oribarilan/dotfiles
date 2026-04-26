# Agent Status in Tmux Sessionbar

The sessionbar shows live status icons inside session pills when a coding agent (OpenCode, Copilot CLI) is running in that session.

## Specification

### States

| State | Icon | Color | Meaning |
|-------|------|-------|---------|
| Idle | _(none)_ | — | No agent running, or agent is waiting for user prompt |
| Busy | `●` | Green (`#a6e3a1`) | Agent is actively working |
| Attention | `󰂞` | Yellow (`#f9e2af`) | Agent is blocked on user input (permission or question) |

### Priority

Attention > Busy > Idle. When both busy and waiting for input, show attention.

### Behavior

- Icon appears inside the session pill, before the session name
- State changes are instant (event-driven, not polled)
- When the agent finishes, the icon disappears
- When the agent asks a question or requests a permission, the bell replaces the busy dot
- After answering, the icon returns to busy (agent continues working)
- If the agent process crashes, stale icons are cleaned up via tmux `pane-exited` hook

### Integration contract

Each agent harness pushes state into a tmux global variable per session:

```
@agent_state_<tmux_session_name>   →  "busy" | "attention" | (unset = idle)
```

The sessionbar reads this variable — it doesn't know or care which agent set it.

To add a new agent: write a plugin/script that sets this variable on state transitions and calls `~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh` to trigger a re-render.

---

## OpenCode Harness

**Implementation:** `opencode/plugins/tmux-status.ts` — an OpenCode plugin using the hook system ([docs](https://opencode.ai/docs/plugins)).

**How it detects state:**
- `session.status` / `session.idle` events → busy / idle
- `permission.asked` event → attention
- `permission.replied` event → back to busy
- `tool.execute.before` / `tool.execute.after` (question tool) → attention / back to busy

**How it finds the tmux session:** reads `$TMUX_PANE` env var, queries tmux for the session name, caches it.

**Sub-agent filtering:** tracks child session IDs via `session.created` events. Only root session status changes affect the busy/idle state. Attention events (permissions, questions) are shown regardless of which session triggered them.

---

## Copilot CLI Harness

**Implementation:** `copilot/extensions/tmux-state/extension.mjs` — a Copilot CLI extension using the SDK ([docs](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-cli-plugins)).

**How it detects state:**
- `assistant.turn_start` / `tool.execution_start` events → busy
- `session.idle` event → idle
- `permission.requested` event → attention
- `session.shutdown` event → cleanup (unset variable)

**How it finds the tmux session:** reads `$TMUX_PANE` env var, queries tmux for the session name, caches it.

**Sub-agent filtering:** Not needed. Unlike OpenCode (where sub-agents are child sessions), Copilot CLI sub-agents run within the same session. `session.idle` only fires when everything — including sub-agents — is done.

**Setup:** symlink `~/.copilot/extensions/tmux-state` → `~/.config/dotfiles/copilot/extensions/tmux-state`

---

## Sessionbar rendering

`tmux/scripts/sessionbar.sh` reads `@agent_state_<session>` per pill and renders the appropriate icon/color. `tmux/scripts/refresh-sessionbar.sh` is the single entry point for re-rendering (called by tmux hooks, agent plugins, and `session-order.sh`).

`tmux/status.conf` includes a `pane-exited` hook that clears the state variable when no `opencode` or `copilot` process remains in the session.
