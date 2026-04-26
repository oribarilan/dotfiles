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

  // In-memory state: idle | busy | attention
  // Priority: attention > busy > idle
  let currentState: "idle" | "busy" | "attention" = "idle"

  async function setState(newState: "idle" | "busy" | "attention", force = false): Promise<void> {
    if (!force) {
      // Don't let busy downgrade attention — only idle or attention itself can clear it
      if (newState === "busy" && currentState === "attention") return
      if (newState === currentState) return
    }
    currentState = newState

    const session = await getTmuxSession()
    if (!session) return
    try {
      if (newState === "idle") {
        // If user is in another session, mark as "done" (unread indicator)
        const activeSession = (await $`tmux display-message -p '#{client_session}'`.text()).trim()
        if (activeSession === session) {
          await $`tmux set -gu @agent_state_${session}`.quiet()
        } else {
          await $`tmux set -g @agent_state_${session} done`.quiet()
        }
      } else {
        await $`tmux set -g @agent_state_${session} ${newState}`.quiet()
      }
      await $`~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh`.quiet()
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

      // session.idle is a separate event from session.status
      if (event.type === "session.idle") {
        const props = (event as any).properties
        if (!childSessions.has(props.sessionID)) {
          await setState("idle")
        }
        return
      }

      // session.status fires for busy/retry transitions
      if (event.type === "session.status") {
        const props = (event as any).properties
        if (childSessions.has(props.sessionID)) return

        const statusType = props.status?.type
        if (statusType === "busy") {
          await setState("busy")
        } else if (statusType === "idle") {
          await setState("idle")
        }
        // "retry" — keep showing busy
        return
      }

      // Permission requested — needs user attention (any session, including sub-agents)
      if (event.type === "permission.asked" || event.type === "permission.updated") {
        await setState("attention")
        return
      }

      // Permission answered — back to busy
      if (event.type === "permission.replied") {
        await setState("busy", true)
        return
      }
    },

    // Question tool invoked — needs user attention
    "tool.execute.before": async (input) => {
      if (input.tool === "question") {
        await setState("attention")
      }
    },

    // Question tool answered — back to busy
    "tool.execute.after": async (input) => {
      if (input.tool === "question") {
        await setState("busy", true)
      }
    },
  }
}
