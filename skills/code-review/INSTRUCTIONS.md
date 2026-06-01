# Code Review — Detailed Instructions

> Load this file when doing the work. `SKILL.md` is the summary.

---

## Inputs

- `05-tasks/NNN-<slug>.md` — the task spec (what should have been built)
- `06-implementation/task-notes/NNN-<slug>.md` — Implementer's notes and deviations
- The committed diff or changed files (specified by Orchestrator)
- Repo memory — conventions, architectural rules, test patterns

---

## Process

### Step 1 — Acceptance criteria check

This is the most important step. If acceptance criteria are not met, nothing else matters.

For each acceptance criterion in the task file:
1. Find the code that satisfies it — read the actual implementation, not just the tests
2. Verify it is correct, not just that it exists
3. Mark: ✅ met / ❌ not met / ⚠️ partially met (describe what's missing)

Any ❌ → verdict is `FAIL` immediately. Complete the rest of the review, but the verdict is already determined.

### Step 2 — Convention compliance

Check against repo memory conventions:

| Convention area | What to check |
|---|---|
| **Naming** | Variables, functions, files, DB columns match existing casing and vocabulary |
| **File placement** | New files are in the right directory/module |
| **Import style** | Matches codebase (named vs. default, relative vs. alias) |
| **Error handling** | Matches codebase pattern (throw, Result type, error codes) |
| **Logging** | Present where expected; absent where not |
| **Test naming** | Test descriptions are readable sentences; follow existing describe/it structure |
| **Commit message** | Follows repo convention (from repo memory) |

Convention violations are `Minor` unless they introduce inconsistency in public interfaces or shared utilities → `Major`.

### Step 3 — Correctness

Think like someone trying to break this code:

**Null and undefined**
- What if an optional parameter is omitted? Does the code handle `undefined`?
- What if a DB query returns no results? Does the code handle `null`?
- What if a list is empty?

**Failure handling**
- What if the external service call fails? Is the error caught, logged, and propagated correctly?
- What if it times out? Is there a timeout set?
- Are error messages safe for external consumers (no stack traces, no internal IDs)?

**Concurrent access**
- Can two requests running simultaneously cause a race condition?
- If there are multiple DB writes, what happens if the second one fails?
- Is there any shared mutable state that needs synchronization?

**Boundary conditions**
- Pagination: what happens at page 0? At a page beyond the last?
- Limits: what if the input is at exactly the max length? Over it?
- Timestamps: timezones? Daylight saving? UTC throughout?

### Step 4 — Security (every item is at least Major)

Work through this checklist for every changed file:

- [ ] **SQL injection**: any string concatenation in queries? Always parameterized?
- [ ] **Command injection**: any user input passed to shell commands?
- [ ] **Authentication**: new endpoints — are they protected? Check middleware chain.
- [ ] **Authorization**: can user A access user B's data through any path in this code?
- [ ] **Data exposure**: any internal field (internal ID, hash, sensitive status) leaking in an API response?
- [ ] **Secrets in code**: any hardcoded credential, key, token, or connection string?
- [ ] **Input validation**: user-supplied input used in file paths, queries, external calls — is it sanitized?
- [ ] **Logging sensitive data**: passwords, tokens, PII being logged?

### Step 5 — Test quality

Tests that don't catch bugs are worse than no tests — they create false confidence.

Check each new test:
- **Does it test behaviour or implementation?** A test that mocks 6 things and asserts that a specific internal method was called is testing implementation. A test that calls the public API and asserts the observable outcome is testing behaviour. Prefer the latter.
- **Does it actually test the acceptance criterion?** Read the AC, then read the test. Would this test fail if the AC were violated?
- **Are edge cases tested?** Not just the happy path.
- **Are mocks realistic?** A mock that always returns success doesn't test failure handling.
- **Test isolation**: does this test depend on test execution order? Database state from another test?

---

## Severity Assignment

Every issue must have a severity. Use it consistently.

| 🔴 Critical | Correctness/security bug; data loss risk; acceptance criterion unmet |
|---|---|
| 🟠 Major | Will likely cause a bug in production; significant convention violation; test doesn't verify what it claims |
| 🟡 Minor | Code quality; maintainability concern; test gap for non-critical path |
| 🔵 Nit | Style, naming preference, optional improvement |

**Security issues are always Critical or Major.** No security issue is a Nit.
**Unmet acceptance criteria are always Critical.**
A cluster of 4+ Major issues can justify FAIL verdict even without any Critical.

---

## Writing the Review Report

Use `templates/self-review.template.md`. Fill every section:

- **Verdict first** — PASS / PASS WITH COMMENTS / FAIL
- **Acceptance criteria table** — row per criterion, ✅/❌/⚠️
- **Issues table** — every issue, sorted by severity descending
- **Security checklist** — mark each item explicitly
- **Edge cases** — what did you check?
- **Test coverage** — count, quality assessment
- **Reviewer notes** — your overall take; what's good, what's concerning

Be specific with file paths and line numbers. "There's a null pointer risk in the service" is not useful. "In `src/services/PaymentService.ts:L52`, `transaction` could be null if `findByIdempotencyKey` returns no result, but it is dereferenced without a null check" is actionable.

---

## Quality Checks Before Finishing

- [ ] Every acceptance criterion has a verdict (✅/❌/⚠️)
- [ ] Every issue has a severity and a file:line reference
- [ ] Security checklist is fully filled (no unchecked items)
- [ ] Verdict matches the issues found (FAIL if any 🔴 Critical)
- [ ] No `{{placeholder}}` tokens remain in the review report

---

## Output Summary to Orchestrator

```
Review complete.

Verdict: PASS / PASS WITH COMMENTS / FAIL
Artifact: 07-review/self-review-NNN-<slug>.md

Issues:
- Critical: N
- Major: N
- Minor: N
- Nits: N

[If FAIL] Must fix before developer review:
  - [brief description of critical issues]

[If PASS WITH COMMENTS] Notable for developer:
  - [brief description of major/minor items]
```
