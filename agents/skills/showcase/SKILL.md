---
name: showcase
description: Create a native-fidelity HTML showcase with multiple design alternatives before implementing UI code.
user-invocable: true
argument-hint: "[TARGET=<screen|component>] [VARIANTS=<number>] [OUTPUT=<path>]"
---

Create a self-contained HTML showcase that lets the user compare design directions before any production UI implementation.

The output should feel as close as possible to the native experience for the target surface.

## MANDATORY PREPARATION

Use the `frontend-design` skill first. It provides design constraints, anti-pattern checks, and context protocol.

If project design context is missing, run `teach-impeccable` before continuing.

---

## What This Skill Produces

One HTML file containing:

1. **Baseline** (current/native-like implementation)
2. **Alternative variants** (usually 2-4)
3. **State toggles** for realistic evaluation (loading, empty, error, normal)
4. **Theme toggles** when relevant (light/dark)

This is a decision artifact, not production code.

## Fidelity Requirements (Critical)

The showcase must mirror native behavior and feel as closely as possible:

- Match the real container size (e.g., panel/window width/height)
- Match typography stack, text sizing, spacing scale, and density
- Match color tokens and contrast behavior (including dark mode)
- Match interaction states (hover/focus/active/disabled where relevant)
- Match truncation, wrapping, and information hierarchy
- Match motion style and respect `prefers-reduced-motion`
- Use realistic content and edge cases from the actual app model

If exact parity is impossible in plain HTML, document the gap clearly at the top of the file.

## Workflow

### 1) Extract Native Constraints

Read the target implementation files and pull concrete constraints:

- Container dimensions and layout limits
- Existing tokens/variables
- Existing component structure
- Real state variants (loading/empty/error/success)
- Data shape used by the UI

Do not invent arbitrary styles if native ones exist.

### 2) Define Variant Axes

Generate alternatives with intentional differences (not cosmetic noise), e.g.:

- Density (compact vs relaxed)
- Hierarchy emphasis (headline-first vs signal-first)
- Field representation (chips vs rows vs inline)
- Error visibility (inline vs banner vs grouped)

Each variant should have a short “why” note.

### 3) Build the Showcase HTML

Create a single self-contained HTML file with inline CSS and JS.

Requirements:

- No build step required
- No external dependency required
- Keyboard/mouse operable controls for toggles
- Accessibility basics (labels, semantics, visible focus states)
- Small fixture dataset in-script that mimics real app payloads

Recommended structure:

- Top controls: state/theme toggles
- Variant switcher or side-by-side variants
- Native-size frame wrapper per variant
- Optional notes section for trade-offs

### 4) Save + Report

Default output path (if not provided):

- `showcases/<target>-showcase.html`

Return:

- Output file path
- Brief variant summary
- Known fidelity gaps
- Suggested next direction

## Quality Bar

Use this checklist before returning:

- [ ] Variants are meaningfully different
- [ ] Content is realistic (not lorem ipsum unless unavoidable)
- [ ] Edge states are represented
- [ ] Visual density and rhythm are intentional
- [ ] Native parity is close enough for decision-making
- [ ] The file opens directly in a browser and works without tooling

## Never Do

- Don’t implement production app code while running this skill
- Don’t produce generic “dribbble shots” disconnected from app constraints
- Don’t ignore accessibility or keyboard interaction
- Don’t hide major parity gaps
- Don’t use fake interactions that imply unsupported native behavior

## Suggested Prompt Patterns

- `/showcase TARGET=menubar-feed-panel VARIANTS=3`
- `/showcase TARGET=settings-screen VARIANTS=4 OUTPUT=showcases/settings-v2.html`
- `/showcase TARGET=activity-row VARIANTS=5`
