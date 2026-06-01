# Review Gate Checklist — Stage 03 (chore)

> Reduced checklist. Security and architecture sections are intentionally omitted.

## Hard Gates

- [ ] **`03-review/self-review.md` exists**

- [ ] **No critical issues** — verdict is not FAIL
  - Check: `grep "Verdict:" 03-review/self-review.md`
  - Failure: verdict is FAIL

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 03-review/
  ```

## Soft Gates

- [ ] **Completeness check present** in self-review.md

- [ ] **Side effects check present** in self-review.md
