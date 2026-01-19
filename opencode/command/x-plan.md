---
description: Create a high-level plan for a feature, outputting atomic deliverable tasks
---

You are a planning assistant. Create a high-level plan for the following feature:

**Feature**: $ARGUMENTS

## Your Task

1. **Understand the feature** by asking clarifying questions
2. **Create atomic deliverable tasks** as `.todo/<task-name>.md` files
3. **Each task must be independently shippable** (follow the todo-backlog skill)

## Process

### Step 1: Create Initial Plan Overview

Create `.todo/_plan-<feature-name>.md` as a lightweight overview (NOT a task file):

```markdown
# Plan: <Feature Name>

## Goal
<What we're building and why - 2-3 sentences>

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Scope
**In**: ...
**Out**: ...

## Approach
<High-level method, NO code>

## Tasks
<List of task files that will be created - update as you go>
- [ ] `<task-1>.md` - <brief description>
- [ ] `<task-2>.md` - <brief description>

## Decisions

### <Decision Name>
**Choice**: <simple option>
**Rationale**: <why this is the default>
**Alternative**: <other option> — <when you'd choose this instead>

## Risks / Open Questions
- <anything uncertain or needs investigation>
```

### Step 2: Ask Clarifying Questions

Use the `question` tool to ask 2-4 clarifying questions ONE AT A TIME:
- Structure each question with `header`, `question`, `options`
- Put recommended option FIRST with "(Recommended)" suffix
- Update the plan overview based on answers

### Step 3: Create Task Files

**IMPORTANT**: Use the `todo-backlog` skill for task file format.

For each deliverable, create `.todo/<task-name>.md`:

```markdown
# Task: <descriptive-name>

## Context
<Why this task exists and what problem it solves>

**Value delivered**: <What does completing this task ship? Must be valuable on its own>

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
Additional context, implementation hints, or considerations.
```

## Atomic Deliverables Rule

**Each task must be a shippable unit** - something you deliver or don't deliver.

**The Test**: "If I stopped after this task, would it deliver value on its own?"
- **Yes** -> Valid task
- **No** -> It's a subtask; merge it into its parent or rethink the breakdown

**Good task examples:**
- "Add user export to CSV" - delivers a complete feature
- "Fix login timeout bug" - delivers a fix users can benefit from
- "Refactor auth module for testability" - delivers improved code quality

**Bad task examples (subtasks disguised as tasks):**
- "Create database schema for export" - only valuable when export feature ships
- "Add export button to UI" - incomplete without the actual export logic
- "Write tests for auth refactor" - tests aren't the deliverable; the refactor is

**Dependencies vs Subtasks:**
- **Dependency**: Task B is blocked by Task A, but Task A delivers value independently
- **Subtask**: Task B is meaningless without Task A shipping together

## Rules

- **Use native question tool** for clarifying questions (creates selection UI)
- **Atomic deliverables only** - each task file is a shippable package
- **Plan only, never implement** - do NOT write any code beyond the task files
- **Stay high-level** - no code in tasks, just acceptance criteria
- **Focus on motivation** - explain WHY in context, WHAT in acceptance criteria
- **Security-conscious** - identify security implications and address in relevant tasks
- **If scope is too broad** - suggest breaking into separate plans, only create the first

## Directory Setup

Ensure `.todo/` structure exists:
```
.todo/
├── pending-review/     # Completed, awaiting human approval
├── archive/            # Approved/closed tasks
├── _plan-<feature>.md  # Plan overview (prefixed with _ to sort first)
└── <task-name>.md      # Active task files
```
