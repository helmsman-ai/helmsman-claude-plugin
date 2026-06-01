# ISSUE-001: `/helmsman-init` token usage is high for the work it does

**Type:** Observation
**Component:** commands / helmsman-init
**Command / Trigger:** `/helmsman-init` in an empty directory

## Observed

Total session usage after a single init run:

| Metric | Value |
|---|---|
| In | 30 |
| Out | 655 |
| Cache read | 719.9k |
| Cache write | 90.8k |
| **Total** | **~811.4k** |

## Notes

For a scaffolding command that only creates directories and writes a few YAML/markdown files, this is a large token footprint. Worth investigating whether the init skill loads too much context (e.g., large templates, full plugin manifest, or unnecessary agent instructions) that could be trimmed or deferred.

## Resolution

**Status:** resolved  
**Fixed in:** `helmsman/commands/helmsman-init.md` — Steps 3, 5, and 6  
**Summary:** Replaced file-read-based copy instructions with explicit `cp -n` shell commands (Steps 3 and 5) so the 37 template files and the repo-claude template never enter model context; inlined the hook descriptions directly in Step 6 so `docs/HOOKS.md` (285 lines) is no longer read on demand.
