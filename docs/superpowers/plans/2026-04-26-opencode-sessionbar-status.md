# OpenCode Sessionbar Status Indicator — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a green dot (●) in tmux session pills when OpenCode is actively working in that session.

**Architecture:** An OpenCode plugin listens for `session.status` events and pushes state into tmux global variables (`@oc_busy_<session>`). The sessionbar script reads those variables when rendering pills and prepends a green dot if set. A pane-exited tmux hook cleans up stale state.

**Tech Stack:** TypeScript (OpenCode plugin), Bash (tmux sessionbar script), tmux config

**Spec:** `docs/superpowers/specs/2026-04-26-opencode-sessionbar-status-design.md`

---

### Task 1: Create the OpenCode plugin

**Files:**
- Create: `opencode/plugins/tmux-status.ts`

This plugin hooks into OpenCode's event system (see https://opencode.ai/docs/plugins) to detect busy/idle state and push it to tmux variables.

**Reference — OpenCode plugin API:**
- Plugin signature: `export const X: Plugin = async ({ $, client, project, directory, worktree }) => { return { ... } }`
- `$` is Bun's shell API (see https://bun.sh/docs/runtime/shell) — tagged template literal for running commands
- The `event` hook receives `{ event }` where `event` is a discriminated union with a `type` field
- `session.status` event shape: `{ type: "session.status", properties: { sessionID: string, status: { type: "idle" } | { type: "busy" } | { type: "retry", ... } } }`
- `session.created` event shape: `{ type: "session.created", properties: { info: { id: string, parentID?: string, ... } } }`
- Sessions with `parentID` set are sub-agent child sessions

**Reference — Tmux session detection:**
- `process.env.TMUX_PANE` contains the pane ID (e.g., `%5`) when running inside tmux
- `tmux display-message -t <pane> -p '#{session_name}'` resolves pane → tmux session name
- The tmux session name won't change during the plugin's lifetime, so cache it on first lookup

- [ ] **Step 1: Create the plugin file**

Create `opencode/plugins/tmux-status.ts`:

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const TmuxStatus: Plugin = async ({ $ }) => {
  // Resolve which tmux session we're in (cached for lifetime of plugin)
  const pane = process.env.TMUX_PANE
  if (!pane) return {} // Not running inside tmux — no-op

  let tmuxSession: string | undefined
  async function getTmuxSession(): Promise<string | undefined> {
    if (tmuxSession !== undefined) return tmuxSession
    try {
      const result = await $`tmux display-message -t ${pane} -p '#{session_name}'`.text()
      tmuxSession = result.trim()
      return tmuxSession
    } catch {
      return undefined
    }
  }

  // Track child session IDs so we only act on root session status changes
  const childSessions = new Set<string>()

  async function setTmuxState(busy: boolean): Promise<void> {
    const session = await getTmuxSession()
    if (!session) return
    try {
      if (busy) {
        await $`tmux set -g @oc_busy_${session} 1`.quiet()
      } else {
        await $`tmux set -gu @oc_busy_${session}`.quiet()
      }
      // Trigger sessionbar refresh
      await $`tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)" && tmux refresh-client -S`.quiet()
    } catch {
      // Silently ignore — don't break opencode if tmux commands fail
    }
  }

  return {
    event: async ({ event }) => {
      // Track child sessions so we can filter them out of status events
      if (event.type === "session.created") {
        const info = (event as any).properties?.info
        if (info?.parentID) {
          childSessions.add(info.id)
        }
        return
      }

      // Only react to root session status changes
      if (event.type === "session.status") {
        const props = (event as any).properties
        if (childSessions.has(props.sessionID)) return

        const statusType = props.status?.type
        if (statusType === "busy") {
          await setTmuxState(true)
        } else if (statusType === "idle") {
          await setTmuxState(false)
        }
        // "retry" — keep showing busy (agent is retrying, still working)
      }
    },
  }
}
```

- [ ] **Step 2: Verify the plugin loads**

Start opencode in a tmux session. Check the logs for any plugin loading errors:

```bash
oc
# Then check: ~/.local/share/opencode/log/ for recent errors mentioning "tmux-status" or "plugin"
```

The plugin should load silently. If `$TMUX_PANE` is set (you're in tmux), it will resolve the session name on first event.

- [ ] **Step 3: Commit**

```bash
git add opencode/plugins/tmux-status.ts
git commit -m "Add opencode plugin to push busy/idle state to tmux variables"
```

---

### Task 2: Modify sessionbar to render the status dot

**Files:**
- Modify: `tmux/scripts/sessionbar.sh` (lines 30-49 — the rendering loop)

Add a per-session check for the `@oc_busy_<session>` tmux variable. If set, prepend a green `●` in the name segment of the pill.

**Reference — Catppuccin Mocha palette:**
- Green: `#a6e3a1`
- Mauve (active name bg): `#cba6f7`
- Overlay (inactive bg): `#9399b2`
- Dark text: `#11111b`

