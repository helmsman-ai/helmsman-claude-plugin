# Fix Plan Gate Checklist — Stage 03 (bugfix)

> Load at gate-check time. Hard failures block advance.

## Hard Gates

- [ ] **`03-fix-plan/fix-plan.md` exists and is non-empty**

- [ ] **Fix approach is specific**
  - Must name the exact change: which function, what logic, what value
  - Failure: "fix the payment logic"
  - Pass: "add `if card.expiry < today: raise CardExpiredError` before stripe.charge()"

- [ ] **Acceptance criteria present and testable**
  - At least one checkbox AC in fix-plan.md
  - Must be verifiable (not "the bug is fixed")

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 03-fix-plan/
  ```

## Soft Gates

- [ ] **`03-fix-plan/regression-risks.md` exists and is non-empty**

- [ ] **Files-to-touch list present** in fix-plan.md
