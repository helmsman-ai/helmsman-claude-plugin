# Chore Skill — Detailed Instructions

## Stage 03: Review (reduced checklist)

### Input
- `01-intake/chore-description.md` — what the chore is supposed to do
- Code diff or relevant committed files

### Process

**Step 1 — Verify completeness**
Does the implementation match what `chore-description.md` specified?
- Dependency bump: is the version correct? Are all references updated?
- Config change: is every config file updated consistently?
- Tooling: does it run? Does it produce the expected output?

**Step 2 — Check for side effects**
Did the change touch anything beyond its stated scope?
- Unintended file changes
- Behavior changes in existing functionality
- Breaking changes for other developers on the team

**Step 3 — Produce review**
Write `03-review/self-review.md`. Structure:

```markdown
## Verdict: PASS / PASS WITH COMMENTS / FAIL

## Completeness Check
[Did the chore do what it said it would?]

## Side Effects Check
[Any unintended changes?]

## Issues
| # | Severity | File | Issue | Recommendation |
|---|---|---|---|---|
```

**Skip entirely:**
- Security analysis
- Architecture review
- Test coverage assessment

### Output to Orchestrator
```
Verdict: PASS / PASS WITH COMMENTS / FAIL
Issues: [count by severity]
Path: 03-review/self-review.md
```