- [ ] **Step 1: Add status variable lookup to the render loop**

In `tmux/scripts/sessionbar.sh`, inside the `while` loop (after `idx=$((idx + 1))` on line 34), add the variable lookup before the `if` block:

Replace lines 36-48 (the entire if/else block) with:

```bash
  # Check if opencode is busy in this session
  oc_busy=$(tmux show-option -gqv "@oc_busy_${session}")

  if [ "$session" = "$current" ]; then
    # Active: grey index | mauve name (with optional green dot)
    printf "#[fg=#9399b2,bg=#181825]"
    printf "#[fg=#11111b,bg=#9399b2] %s " "$idx"
    printf "#[fg=#cba6f7,bg=#9399b2]"
    if [ -n "$oc_busy" ]; then
      printf "#[fg=#a6e3a1,bg=#cba6f7,bold]● #[fg=#11111b,bg=#cba6f7,bold]%s " "$session"
    else
      printf "#[fg=#11111b,bg=#cba6f7,bold] %s " "$session"
    fi
    printf "#[fg=#cba6f7,bg=#181825,nobold]"
  else
    # Inactive: grey pill (with optional green dot)
    printf "#[fg=#9399b2,bg=#181825]"
    if [ -n "$oc_busy" ]; then
      printf "#[fg=#11111b,bg=#9399b2] %s #[fg=#a6e3a1,bg=#9399b2]● #[fg=#11111b,bg=#9399b2]%s " "$idx" "$session"
    else
      printf "#[fg=#11111b,bg=#9399b2] %s  %s " "$idx" "$session"
    fi
    printf "#[fg=#9399b2,bg=#181825]"
  fi
```

- [ ] **Step 2: Manually test the sessionbar rendering**

Set a fake variable and reload the sessionbar to verify rendering:

```bash
# Set a fake busy state for the current session
tmux set -g @oc_busy_$(tmux display-message -p '#{session_name}') 1

# Re-render the sessionbar
tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)" && tmux refresh-client -S

# You should see a green ● before the session name in the active pill

# Clear the fake state
tmux set -gu @oc_busy_$(tmux display-message -p '#{session_name}')
tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)" && tmux refresh-client -S

# The dot should disappear
```

- [ ] **Step 3: Commit**

```bash
git add tmux/scripts/sessionbar.sh
git commit -m "Show green dot in session pill when opencode is busy"
```

---

### Task 3: Add pane-exited cleanup hook

**Files:**
- Modify: `tmux/status.conf` (add hook after line 46)

When a pane exits (e.g., opencode is killed or crashes), clear the `@oc_busy_` variable for that session and refresh the sessionbar. This prevents stale dots from lingering.

- [ ] **Step 1: Add the pane-exited hook**

In `tmux/status.conf`, after line 46 (`set-hook -g session-renamed ...`), add:

```tmux
set-hook -g pane-exited         "run-shell 'tmux set -gu @oc_busy_#{session_name} 2>/dev/null; $SESSIONBAR_CMD'"
```

This fires when any pane exits. `tmux set -gu` (unset global) is a no-op if the variable doesn't exist, so it's safe to run for all pane exits.

**Note:** `#{session_name}` is expanded by tmux at hook-fire time to the session that the exiting pane belonged to.

- [ ] **Step 2: Test the cleanup hook**

```bash
# Reload tmux config
tmux source-file ~/.config/dotfiles/tmux/tmux.conf

# Set a fake busy state
tmux set -g @oc_busy_$(tmux display-message -p '#{session_name}') 1
tmux set -g @sessionbar "$(~/.config/dotfiles/tmux/scripts/sessionbar.sh)" && tmux refresh-client -S

# Verify the dot appears

# Split a pane and immediately close it to trigger pane-exited
tmux split-window -h && sleep 0.5 && tmux send-keys exit Enter

# After the pane exits, the dot should disappear (hook clears the variable and refreshes)
```

- [ ] **Step 3: Commit**

```bash
git add tmux/status.conf
git commit -m "Add pane-exited hook to clean up stale opencode status indicators"
```

---

### Task 4: End-to-end manual test

No files changed — this is a verification step.

- [ ] **Step 1: Reload tmux config**

```bash
tmux source-file ~/.config/dotfiles/tmux/tmux.conf
```

- [ ] **Step 2: Start opencode in a tmux session**

```bash
oc
```

- [ ] **Step 3: Send a prompt and observe**

Send any prompt (e.g., "hello"). Watch the session pill — a green `●` should appear when the agent starts working and disappear when it finishes.

- [ ] **Step 4: Verify other sessions are unaffected**

Switch to another tmux session (`Alt+.`). That session's pill should have no dot (unless it also has opencode running).

- [ ] **Step 5: Test crash cleanup**

In a session with opencode running, kill the opencode process (`Ctrl+C` or `kill`). The pane-exited hook should fire and clear the dot.
