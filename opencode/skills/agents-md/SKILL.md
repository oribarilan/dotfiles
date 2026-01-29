---
name: agents-md
description: Use when creating or improving an AGENTS.md file for a project to guide AI coding agents
---

# AGENTS.md Skill

Create or improve an `AGENTS.md` file - the source of truth for AI coding agents working in a repository.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DETECT MODE                                                 │
│     └─> Check if AGENTS.md exists → CREATE or IMPROVE mode      │
├─────────────────────────────────────────────────────────────────┤
│  2. DISCOVER (silent)                                           │
│     └─> Scan project structure, tooling, existing docs          │
├─────────────────────────────────────────────────────────────────┤
│  3. INTERACTIVE QUESTIONS                                       │
│     └─> Ask user about docs, tasks, terminology, preferences    │
├─────────────────────────────────────────────────────────────────┤
│  4. GAP ANALYSIS (improve mode)                                 │
│     └─> Compare existing AGENTS.md against best practices       │
├─────────────────────────────────────────────────────────────────┤
│  5. DRAFT & REVIEW                                              │
│     └─> Generate/update AGENTS.md, get user approval            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Detect Mode

Check if `AGENTS.md` exists in project root:
- **Exists** → IMPROVE mode (analyze gaps, suggest additions)
- **Missing** → CREATE mode (build from scratch)

---

## Phase 2: Silent Discovery

Gather information WITHOUT asking the user yet. Scan for:

### Project Identity
```bash
# Check for project manifests
ls package.json Cargo.toml go.mod pyproject.toml *.csproj *.sln 2>/dev/null

# Understand structure  
ls -la
find . -maxdepth 2 -type d | grep -E "(src|lib|app|cmd|pkg|internal)" | head -10
```

### Existing Documentation
```bash
# Check for docs
ls README.md CONTRIBUTING.md AGENTS.md docs/ .github/ 2>/dev/null
```

### Task Management
```bash
# Check for task systems
ls .todo/ .tasks/ TODO.md 2>/dev/null
ls justfile Makefile 2>/dev/null
```

### Code Style & Tooling
```bash
# Formatters and linters
ls .prettierrc* .eslintrc* stylua.toml rustfmt.toml .editorconfig pyproject.toml 2>/dev/null

# Testing
ls jest.config* vitest.config* pytest.ini .pytest.ini conftest.py 2>/dev/null
find . -maxdepth 3 -type d -name "__tests__" -o -name "test" -o -name "tests" 2>/dev/null | head -5
```

### Monorepo Detection
```bash
# Check for monorepo patterns
ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null
ls packages/ apps/ libs/ 2>/dev/null
```

### CI/CD & Git
```bash
# Check for CI configuration
ls .github/workflows/ .gitlab-ci.yml .circleci/ Jenkinsfile 2>/dev/null

# Check for git hooks
ls .husky/ .git/hooks/ .pre-commit-config.yaml 2>/dev/null

# Check branch protection indicators
cat .github/CODEOWNERS 2>/dev/null | head -5
```

### Environment & Secrets
```bash
# Check for env patterns
ls .env.example .env.local.example .env.template 2>/dev/null
ls docker-compose*.yml 2>/dev/null

# Check for secrets patterns (DO NOT read contents)
ls .gitignore | xargs grep -l "\.env" 2>/dev/null
```

Record what you find. This informs the questions.

---

## Phase 3: Interactive Questions

Use the Question tool to ask the user. Adapt questions based on discovery.

### Required Questions

**Q1: Documentation System**
If NO docs/ directory found:
> "I didn't find a docs/ directory. Do you want in-repo documentation?"
> - Yes, create docs/ structure
> - No, keep docs minimal (README only)
> - Already have docs elsewhere (specify)

If docs/ EXISTS:
> "I found docs/ directory. How should agents handle documentation?"
> - Update existing docs when code changes
> - Docs are manually maintained, don't auto-update
> - Other approach (specify)

**Q2: Task Management**
If NO .todo/ found:
> "Do you want a task management system for agents?"
> - Yes, use .todo/ backlog system
> - No, use GitHub issues / external system
> - Other approach (specify)

