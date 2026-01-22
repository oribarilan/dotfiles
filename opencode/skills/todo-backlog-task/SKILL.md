---
name: todo-backlog
description: Use when working on a project with a .todo/ backlog directory, or when asked to create/manage task files
---

# Todo Backlog System

## Overview

A structured backlog system using `.todo/<task-name>.md` files with clear acceptance criteria. Completed tasks move to `.done/`.

## Directory Structure

```
.todo/
├── <task-name>.md                    # Standalone task
└── <group-name>/                     # Task group (related tasks)
    ├── 1-<first-task>.md
    ├── 2-<second-task>.md
    └── 3-<third-task>.md

.done/
├── <task-name>.md                    # Completed standalone task
└── <group-name>/                     # Completed group (when all tasks done)
    ├── 1-<first-task>.md
    ├── 2-<second-task>.md
    └── 3-<third-task>.md
```

## Before Starting Any Task

1. **Check project documentation first:**
   - Read `README.md` in project root
   - Check `AGENTS.md` if present
   - Browse project docs (location varies - check README/AGENTS for where docs live)
   
2. **Then read the task file** to understand acceptance criteria

## Picking a Task

- Choose any `.todo/*.md` file or `.todo/<group>/*.md` file
- For grouped tasks: work them in sequence order (1-, 2-, 3-, etc.)
- Tasks are independent deliverables unless blocked by Dependencies

## Working a Task

1. Mark acceptance criteria checkboxes as you complete them
2. Add notes to the task file if you discover important context
3. Keep the task file updated with progress

## Completing a Task

**REQUIRED**: When **all** acceptance criteria are checked, you MUST move the task file:

**Standalone task:**
```bash
mkdir -p .done && mv .todo/<task-name>.md .done/
```

**Grouped task:**
```bash
mkdir -p .done/<group-name> && mv .todo/<group-name>/<n>-<task>.md .done/<group-name>/
```

**When all tasks in a group are complete**, move the entire group directory:
```bash
mv .todo/<group-name> .done/
```

**This is not optional.** A task is not complete until the file is moved to `.done/`.

## Creating New Tasks

### Standalone Task

For independent tasks with no related sequence, create directly in `.todo/`:

```bash
.todo/<task-name>.md
```

### Task Groups

When creating multiple related tasks that share a context (e.g., implementing a feature end-to-end), create a **group directory** with sequenced tasks:

```bash
.todo/<group-name>/
├── 1-<first-task>.md
├── 2-<second-task>.md
└── 3-<third-task>.md
```

**When to use groups:**
- Multiple tasks that implement parts of the same feature
- Tasks that naturally build on each other
- Work that shares significant context

**Group naming:**
- Use kebab-case for group directories (e.g., `ai-integration`, `user-export`)
- Prefix tasks with sequence numbers (1-, 2-, 3-)
- Task names after the prefix describe the deliverable

**Example:**
```
.todo/ai-integration/
├── 1-api-endpoints.md
├── 2-data-models.md
└── 3-ux-implementation.md
```

### Task Template

Use this template for both standalone and grouped tasks:

```markdown
# Task: <descriptive-name>

## Context
Brief background on why this task exists and what problem it solves.

**Value delivered**: What does completing this task ship? (Must be valuable on its own)

## Related Files
- `path/to/relevant/file.ts`

## Dependencies
- None (or list task names that must complete first)

Note: Dependencies indicate sequencing only. This task must still deliver value independently once unblocked.

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

## Documentation

When completing tasks that change behavior, APIs, or usage patterns, documentation may need updating.

**Use the `devdoc` skill** for all documentation work - it contains the authoritative guidelines for:
- Finding the project's doc location
- When to update vs. create docs
- Never creating new doc structure without human approval

## Quick Reference

| Action | Command |
|--------|---------|
| List standalone tasks | `ls .todo/*.md` |
| List all tasks (including groups) | `find .todo -name "*.md"` |
| List tasks in a group | `ls .todo/<group>/*.md` |
| **Complete standalone task** | `mkdir -p .done && mv .todo/<task>.md .done/` |
| **Complete grouped task** | `mkdir -p .done/<group> && mv .todo/<group>/<n>-<task>.md .done/<group>/` |
| **Complete entire group** | `mv .todo/<group> .done/` |
| Create standalone task | Create `.todo/<task-name>.md` with template |
| Create task group | Create `.todo/<group-name>/` with sequenced task files |
