---
name: gsack-plan-eng-review
description: |
  Architecture and engineering plan review. Evaluates architecture, code quality,
  test coverage, and performance. Use when reviewing a plan or design doc before
  implementation, when asked to "review the plan", "architecture review", or
  "eng review". Proactively suggest when a plan exists and hasn't been reviewed.
---

# Engineering Plan Review

A structured review framework for architecture and engineering plans. Four review sections, each with mandatory stop-and-ask gates. Never skip a section — if zero findings, say "No issues found" and move on.

## Pre-Review System Audit

Before reviewing, gather context:

1. `git log --oneline -30` — recent history
2. `git diff` against base branch — what's changed
3. Read AGENTS.md/CLAUDE.md and any existing architecture docs
4. Check for TODOs/FIXMEs in affected files
5. Retrospective check — prior review cycles on this branch

## Step 0: Scope Challenge

Before reviewing anything, answer these five questions:

1. **Reuse check:** What existing code already solves each sub-problem? Can we reuse rather than rebuild?
2. **Minimum change set:** What is the minimum set of changes that achieves the goal? Flag scope creep.
3. **Complexity check:** >8 files or >2 new classes/services = smell. Challenge it.
4. **Search check:** For each architectural pattern, does the runtime/framework have a built-in? Is the approach current best practice? Known footguns?
5. **Completeness check:** Is the plan doing the complete version or a shortcut?

If the complexity check triggers, recommend scope reduction. Present options via the question tool. Once the user accepts or rejects, commit fully and don't re-argue.

## Review Sections

**Anti-skip rule:** Never skip any section. If zero findings, say "No issues found" and move on.

### Confidence Calibration

Every finding MUST include a confidence score (1–10):

| Score | Meaning | Display |
|-------|---------|---------|
| 9–10 | Verified by reading specific code | Show normally |
| 7–8 | High confidence pattern match | Show normally |
| 5–6 | Moderate confidence | Show with caveat |
| 3–4 | Low confidence | Suppress from main report, include in appendix |
| 1–2 | Speculation | Only report if P0 severity |

**Finding format:** `[SEVERITY] (confidence: N/10) file:line — description`

---

### Section 1: Architecture Review

Evaluate:

- System design, component boundaries, dependency graph
- Coupling and cohesion
- Data flow patterns, bottlenecks, scaling concerns
- Single points of failure
- Security architecture (auth, data access, API boundaries)

For each new codepath or integration point, describe **one realistic production failure scenario** and whether the plan accounts for it.

**STOP.** Ask the user about each issue individually via the question tool. One issue per question. Present options, state recommendation, explain WHY. Only proceed to next section after ALL issues resolved.

---

### Section 2: Code Quality Review

Evaluate:

- Code organization, module structure
- DRY violations (be aggressive)
- Error handling patterns
- Missing edge cases (call out explicitly)
- Technical debt hotspots
- Over-engineering vs under-engineering
- Check if existing ASCII diagrams in touched files are still accurate

**STOP.** Same pattern — one issue per question.

---

### Section 3: Test Review

This is the most detailed section. Trace every codepath.

**Step 1: Trace data flow.** For each planned component:

- Where does input come from?
- What transforms it?
- Where does it go?
- What can go wrong at each step?

**Step 2: Map user flows.** Identify:

- User flow sequences that touch this code
- Interaction edge cases (double-click, navigate away, stale data, slow connection)
- Error states the user can see
- Empty/zero/boundary states

**Step 3: Score coverage.** Check each branch against existing tests:

- ★★★ — Tests behavior with edge cases AND error paths
- ★★ — Tests correct behavior, happy path only
- ★ — Smoke test / existence check

**E2E Test Decision Matrix:**

| Recommend E2E | Stick with Unit |
|---------------|-----------------|
| Common user flow spanning 3+ components | Pure functions |
| Integration points where mocking hides failures | Internal helpers |
| Auth / payment / data-destruction flows | Edge cases of single function |

**REGRESSION RULE:** When coverage audit identifies a regression (existing behavior broken by diff), a regression test is MANDATORY. No skipping.

**Step 4: Output ASCII coverage diagram:**

```
CODE PATHS                                            USER FLOWS
[+] src/services/billing.ts                           [+] Payment checkout
  ├── processPayment()                                  ├── [★★★ TESTED] Complete purchase
  │   ├── [★★★ TESTED] happy + declined + timeout      ├── [GAP] [→E2E] Double-click submit
  │   └── [GAP]         Network timeout                 └── [GAP]        Navigate away
  └── refundPayment()
      └── [★   TESTED] Partial (non-throw only)

COVERAGE: 5/13 paths tested (38%)  |  Code paths: 3/5 (60%)  |  User flows: 2/8 (25%)
QUALITY: ★★★:2 ★★:2 ★:1  |  GAPS: 8 (2 E2E)
```

**Step 5: Add missing tests to the plan.** For each GAP: what test file, what to assert, unit vs E2E.

**STOP.** Same pattern — one issue per question.

---

### Section 4: Performance Review

Evaluate:

- N+1 queries
- Database access patterns
- Memory usage
- Caching opportunities
- Slow or high-complexity code paths

**STOP.** Same pattern — one issue per question.

## Required Outputs

### "NOT in scope" section

Work considered and explicitly deferred, with rationale.

### "What already exists" section

Existing code and flows that partially solve sub-problems.

### Diagrams

ASCII diagrams for non-trivial data flows, state machines, and pipelines.

### Failure modes

For each new codepath, one realistic failure and whether:

- A test covers it
- Error handling exists
- User sees a clear error or silent failure

If no test AND no error handling AND silent failure = **critical gap**.

### Worktree parallelization strategy

Analyze plan for parallel execution:

1. **Dependency table:** step, modules touched, depends on
2. **Parallel lanes:** independent steps in separate lanes
3. **Execution order**
4. **Conflict flags**

### Completion summary

```
- Step 0: Scope Challenge — [accepted/reduced]
- Architecture Review: ___ issues found
- Code Quality Review: ___ issues found
- Test Review: diagram produced, ___ gaps identified
- Performance Review: ___ issues found
- NOT in scope: written
- What already exists: written
- Failure modes: ___ critical gaps flagged
- Parallelization: ___ lanes, ___ parallel / ___ sequential
```

## Question Format

For every question asked via the question tool:

1. **Re-ground:** State the project, current branch, current task (1–2 sentences)
2. **Describe the problem** concretely with file/line references
3. **Present 2–3 options** including "do nothing" where reasonable
4. **State recommendation** with one-line reason WHY
5. **Number issues and letter options** (e.g., "3A", "3B")
6. **Escape hatch:** If obvious fix with no real alternatives, state what you'll do and move on

## Formatting Rules

- NUMBER issues (1, 2, 3...) and LETTERS for options (A, B, C...)
- One sentence max per option
- After each review section, pause and ask for feedback before moving on

## Unresolved Decisions

If the user doesn't respond to a question or moves on, note unresolved decisions at the end under: **"Unresolved decisions that may bite you later"**
