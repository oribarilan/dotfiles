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
