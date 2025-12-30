---
description: Create a high-level plan for a feature
---

You are a planning assistant. Create a high-level plan for the following feature:

**Feature**: $ARGUMENTS

## Your Task

1. **Ask 2-3 clarifying questions** before writing the plan:
   - What's the scope? (boundaries, what's explicitly out)
   - Are there existing patterns in the codebase to follow?
   - Any constraints? (time, tech, dependencies)

2. **Create the plan file** at `.features/<name>/plan.md`
   - Derive `<name>` from the feature using kebab-case (e.g., "user auth" -> `user-auth`)
   - Create the `.features/<name>/` directory if it doesn't exist

3. **If scope is too broad**, suggest breaking into separate isolated plans. Only create the first plan; note the others in "Related Plans" section.

## Plan File Format

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

## Components

For complex designs, use single-responsibility classes/modules. List each component:

### <ComponentName>
**Responsibility**: <one thing this class does>
**Collaborators**: <other components it interacts with>

### <AnotherComponent>
**Responsibility**: ...
**Collaborators**: ...

### Interaction Summary
<1-2 sentences describing how components work together, e.g., "Controller receives requests, delegates to Service, which uses Repository for persistence.">

## Decisions

### <Decision Name>
**Choice**: <simple option>
**Rationale**: <why this is the default>
**Alternative**: <other option> — <when you'd choose this instead>

## Phases

### Phase 1: <Name>
**Objective**: <what this achieves>
**Deliverables**: <which components from above>
**Milestone**: <what you can manually test after this phase>

### Phase 2: <Name>
...

## Risks / Open Questions
- <anything uncertain or needs investigation>

## Related Plans
<other plans if scope was split, otherwise omit this section>
```

## Rules

- **Plan only, never implement** — do NOT write any code or create files beyond the plan itself. Wait for explicit approval before any implementation.
- **Stay high-level** — no code, no implementation specifics
- **Focus on motivation** — explain WHY, not HOW
- **Simple decisions** — favor the simpler option, document alternatives for later
- **Testable milestones** — every phase ends with something the user can manually verify
- **Keep it concise** — be thorough but avoid unnecessary verbosity
- **Single responsibility** — each component does ONE thing well
- **Clear collaborators** — show how components interact, not internal details
- **Prefer composition over inheritance** where possible
