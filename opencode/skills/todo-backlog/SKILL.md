---
name: todo-backlog
description: Use when working on a project with a .todo/ backlog directory, or when asked to create/manage task files
---

# Todo Backlog System

## Overview

A structured backlog system using `.todo/<task-name>.md` files with clear acceptance criteria. Tasks flow: **active → pending-review → archive**.

## Directory Structure

```
.todo/
├── AGENTS.md              # These instructions
├── TEMPLATE.md            # Task file template
├── pending-review/        # Completed, awaiting human approval
├── archive/               # Approved/closed tasks
└── <task-name>.md         # Active tasks
```

## Before Starting Any Task

1. **Check project documentation first:**
   - Read `README.md` in project root
   - Check `AGENTS.md` if present
   - Browse `docs/` folder for relevant context
   
2. **Then read the task file** to understand acceptance criteria

## Picking a Task

- Choose any `.todo/*.md` file (no priority ordering)
- Tasks are independent unless explicitly noted in Dependencies section

## Working a Task

1. Mark acceptance criteria checkboxes as you complete them
2. Add notes to the task file if you discover important context
3. Keep the task file updated with progress

## Completing a Task

When **all** acceptance criteria are checked:

```bash
mv .todo/<task-name>.md .todo/pending-review/
```

**Do NOT move directly to archive.** Human approval is required.

## Archival (Human Only)

Only humans move files from `pending-review/` → `archive/`:

```bash
mv .todo/pending-review/<task-name>.md .todo/archive/
```

## Creating New Tasks

Use the template:

```markdown
# Task: <descriptive-name>

## Context
Brief background on why this task exists and what problem it solves.

## Related Files
- `path/to/relevant/file.ts`

## Dependencies
- None (or list task names this depends on)

## Acceptance Criteria
- [ ] Criterion 1 - specific, testable
- [ ] Criterion 2 - specific, testable
- [ ] Criterion 3 - specific, testable

## Scope Estimate
Small | Medium | Large

## Notes
Additional context, links, or considerations.
```

## Task File Guidelines

**Acceptance Criteria must be:**
- Specific and unambiguous
- Testable/verifiable
- Independent where possible

**Context should include:**
- Why the task exists
- What problem it solves
- Any relevant background

**Related Files help agents:**
- Find the right code quickly
- Understand scope boundaries

## Quick Reference

| Action | Command |
|--------|---------|
| List active tasks | `ls .todo/*.md` |
| Complete a task | `mv .todo/<task>.md .todo/pending-review/` |
| Archive (human) | `mv .todo/pending-review/<task>.md .todo/archive/` |
| Create new task | Copy from `.todo/TEMPLATE.md` |
