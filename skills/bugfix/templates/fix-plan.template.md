# Fix Plan — {{project-name}}

## Fix Approach

{{One paragraph: what specifically changes, in which file/function, and why this fixes the root cause}}

## Files to Touch

| Action | File | What Changes |
|---|---|---|
| modify | `{{path/to/file}}` | {{what changes}} |

## Acceptance Criteria

- [ ] {{AC-01: specific, testable — e.g., "POST /charge with expired card returns HTTP 402 with code CARD_EXPIRED"}}
- [ ] {{AC-02}}

## Test Requirements

| Test | Type | What It Verifies |
|---|---|---|
| `{{test name}}` | unit | {{what it tests}} |
| `{{test name}}` | integration | {{what it tests}} |

## Scope Boundary

This fix touches ONLY the root cause identified in `02-reproduce/root-cause.md`.
The following related improvements are explicitly OUT OF SCOPE for this fix:
- {{item 1, or "None identified"}}
