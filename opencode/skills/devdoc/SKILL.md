---
name: devdoc
description: Use when creating or updating project documentation
---

# Developer Documentation Skill

## Core Principle

**Docs stay accurate as code evolves, but humans own the documentation strategy.**

## Before Writing Any Documentation

1. **Find the project's doc location** - Check `README.md` or `AGENTS.md` for where docs live (commonly `/docs/`, but varies by project)

2. **Never create new documentation structure** without explicit human approval:
   - No new doc folders
   - No new index files
   - No new doc hierarchies
   
   If docs don't exist and you think they should, **ask first**.

3. **Update existing docs** - If relevant docs exist, update them to reflect current implementation

## When to Document

Document when your work changes:
- Public APIs or interfaces
- Usage patterns or workflows
- Configuration options
- Architecture or component relationships

Skip documentation for:
- Internal implementation details
- Obvious code (self-documenting)
- Temporary or experimental code

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

## Guidelines

- **Audience**: Developers and coding agents only
- **Stay high-level** - explain concepts, don't duplicate code
- **Focus on "why"** - rationale matters more than implementation details
- **Breadcrumbs over details** - point to source files, let readers explore
- **Keep current** - update existing docs to match implementation, don't preserve stale info
- **Security-conscious** - document security considerations (auth, input validation, data sensitivity) where relevant
- **Component-based** - one doc per logical component, not per feature
- **Merge when updating** - preserve structure, update content to reflect current implementation
