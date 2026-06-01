# Target Design Gate Checklist — Stage 03 (refactor)

## Hard Gates

- [ ] **`03-target-design/target-design.md` exists and is non-empty**

- [ ] **Target structure is explicit**
  - New files/modules named (not "split into smaller files")
  - Each module has a stated responsibility

- [ ] **Consumer impact addressed**
  - target-design.md states what changes for code that currently calls the refactored area

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 03-target-design/
  ```

## Soft Gates

- [ ] **At least one ADR in `03-target-design/adrs/`**
