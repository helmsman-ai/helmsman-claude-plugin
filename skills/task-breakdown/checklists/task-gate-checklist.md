# Task Breakdown Gate Checklist — Stage 05

> Load at gate-check time only. Hard failures block `/advance`.

---

## Hard Gates

- [ ] **`INDEX.md` exists** and contains a dependency graph
  - Path: `05-tasks/INDEX.md`
  - Failure: file missing, or dependency graph section is empty

- [ ] **Every task file has all required sections**
  - Goal · Context · Files to Touch · Acceptance Criteria · Test Requirements · Dependencies
  - Spot-check: open first, middle, and last task file
  - Failure: any required section missing or contains `{{placeholder}}`

- [ ] **Every task has ≥ 1 acceptance criterion**
  - Failure: any task file with no acceptance criteria checkboxes

- [ ] **Every task has ≥ 1 test requirement**
  - Failure: any task file with no test requirements
  - Exception (must be explicit): pure infrastructure tasks (e.g., "update config file") — must note "no tests needed because X"

- [ ] **No circular dependencies**
  - Manually trace: does any task depend on a task that (directly or transitively) depends on it?
  - Failure: any circular chain found

- [ ] **No `{{placeholder}}` tokens remain**
  - Run: `grep -r "{{" 05-tasks/`
  - Failure: any unreplaced tokens

- [ ] **Every PRD acceptance criterion is assigned to a task**
  - List ACs from `02-prd-clean/clean-prd.md`
  - For each: find it (or its derivative) in a task file
  - Failure: any AC with no corresponding task coverage

---

## Soft Gates

- [ ] **No task exceeds 6 acceptance criteria**
  - Warn: task may be too large; suggest splitting

- [ ] **Total task count matches effort estimate in design**
  - Warn if task count is significantly higher or lower than expected from the design

- [ ] **INDEX.md dependency graph matches task file dependency fields**
  - Warn if graph and per-file `Dependencies` fields are inconsistent

- [ ] **Effort estimates present on all tasks**
  - Warn if any task file has no effort estimate
