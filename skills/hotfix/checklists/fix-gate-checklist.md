# Fix Gate Checklist — Stage 02 (hotfix)

> In fast_track mode, hard gate failures WARN instead of block.
> Gate results are still recorded in state.yaml for the audit trail.

## Hard Gates (warn in fast_track)

- [ ] **Tests pass**
  - Run the test suite for affected files
  - Failure (warn): tests failing — proceed but flag to developer

- [ ] **At least one new test added**
  - The fix must have a test that reproduces the bug
  - Failure (warn): no new tests — proceed but flag

## Soft Gates (silent in fast_track)

- [ ] **`02-fix/notes.md` exists**

- [ ] **Commit message references incident ID**
  ```bash
  git log -1 --format="%s" | grep -i "incident\|fix\|hotfix"
  ```
