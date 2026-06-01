# Implementation Gate Checklist — Stage 06

> Checked by Orchestrator after each task is marked `in-review` and before presenting to developer.
> Hard failures route back to Implementer. Soft failures warn the developer.

---

## Hard Gates (per task)

- [ ] **All tests pass**
  - Run: `<test command from repo memory>`
  - Failure: any test suite failure, including pre-existing tests broken by this task

- [ ] **Task committed to correct branch**
  - Branch: `helmsman/<project-name>`
  - Failure: code not committed, or committed to wrong branch

- [ ] **`progress.md` updated**
  - Task status changed to `in-review`
  - Commit SHA recorded
  - Failure: progress file not updated

- [ ] **All task acceptance criteria addressed**
  - Each criterion from the task file must have corresponding code or test
  - Check `task-notes/` for any deviations — deviations must be noted, not silently omitted
  - Failure: any AC with no corresponding implementation or explicit note

---

## Soft Gates (per task)

- [ ] **Lint clean**
  - Run: `<lint command from repo memory>`
  - Warn: any lint errors present (warnings are acceptable if noted)

- [ ] **`task-notes/NNN-<slug>.md` written**
  - Warn if missing — especially if there were any deviations from spec

- [ ] **No debugging artifacts**
  - Run: `grep -r "console\.log\|debugger\|TODO\|FIXME\|HACK" <changed files>`
  - Warn for each hit; developer decides whether to remove before merge

- [ ] **Test count reasonable**
  - Warn if task required 3+ acceptance criteria but only 1 test was added

---

## Stage-Level Gate (before advancing to Stage 07)

- [ ] **All tasks in INDEX.md are `complete`**
  - Check `progress.md` — every task must show `complete` status
  - Failure: any task still `pending`, `in-progress`, or `blocked`
