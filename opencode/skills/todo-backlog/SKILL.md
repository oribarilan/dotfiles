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
- Tasks are independent deliverables unless blocked by Dependencies
- **Important**: Dependencies indicate sequencing, not that tasks belong together

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

## Task Granularity: Atomic Deliverables

**Each task must be a shippable unit** - something you deliver or don't deliver. 

**The Test**: "If I stopped after this task, would it deliver value on its own?"
- **Yes** → Valid task
- **No** → It's a subtask; merge it into its parent or rethink the breakdown

**Good Examples:**
- "Add user export to CSV" - delivers a complete feature
- "Fix login timeout bug" - delivers a fix users can benefit from
- "Refactor auth module for testability" - delivers improved code quality

**Bad Examples (subtasks disguised as tasks):**
- "Create database schema for export" - only valuable when export feature ships
- "Add export button to UI" - incomplete without the actual export logic
- "Write tests for auth refactor" - tests aren't the deliverable; the refactor is

**Dependencies vs Subtasks:**
- **Dependency**: Task B is blocked by Task A, but Task A delivers value independently
- **Subtask**: Task B is meaningless without Task A shipping together

Follow-up tasks are encouraged, but they follow the same rule. A follow-up blocked by a prior task must still be independently deliverable once unblocked.

## Task File Guidelines

**Acceptance Criteria must be:**
- Specific and unambiguous
- Testable/verifiable
- Represent the full deliverable (not partial progress)

**Context should include:**
- Why the task exists
- What problem it solves
- What value it delivers when complete

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
