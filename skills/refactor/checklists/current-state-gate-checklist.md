# Current State Gate Checklist — Stage 02 (refactor)

## Hard Gates

- [ ] **`02-current-state/current-state.md` exists and is non-empty**

- [ ] **Pain points are specific**
  - Must reference files/lines or measurable problems
  - Failure: "the code is hard to understand"
  - Pass: "UserService.ts:L120–280 contains billing logic unrelated to its name"

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 02-current-state/
  ```

## Soft Gates

- [ ] **`02-current-state/impacted-files.md` exists and lists file paths**

- [ ] **Consumer files listed** (not just the files being changed)