If .todo/ EXISTS:
> "I found .todo/ directory. Should agents use this for task tracking?"
> - Yes, follow the todo-backlog skill
> - No, it's for humans only

**Q3: Terminology**
> "Are there domain-specific terms that could be confused? (e.g., 'auth' vs 'integration', 'user' vs 'account')"
> - Yes (will ask for details)
> - No confusable terms

If yes, follow up:
> "Describe the terms that could be confused and their differences."

**Q4: Testing Preference**
If testing setup found:
> "I found [jest/vitest/pytest/etc]. What's your testing philosophy?"
> - TDD - write tests first
> - Test alongside development
> - Test after implementation
> - Minimal testing

**Q5: Code Review**
> "Should agents self-review code before committing?"
> - Yes, always review and iterate
> - Only for significant changes
> - No, rely on CI/PR review

**Q6: Security Sensitivity**
> "How security-sensitive is this project?"
> - High (auth, payments, PII) - strict security section
> - Medium - standard security practices
> - Low (internal tool, prototype) - minimal security focus

**Q7: Monorepo Structure** (if monorepo detected)
> "I detected a monorepo setup. How should agents navigate it?"
> - Document package boundaries and dependencies
> - Treat as independent projects
> - Other approach (specify)

**Q8: Environment Setup**
If .env.example or similar found:
> "I found environment configuration. What should agents know?"
> - Document required env vars in AGENTS.md
> - Point to .env.example, don't duplicate
> - Environment setup is complex, add detailed section

**Q9: Git Workflow**
If CI/CD detected:
> "What's your git workflow?"
> - Feature branches → PR → main
> - Trunk-based development
> - Gitflow (develop, release branches)
> - Other (specify)

**Q10: Dependency Policy**
> "How should agents handle adding dependencies?"
> - Ask before adding any new dependency
> - Add freely if well-maintained and necessary
> - Prefer stdlib/existing deps, minimize new ones

### Improvement Mode Questions

If AGENTS.md exists, also ask:

**Q6: Missing Sections**
After gap analysis, if sections are missing:
> "Your AGENTS.md is missing these common sections: [list]. Add them?"
> - Yes, add all
> - Let me choose which ones
> - No, keep it minimal

**Q7: Outdated Information**
If detected:
> "Some information may be outdated (e.g., [specific examples]). Update?"
> - Yes, update to match current project
> - No, leave as-is

---

## Phase 4: Gap Analysis (Improve Mode)

Compare existing AGENTS.md against this checklist:

### Mandatory Sections (must exist)
- [ ] Core Principles section with KISS, DRY, planning, communication
- [ ] Code organization / directory structure
- [ ] How to run the project
- [ ] How to run tests

### Recommended Sections (suggest if missing)
- [ ] Terminology (if confusable terms exist)
- [ ] Knowledge management / docs location
- [ ] Task management approach
- [ ] Code style / formatting
- [ ] Commit guidelines
- [ ] Code review process
- [ ] Security practices (especially for sensitive projects)
- [ ] Git workflow / branching strategy
- [ ] Environment setup
- [ ] Dependency policy
- [ ] Error handling patterns
- [ ] CI/CD awareness (what pipelines run, how to not break them)

### Best Practices Check
Verify these are covered (add if missing):
- [ ] "Plan before coding" guidance
- [ ] "Ask before assuming" guidance  
- [ ] File size limits mentioned
- [ ] Single responsibility mentioned
- [ ] When to deviate from KISS/DRY (with user awareness)

Report gaps to user and ask which to address.

---

## Phase 5: Generate AGENTS.md

### Mandatory Core Principles Section

**This section is NON-NEGOTIABLE. Always include it.**

