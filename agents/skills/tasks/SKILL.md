---
name: tasks
description: Use when working with a .todo/ directory, creating or managing tasks, picking tasks to work on, or completing tasks
---

# Todo Backlog System

## Overview

A structured backlog system using markdown files in `.todo/`. Tasks belong to either the general backlog or a user story.

## Directory Structure

```
.todo/
├── backlog/                          # Standalone tasks
│   └── <task-name>.md
├── US-<story-name>/                  # User story
│   ├── main.md                       # Story overview, priorities, cross-cutting concerns
│   ├── 1-<task-name>.md              # Optional numeric prefix = execution step
│   ├── 2-<task-name>.md
│   └── <task-name>.md                # Unprefixed = no enforced order
└── done/                             # Completed tasks (mirrors source structure)
    ├── backlog/
    │   └── <task-name>.md
    └── US-<story-name>/
        ├── main.md                   # Moved here when story is finalized
        └── <task-name>.md            # Prefix is preserved if it had one
```

### Numeric Step Prefixes (optional)

When tasks in a user story have a **real sequential dependency** (task 2 cannot start until task 1 ships), prefix the filename with the step number:

```
US-eval/
├── main.md
├── 1-setup-dataset.md
├── 2-run-baseline.md
└── 3-add-metrics.md
```

**Rules:**
- **Optional**: only use prefixes when ordering is meaningful. Independent / parallelizable tasks stay unprefixed.
- **Filename wins**: when prefixes exist, they are the source of truth for execution order. The `Task Priority` section in `main.md` becomes optional (or can omit prefixed tasks and only list unprefixed ones).
- **Don't fake order**: do not add prefixes just to impose arbitrary ordering on independent tasks.
- **Mixed is fine**: a story can have both prefixed (sequential) and unprefixed (independent) tasks side by side.

## User Stories

A user story groups related tasks under a `US-` prefixed directory (e.g., `US-eval`, `US-onboarding`).

**`main.md`** is required for every user story. It contains:
- Overall goal and context
- Task prioritization order
- Cross-cutting concerns and decisions that affect multiple tasks

## Definition of Done

Every task and user story **must** have a clear, testable definition of done — not vague intents or desires, but concrete outcomes the agent can verify with high confidence.

### What makes a good definition of done

- **Observable**: you can see or measure the result (a test passes, a command outputs X, a file exists with Y content)
- **Binary**: it's done or it's not — no "mostly done" or "should work"
- **Agent-verifiable**: the agent can check it without asking the user (run a test, check output, inspect a file)

### Bad vs Good

| ❌ Bad (vague intent) | ✅ Good (testable outcome) |
|---|---|
| "Support dark mode" | "Toggling the theme switch applies `data-theme='dark'` to `<html>` and all CSS variables update" |
| "Improve error handling" | "All API endpoints return structured `{ error, code, message }` on failure; no raw stack traces in production responses" |
| "Add logging" | "`npm run build` produces zero warnings; all API calls log request method, path, status, and duration to stdout" |

### When to push back

**If you cannot describe how to verify a task is done, the task is not ready to work on.**

Before starting a task, evaluate its acceptance criteria. If any criterion is:
- Subjective ("make it better", "improve UX")
- Unmeasurable ("should be fast", "handle edge cases")
- Missing a concrete check ("add tests" — which tests? what do they assert?)

Then **stop and ask the user** to refine the criteria into something testable. Suggest specific verifiable alternatives. Do not start work on tasks you cannot confidently verify.

## Before Starting Any Task

1. **Check project documentation first:**
   - Read `README.md` in project root
   - Check `AGENTS.md` if present
   - Browse project docs (location varies - check README/AGENTS for where docs live)

2. **Then read the task file** to understand acceptance criteria
3. **For user story tasks**, read `main.md` first for prioritization and context

## Picking a Task

- **Backlog:** choose any `.todo/backlog/*.md` file
- **User story:**
  - If tasks use numeric prefixes (`1-foo.md`, `2-bar.md`), execute them in numeric order — earlier steps must be done before later ones
  - For unprefixed tasks, check `main.md` for priority order
  - A story may mix both — finish the prefixed sequence as required, pick unprefixed tasks per `main.md` guidance
- Respect dependencies between tasks
- Tasks are independent deliverables — each must ship value on its own

## Task Housekeeping (non-negotiable)

Tasks are the source of truth for what's in flight, what's done, and why. **Stale task files are a bug.** Every time you touch a task, you owe it housekeeping:

