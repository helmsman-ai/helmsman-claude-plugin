# Code Review Gate Checklist — Stage 07

> Checked by Orchestrator after reviewer produces report.
> Hard failures route back to Implementer before presenting to developer.

---

## Hard Gates (per task review)

- [ ] **Review report exists**
  - Path: `07-review/self-review-NNN-<slug>.md`
  - Failure: file missing

- [ ] **All acceptance criteria have a verdict**
  - Every AC from the task file must be marked ✅, ❌, or ⚠️ in the report
  - Failure: any AC row missing or blank

- [ ] **No Critical (🔴) issues are open**
  - If Critical issues exist: Implementer must fix → re-review before developer sees it
  - Failure: report contains Critical issues with no resolution

- [ ] **Verdict is consistent with issues**
  - FAIL if any Critical issue exists
  - FAIL if any acceptance criterion is ❌
  - Failure: PASS verdict with Critical issues, or vice versa

- [ ] **No `{{placeholder}}` tokens in report**
  - Run: `grep "{{" 07-review/self-review-NNN-<slug>.md`

---

## Soft Gates (per task review)

- [ ] **Security checklist is fully marked**
  - Warn if any security checklist item is left blank

- [ ] **Major issues are addressed before developer review**
  - Warn developer of Major issues; they decide whether to fix before proceeding

- [ ] **File:line references for all issues**
  - Warn if any issue row is missing a file path and line number

---

## Stage-Level Gate (before advancing to Stage 08)

- [ ] **All task reviews have verdict PASS or PASS WITH COMMENTS**
  - Check: all `07-review/self-review-*.md` files exist and have a PASS verdict
  - Failure: any task review with FAIL verdict that was not subsequently resolved
