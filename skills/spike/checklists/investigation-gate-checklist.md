# Investigation Gate Checklist — Stage 02 (spike)

## Soft Gates (warn only)

- [ ] **`02-investigation/codebase-findings.md` exists and is non-empty**

- [ ] **`02-investigation/external-research.md` exists**
  - Should cite at least one external source
  - Warn if empty: "External research not conducted — may miss relevant prior art"

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 02-investigation/
  ```