```markdown
## Core Principles

### Plan Before You Code
- Understand the task fully before writing code
- Break complex tasks into smaller steps
- Use todo lists to track multi-step work
- If requirements are unclear, clarify first

### Ask, Don't Assume
- When uncertain about requirements, ask the user
- When multiple approaches exist, present options
- Don't guess at business logic or user preferences
- Clarify scope before making architectural decisions

### KISS (Keep It Simple, Stupid)
- Prefer simple solutions over clever ones
- Avoid premature abstraction
- If a solution feels complex, step back and reconsider
- **If deviating from simplicity, inform the user why**

### DRY (Don't Repeat Yourself)
- Extract shared logic into reusable functions
- But don't over-abstract - wait for patterns to emerge (Rule of Three)
- **If duplicating code intentionally, inform the user why**

### Single Responsibility & Small Files
- Each function/module does one thing well
- Keep files under ~500 lines where possible
- Large files are a smell - consider splitting by:
  - Components → sub-components, hooks, utilities
  - Modules → by domain or operation type
  - Classes → extract collaborators
- Prefer composable primitives over monolithic solutions

### Security
- Never store secrets in code, logs, or error messages
- Validate and sanitize all inputs (user input, API responses, webhooks)
- Use parameterized queries - never string concatenation for data access
- Apply principle of least privilege for OAuth scopes and permissions
- When in doubt, choose the more secure option
- **For high-sensitivity projects, add project-specific security requirements**
```

### Full AGENTS.md Template

```markdown
# AGENTS.md

## Terminology
[Include ONLY if user confirmed confusable terms exist]

**IMPORTANT: Understand the difference between [Term A] and [Term B].**

| Term | What it is | Example |
|------|------------|---------|
| **[Term A]** | [Definition] | [Concrete example] |
| **[Term B]** | [Definition] | [Concrete example] |

[Explain why confusion is problematic]

---

## Core Principles

### Plan Before You Code
- Understand the task fully before writing code
- Break complex tasks into smaller steps  
- Use todo lists to track multi-step work
- If requirements are unclear, clarify first

### Ask, Don't Assume
- When uncertain about requirements, ask the user
- When multiple approaches exist, present options
- Don't guess at business logic or user preferences
- Clarify scope before making architectural decisions

### KISS (Keep It Simple, Stupid)
- Prefer simple solutions over clever ones
- Avoid premature abstraction
- If a solution feels complex, step back and reconsider
- **If deviating from simplicity, inform the user why**

### DRY (Don't Repeat Yourself)  
- Extract shared logic into reusable functions
- But don't over-abstract - wait for patterns to emerge (Rule of Three)
- **If duplicating code intentionally, inform the user why**

### Single Responsibility & Small Files
- Each function/module does one thing well
- Keep files under ~500 lines where possible
- Large files are a smell - consider splitting
- Prefer composable primitives over monolithic solutions

### Security Mindset
- Never store secrets in code or logs
- Validate all inputs, sanitize outputs
- When in doubt, choose the more secure option

[Add project-specific principles based on user responses]

---

## Knowledge Management
[Include if user wants docs]

### Documentation Location
- Project docs live in `docs/`
- Update docs when changing public APIs or workflows
- Use the `devdoc` skill for documentation work

### Maintaining AGENTS.md
- Update this file as new patterns emerge
- Keep it current with project conventions

---

## Task Management
[Include if user wants .todo/ system]

### Using the Backlog
- Tasks live in `.todo/` directory
- Completed tasks move to `.done/`
- Use the `todo-backlog` skill for task management

---

## Code Organization

```
[Project-specific directory structure]
```

---

## Development

### Running the Project
```bash
[Project-specific commands]
```

### Running Tests
```bash
[Project-specific test commands]
```

### Test Philosophy
[Based on user's testing preference response]

---

## Code Style

[Project-specific style based on discovered tooling]

### Formatting
- Formatter: [discovered formatter]
- Run: `[format command]`

### Naming Conventions
[Project-specific or language defaults]

---

## Code Review
[Based on user's code review preference]

---

## Commit Guidelines
[Project-specific or sensible defaults]
```

### Additional Sections (include based on Q&A responses)

#### Security Section (for medium/high sensitivity projects)
```markdown
## Security

### Principles
- Never store secrets in code, logs, or error messages
- Validate all inputs - user data, API responses, webhook payloads
- Use parameterized queries, never string concatenation
- Apply least privilege for OAuth scopes and permissions
- Encrypt sensitive data at rest (tokens, API keys, PII)

### Secrets Handling
- Use environment variables for all secrets
- Never commit .env files (check .gitignore)
- Reference .env.example for required variables

### [Project-specific security requirements]
```

