# Bugfix Skill — Detailed Instructions

## Stage 02: Reproduce & Diagnose

### Input
- `01-bug-intake/bug-report.md` — symptom, reproduction steps, expected vs actual
- Linked repo(s) from `manifest.yaml`
- Repo memory

### Process

**Step 1 — Reproduce the bug**
Follow the reproduction steps in `bug-report.md` exactly. If you cannot
reproduce it, stop and report `NEEDS_CONTEXT` with: what you tried, what
you got, what you expected. Do not proceed to root cause analysis if you
cannot reproduce.

**Step 2 — Identify impacted code paths**
- Search the repo for the symptom (grep for error messages, function names, route handlers)
- Trace the call path from the user action to the failure point
- Note every file, function, and data path involved
- Record findings in `02-reproduce/impacted-paths.md` with file paths and line numbers

**Step 3 — Identify root cause**
The root cause is the specific code or configuration change that, if fixed,
eliminates the bug. It is NOT "the payment service is broken." It IS:
"Line 47 of `PaymentService.ts` calls `charge()` without checking if the
user's card is expired; the card expiry check was removed in commit a1b2c3."

Write `02-reproduce/root-cause.md` — must answer:
- What is the root cause? (specific, traceable)
- When was it introduced? (commit, PR, deploy if determinable)
- Why does it cause the observed symptom?
- Are there other manifestations of the same root cause?

**Step 4 — Quality check before finishing**
- [ ] Root cause is specific (file + line or config key, not a vague description)
- [ ] Impacted paths are listed with file paths
- [ ] Bug is reproducible (or explicitly noted as not reproducible with reason)
- [ ] No `{{placeholder}}` tokens remain

### Output summary to Orchestrator
```
Reproduce & Diagnose complete.

Root cause: [one sentence]
Impacted files: [count]
Reproducible: yes / no (reason if no)

Artifacts:
- 02-reproduce/root-cause.md
- 02-reproduce/impacted-paths.md

Gate status: PASS / FAIL
```

---

## Stage 03: Fix Plan

### Input
- `02-reproduce/root-cause.md`
- `02-reproduce/impacted-paths.md`
- `01-bug-intake/bug-report.md`
- Repo memory (conventions, test patterns)

### Process

**Step 1 — Design the minimal fix**
The fix must address the root cause and nothing else. Do not refactor
surrounding code, rename variables, or "improve" code you're reading.
Bug fixes that also refactor are harder to review and harder to revert.

Write `03-fix-plan/fix-plan.md`:
- Fix approach: exactly what changes to make and why
- Files to touch: explicit list (same format as task files in feature mode)
- Acceptance criteria: how to verify the bug is fixed
- Test requirements: what test(s) prove the fix works

**Step 2 — Identify regression risks**
For each file in the fix plan, ask: what else uses this code?
Write `03-fix-plan/regression-risks.md`:
- List callers/consumers of changed code
- Note any edge cases the fix might break
- Flag if the fix requires a migration or data change

**Step 3 — Quality check**
- [ ] Fix approach is specific — not "update the payment logic" but "add expiry check before calling `stripe.charge()`"
- [ ] Acceptance criteria are testable
- [ ] Regression risks are listed even if assessed as low
- [ ] Fix is scoped to the root cause — no scope creep

### Output summary to Orchestrator
```
Fix Plan complete.

Fix approach: [one sentence]
Files to touch: [count]
Regression risks identified: [count]

Artifacts:
- 03-fix-plan/fix-plan.md
- 03-fix-plan/regression-risks.md

Gate status: PASS / FAIL
```
