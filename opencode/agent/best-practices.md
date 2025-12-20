# Code Best Practices

All agents must enforce these standards. Reference this file rather than duplicating.

## Structure

- **1 file = 1 class** — Each file contains a single class/module
- **Single responsibility** — Each class does one thing well
- **500-line soft limit** — Flag files over 500 lines, but allow exceptions for cohesive classes (e.g., complex state machines)
- **Clear naming** — File names reflect the class/module they contain

## Dependencies

- **Constructor injection** — All dependencies passed via constructor, no hidden dependencies
- **Explicit over implicit** — Dependencies should be visible in the constructor signature
- **No service locators** — Avoid hidden singletons or global state

## Error Handling (Hybrid Approach)

- **Fail fast for bugs** — Throw/raise for programming errors (null where not expected, invalid state)
- **Result types for expected errors** — Return error types for expected failure cases (not found, validation failed, network error)
- **No silent failures** — Never swallow errors without logging or handling

## Documentation

- **Document public APIs** — Public methods/functions get brief doc comments
- **Document module purpose** — Each file has a 1-2 line header comment explaining its role
- **Skip the obvious** — No comments for self-explanatory code; prefer clear naming
- **Explain "why" not "what"** — Comments should explain reasoning, not describe code

### File Header Example
```
# UserRepository — Handles user persistence and retrieval.
# Uses PostgreSQL via SQLAlchemy.
```

### Comment Example
```python
# Good: Explains WHY
# Using binary search because dataset exceeds 10k items

# Bad: Explains WHAT (obvious from code)
# Loop through the array
```

## Testing

- **Isolated and atomic** — Each test is independent, no shared mutable state
- **AAA pattern** — Arrange, Act, Assert in every test
- **Shared fixtures OK** — Use setup/fixtures for common data to reduce duplication
- **Meaningful names** — `test_<unit>_<scenario>_<expected_result>`
- **Test behavior, not implementation** — Tests verify what code does, not how

### Coverage Targets
- **New code**: 80% line coverage
- **Critical paths**: 100% branch coverage
- **Each public function**: At least 1 happy path + 1 error case

### Test File Location
Follow project conventions. If none exist:
- **Colocated**: `foo.ts` → `foo.test.ts` (JS/TS)
- **Separate directory**: `src/foo.py` → `tests/test_foo.py` (Python)
- **Same directory**: `foo.go` → `foo_test.go` (Go)