#### Git Workflow Section
```markdown
## Git Workflow

### Branching Strategy
[Feature branches / trunk-based / gitflow - based on user response]

### Branch Naming
- Features: `feat/description` or `feature/description`
- Fixes: `fix/description`
- Chores: `chore/description`

### Pull Requests
- PRs require [review count] approvals
- CI must pass before merge
- [Squash/merge commit preference]

### Protected Branches
- `main` / `master` - never force push
- [Other protected branches]
```

#### Environment Setup Section
```markdown
## Environment Setup

### Required Environment Variables
Copy `.env.example` to `.env` and configure:
```bash
cp .env.example .env
```

Key variables:
- `DATABASE_URL` - [description]
- `API_KEY` - [description]
[List discovered/user-provided vars]

### Local Development
```bash
[Setup commands]
```
```

#### Dependencies Section
```markdown
## Dependencies

### Policy
[Based on user response - ask first / add freely / minimize]

### Adding Dependencies
- Check if functionality exists in stdlib or current deps first
- Prefer well-maintained packages with active communities
- Consider bundle size impact (for frontend)
- Document why the dependency was added in PR

### Updating Dependencies
- Run `[update command]` periodically
- Test thoroughly after updates
- Don't update major versions without review
```

#### Error Handling Section
```markdown
## Error Handling

### Principles
- Fail fast, fail loud - don't swallow errors silently
- Log errors with context (what operation, what input)
- User-facing errors should be helpful but not leak internals
- Use typed errors / error codes where possible

### Logging
- Use structured logging (JSON) in production
- Include correlation IDs for request tracing
- Log levels: error (failures), warn (degraded), info (significant events), debug (development)
- Never log sensitive data (passwords, tokens, PII)
```

#### CI/CD Awareness Section
```markdown
## CI/CD

### Pipelines
[Describe what runs on PR, on merge, etc.]

### Pre-commit Hooks
[Describe what hooks run locally - formatting, linting, tests]

### Don't Break the Build
- Run `[test command]` locally before pushing
- Run `[lint command]` locally before pushing
- If CI fails, fix it before requesting review

### Deploy Process
[How deploys work, any manual steps]
```

#### Monorepo Section (if applicable)
```markdown
## Monorepo Structure

### Packages
```
packages/
├── core/          # Shared utilities
├── api/           # Backend service
└── web/           # Frontend app
```

### Package Boundaries
- Import from package public API only (`packages/core/src/index.ts`)
- Don't reach into package internals
- Shared types go in `packages/core`

### Running Commands
```bash
# Run command in specific package
pnpm --filter @org/web dev

# Run command in all packages
pnpm -r build
```

### Dependencies Between Packages
[Document which packages depend on which]
```

---

## Writing Guidelines

### Be Specific, Not Generic
- Bad: "Follow best practices"
- Good: "Run `npm test` for unit tests. Tests live in `__tests__/`."

### Include Runnable Commands
- Bad: "Use the task runner"
- Good: `just dev  # Start development server`

### Explain the Why
- Bad: "Keep files small"
- Good: "Keep files under 500 lines - large files indicate need for decomposition."

### Be Opinionated
- Bad: "Consider using types"
- Good: "Use TypeScript. No `any` unless truly necessary."

---

## Validation Checklist

Before finalizing, verify:

- [ ] Core Principles section is complete (planning, asking, KISS, DRY, SRP, security)
- [ ] Can an agent run the project with info provided?
- [ ] Can an agent run tests with info provided?
- [ ] File locations are specific enough to navigate
- [ ] Commands are copy-pasteable and correct
- [ ] User's preferences from Q&A are reflected
- [ ] Security section included (if medium/high sensitivity)
- [ ] Git workflow documented (if CI/CD exists)
- [ ] Environment setup documented (if .env exists)
- [ ] No generic filler content

---

## Anti-Patterns

1. **Skipping Core Principles** - Never omit the mandatory section
2. **Generic advice** - "Write clean code" is useless
3. **Missing commands** - Always include runnable commands
4. **Guessing preferences** - Ask the user, don't assume
5. **Over-documenting** - AGENTS.md should be scannable
6. **Duplicating README** - AGENTS.md is for agents, README for humans
7. **Ignoring security** - Even low-sensitivity projects need basics
8. **Outdated commands** - Verify commands actually work
9. **Missing env setup** - Agents can't run what they can't configure