- **Tick checkboxes** as criteria are met — never leave a verified criterion unchecked
- **Update the task file** with discoveries: revised criteria, new constraints, decisions made, files touched, follow-ups
- **Record deviations**: if you diverged from the original plan, write down what you actually did and why
- **Move on completion**: a task is not done until the file lives in `.todo/done/` (see [Completing a Task](#completing-a-task))
- **Finalize stories**: when the last task in a `US-<story>/` ships, verify story-level DoD and move `main.md` too

**Before ending any session that touched a task**, do a housekeeping pass:
1. Are all completed criteria checked?
2. Is the task file's current state accurate (notes, deviations, follow-ups recorded)?
3. Are completed tasks moved to `.todo/done/`?
4. Are emptied user stories finalized?

If the answer to any of these is "no" and the work is actually done, fix it before stopping.

## Working a Task

1. **Verify the definition of done is testable** before writing any code. If not, ask the user to clarify.
2. Mark acceptance criteria checkboxes as you complete them — in the same edit batch as the work that satisfies them, not "later"
3. Add notes to the task file as you discover important context, decisions, or deviations from the original plan
4. Keep the task file updated with progress — it should accurately reflect reality at all times, not just at the end

## Completing a Task

### Verification is mandatory

Before moving a task to done, you **must actively verify** every acceptance criterion yourself — not just trust that the code looks right.

**Prefer automated tests (ask the user first):**
When a criterion can be covered by a lasting automated test (unit, integration, e2e), propose adding one. This is the highest-confidence verification and provides ongoing regression protection. But the user must agree — automated tests are code that lives in the project, so align on:
- Whether the project wants a test for this
- What test framework / location to use
- Whether the criterion warrants ongoing automation vs. a one-time check

**Fall back to ad-hoc verification:**
When automated tests are impossible, irrelevant, or the user declines:
- Run the relevant command and check output
- Inspect files for expected content
- Hit an endpoint and verify the response
- Build/compile and confirm zero errors
- Any concrete action that proves the criterion is met

**Never skip verification.** "I wrote the code so it should work" is not verification. You must have **evidence**, not assumptions.

When **all** acceptance criteria are verified:

1. **Tick every checkbox** in the task file
2. **Update the file** with anything that changed during execution: actual approach taken, deviations, follow-ups, files touched, decisions made
3. **Move the file** to `.todo/done/`, preserving the source structure

```bash
# Backlog task
mkdir -p .todo/done/backlog && mv .todo/backlog/<task>.md .todo/done/backlog/

# User story task
mkdir -p .todo/done/US-<story>/ && mv .todo/US-<story>/<task>.md .todo/done/US-<story>/
```

**This is not optional.** A task is not complete until the file is updated to reflect final reality **and** moved to `.todo/done/`. Leaving a finished task in its source directory — or moving it without updating checkboxes/notes — is a housekeeping bug.

### Finalizing a User Story

When the **last task** in a user story is completed (no more `.md` files remain in `.todo/US-<story>/` except `main.md`):

1. **Verify the story-level Definition of Done** in `main.md` — run end-to-end checks, not just confirm individual tasks passed. Prefer adding an automated test that covers the story-level outcome if the user agrees; otherwise perform ad-hoc verification.
2. Check all story-level criteria checkboxes in `main.md`
3. If you cannot verify the story is holistically done, **ask the user** before finalizing
4. Move and clean up:

```bash
mv .todo/US-<story>/main.md .todo/done/US-<story>/ && rmdir .todo/US-<story>/
```

A user story is not finalized until its story-level definition of done is verified, `main.md` is moved, and the source directory is cleaned up.

## Creating New Tasks

### Standalone Task

For independent tasks with no related story, create in `.todo/backlog/`:

```bash
.todo/backlog/<task-name>.md
```

### User Story

When creating related tasks that form a coherent feature or initiative:

```
.todo/US-<story-name>/
├── main.md                # Required: overview, priorities, cross-cutting concerns
├── 1-<task-name>.md       # Optional: prefix when tasks have a sequential dependency
├── 2-<task-name>.md
└── <task-name>.md         # Unprefixed: independent / parallelizable
```

**When to use user stories:**
- Multiple tasks implementing parts of the same feature
- Tasks that share significant context
- Work that benefits from shared prioritization and cross-cutting notes

**Naming:** use kebab-case for story and task names (e.g., `US-eval`, `setup-monorepo.md`). Optionally prefix with a step number (`1-setup-monorepo.md`) when tasks must run in order — see [Numeric Step Prefixes](#numeric-step-prefixes-optional).

### Task Template

```markdown
# <task-name>

## Context
Why this task exists and what it delivers.

**Value delivered**: What does completing this task ship? (Must be valuable on its own)

## Related Files
- `path/to/relevant/file.ts`

## Dependencies
- None (or list task names that must complete first)

## Acceptance Criteria
- [ ] Criterion 1 - specific, testable, agent-verifiable
- [ ] Criterion 2 - specific, testable, agent-verifiable

## Verification
How to confirm this task is done:
- **Automated** (preferred, if user agrees): test file/command to create
- **Ad-hoc** (fallback): commands to run, output to expect, files to inspect

## Notes
Additional context, links, or considerations.
```

### User Story main.md Template

```markdown
# US-<story-name>

## Goal
What this user story delivers overall.

## Definition of Done
How to verify the **entire story** is complete — the end-to-end outcome, not just individual tasks.
- [ ] Story-level criterion 1 - verifiable end state
- [ ] Story-level criterion 2 - verifiable end state

## Task Priority
1. `<task-name>.md` — why first
2. `<task-name>.md` — why second

> If tasks use numeric filename prefixes (`1-foo.md`, `2-bar.md`), the filename is the source of truth for order — this section becomes optional and may be omitted, or used only for unprefixed tasks.

## Cross-Cutting Concerns
- Decisions, constraints, or patterns that apply across tasks
```

## Task Granularity: Atomic Deliverables

**Each task must be a shippable unit** - something you deliver or don't deliver.

**The Test**: "If I stopped after this task, would it deliver value on its own?"
- **Yes** → Valid task
- **No** → It's a subtask; merge it into its parent or rethink the breakdown

## Documentation

When completing tasks that change behavior, APIs, or usage patterns, documentation may need updating.

**Use the `devdoc` skill** for all documentation work.

## Quick Reference

| Action | Command |
|--------|---------|
| List backlog tasks | `ls .todo/backlog/` |
| List story tasks | `ls .todo/US-<story>/` |
| List all active tasks | `find .todo -name "*.md" -not -path ".todo/done/*"` |
| Complete backlog task | `mkdir -p .todo/done/backlog && mv .todo/backlog/<task>.md .todo/done/backlog/` |
| Complete story task | `mkdir -p .todo/done/US-<story> && mv .todo/US-<story>/<task>.md .todo/done/US-<story>/` |
| Finalize user story | `mv .todo/US-<story>/main.md .todo/done/US-<story>/ && rmdir .todo/US-<story>/` |
