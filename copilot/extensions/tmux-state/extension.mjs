import { joinSession } from "@github/copilot-sdk/extension"
import { execSync } from "child_process"

// Resolve which tmux session we're in (cached for lifetime of extension)
const pane = process.env.TMUX_PANE

if (!pane) {
  // Not running inside tmux — register as no-op
  await joinSession({ tools: [], hooks: {} })
} else {
  let tmuxSession

  function getTmuxSession() {
    if (tmuxSession !== undefined) return tmuxSession
    try {
      const result = execSync(`tmux display-message -t ${pane} -p '#{session_name}'`, {
        timeout: 5000,
        encoding: "utf-8",
      })
      tmuxSession = result.trim()
      return tmuxSession
    } catch {
      return undefined
    }
  }

  // In-memory state: idle | busy | attention
  // Priority: attention > busy > idle
  //
  // Unlike OpenCode, Copilot CLI sub-agents run within the same session —
  // session.idle only fires when everything (including sub-agents) is done,
  // so no sub-agent filtering is needed.
  let currentState = "idle"

  function setState(newState, force = false) {
    if (!force) {
      // Don't let busy downgrade attention — only idle or attention itself can clear it
      if (newState === "busy" && currentState === "attention") return
      if (newState === currentState) return
    }
    currentState = newState

    const session = getTmuxSession()
    if (!session) return
    try {
      if (newState === "idle") {
        execSync(`tmux set -gu @agent_state_${session}`, { timeout: 5000, stdio: "ignore" })
      } else {
        execSync(`tmux set -g @agent_state_${session} ${newState}`, { timeout: 5000, stdio: "ignore" })
      }
      execSync(`~/.config/dotfiles/tmux/scripts/refresh-sessionbar.sh`, { timeout: 5000, stdio: "ignore" })
    } catch {
      // Silently ignore — don't break the extension if tmux commands fail
    }
  }

  const session = await joinSession({ tools: [], hooks: {} })

  // assistant.turn_start → busy
  session.on("assistant.turn_start", () => {
    setState("busy")
  })

  // tool.execution_start → busy
  // Force only when clearing attention (permission was just granted).
  // Normal priority rules handle the common case (already busy → no-op).
  session.on("tool.execution_start", () => {
    setState("busy", currentState === "attention")
  })

  // session.idle → idle
  session.on("session.idle", () => {
    setState("idle")
  })

  // permission.requested → attention
  session.on("permission.requested", () => {
    setState("attention")
  })

  // session.shutdown → clear variable
  session.on("session.shutdown", () => {
    const tmuxSess = getTmuxSession()
    if (!tmuxSess) return
    try {
      execSync(`tmux set -gu @agent_state_${tmuxSess}`, { timeout: 5000, stdio: "ignore" })
    } catch {
      // Silently ignore
    }
  })
}
