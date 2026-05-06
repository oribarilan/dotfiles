# `agents/` — shared agent config

Tool-neutral home for instructions and skills shared across opencode and
GitHub Copilot CLI. Both tools point here so a single edit affects both.

## Contents

- `AGENTS.md` — global instructions loaded into every session.
- `skills/` — `SKILL.md` definitions discovered by both tools.
  `opencode/skills` is a symlink to this directory.

## How each tool loads it

- **opencode**: `opencode/opencode.jsonc` lists `AGENTS.md` in its
  `instructions` array (absolute path; relative paths silently don't
  resolve). Skills are auto-discovered through the `opencode/skills`
  symlink.
- **copilot**: `copilot/copilot-instructions.md` is a symlink to
  `AGENTS.md`, auto-loaded from `COPILOT_HOME`. Skills are picked up via
  `skillDirectories` in `copilot/settings.json`.

See `../README.md` for the full wiring.
