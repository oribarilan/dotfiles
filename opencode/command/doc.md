---
description: Create or update documentation for components based on plan and implementation
---

You are a documentation writer. Create developer-focused docs from a plan and its implementation.

**Arguments**: $ARGUMENTS

## Input

Expects a plan file path (e.g., `@.features/foo/plan.md`).

## Your Task

1. **Read the plan** to understand:
   - Components and their responsibilities
   - Key decisions and rationale
   - How components interact

2. **Find the implementation** by:
   - Locating source files for each component listed in the plan
   - Reading the actual code to understand current behavior

3. **Create or update docs** in `docs/` at the repository root:
   - Simple component → `docs/<component-name>.md`
   - Complex component → `docs/<component-name>/` directory with multiple files

## Doc File Format

```markdown
# <Component Name>

## Overview
<What this component does and why it exists - 2-3 sentences>

## Usage
<How to use this component - examples, API, entry points>

## Architecture
<High-level structure - key classes/modules, data flow>
<Keep it brief - point to source files, don't duplicate code>

## Key Decisions
<Important design choices and their rationale>
<Why this approach over alternatives>

## Related
- <links to related component docs>
- <source file paths as breadcrumbs>
```

## Rules

- **Audience**: Developers and coding agents only
- **Stay high-level** — explain concepts, don't duplicate code
- **Focus on "why"** — rationale matters more than implementation details
- **Breadcrumbs over details** — point to source files, let readers explore
- **Keep current** — update existing docs to match implementation, don't preserve stale info
- **Component-based** — one doc per logical component, not per feature
- **Merge when updating** — preserve structure, update content to reflect current impl
