# Reproduce & Diagnose Gate Checklist — Stage 02 (bugfix)

> Load at gate-check time. Hard failures block advance.

## Hard Gates

- [ ] **`02-reproduce/root-cause.md` exists and is non-empty**

- [ ] **Root cause is specific**
  - Must name a file, function, config key, or data condition
  - Failure: "the payment code has a bug" — too vague
  - Pass: "PaymentService.ts:47 — expiry check removed in commit a1b2c"

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 02-reproduce/
  ```

## Soft Gates

- [ ] **`02-reproduce/impacted-paths.md` exists and lists file paths**

- [ ] **Reproduction confirmed** — root-cause.md states bug was reproduced
  - Warn if not reproducible; do not block (intermittent bugs are real)
