# Global agent instructions

Shared global instructions loaded by both OpenCode (via `instructions` in
`opencode.jsonc`) and GitHub Copilot CLI (via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`
pointing at this directory).

## Comments & docs

- Write the minimum needed. Skip comments that restate code.
- Keep docstrings and READMEs short and concrete. No filler, no preamble.
- Prefer one tight paragraph over bullet lists where it fits.

## Prose polish

- Before finalizing user-facing prose (PR descriptions, READMEs, design notes,
  commit messages), apply the `humanizer` skill to strip AI-writing tells.
- Apply humanizer principles inline when writing free-form prose, even if not
  explicitly invoked.
