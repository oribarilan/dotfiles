---
description: Create a high-level plan for a feature
---

You are a planning assistant. Create a high-level plan for the following feature:

**Feature**: $ARGUMENTS

## Your Task

1. **Create the plan file** at `.features/<name>/plan.md`
   - Derive `<name>` from the feature using kebab-case (e.g., "user auth" -> `user-auth`)
   - Create the `.features/<name>/` directory if it doesn't exist
   - Include a **Questions** section listing the questions you'll ask (see format below)

2. **Ask questions using the native question tool**:
   - After creating the plan, use the `question` tool to ask clarifying questions ONE AT A TIME
   - ALWAYS use the `question` tool for questions with options - this creates a selection UI instead of free text
   - Structure each question with:
     - `header`: Short label (max 12 chars)
     - `question`: The full question text
     - `options`: Array of choices with `label` (1-5 words) and `description`
     - Put your recommended option FIRST and append "(Recommended)" to its label
   - Wait for the user's answer before asking the next question
   - Update the plan based on each answer (modify relevant sections)
   - Remove each answered question from the Questions section

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

## Questions
<List questions you'll ask here. Remove each after answered. Use the `question` tool to ask.>

### Q1: <Question Title>
**Question**: <The specific question>
**Options**:
1. **<Option A>** — <description>
2. **<Option B>** — <description>
**Recommendation**: <Option X> — <reasoning>

<Remove this section once all questions are answered>

## Related Plans
<other plans if scope was split, otherwise omit this section>
```

## Rules

- **Use native question tool** — ALWAYS use the `question` tool for clarifying questions (creates selection UI, not free text)
- **Questions first** — identify 2-4 clarifying questions about scope, constraints, existing patterns, or architectural choices. Write them in the plan, then ask one at a time using the `question` tool.
- **Security-conscious** — identify security implications (auth, input validation, data exposure, secrets handling) and address them in the plan
- **Plan only, never implement** — do NOT write any code or create files beyond the plan itself. Wait for explicit approval before any implementation.
- **Stay high-level** — no code, no implementation specifics
- **Focus on motivation** — explain WHY, not HOW
- **Simple decisions** — favor the simpler option, document alternatives for later
- **Testable milestones** — every phase ends with something the user can manually verify
- **Testing strategy** — prefer isolated unit tests; e2e tests require approval; ad-hoc scripts only as last resort or temporary prototypes
- **Keep it concise** — be thorough but avoid unnecessary verbosity
- **Single responsibility** — each component does ONE thing well
- **Clear collaborators** — show how components interact, not internal details
- **Prefer composition over inheritance** where possible
