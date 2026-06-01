# Change Impact Report — {{project_name}}

> **Generated**: {{YYYY-MM-DD HH:MM}}
> **Triggered by**: Jump-back from `{{from_stage}}` to `{{to_stage}}`
> **Reason**: {{jump_back_reason}}
> **Upstream diffs reviewed**:
>   - `{{diff_path_1}}`
>   - `{{diff_path_2}}`

---

## What Changed Upstream

For each stage that was propagated, summarize the delta and its implementation implications.

### Stage `{{stage-id}}` — {{stage-label}}

{{2-4 sentences describing what changed in this stage's artifacts. Focus on
implementation implications: new constraints, removed features, changed APIs,
renamed components, updated data models, interface changes.}}

Key changes:
- **{{change_1}}**: {{one-line implementation implication}}
- **{{change_2}}**: {{one-line implementation implication}}

Diff: `.snapshots/{{snapshot-id}}/DIFF.md`

---

## Affected Tasks

One entry per task in the task stage directory. Every task must appear — even tasks categorized as `leave`.

### Task {{NNN}} — {{task_title}}

**Category**: `redo`

**Reason**: {{1-2 sentences explaining why this task needs significant rework — which upstream change invalidates its core approach or scope.}}

**Required changes**:
- {{specific change 1 — be concrete, not vague}}
- {{specific change 2}}

**Estimated effort**: small | medium | large
<!-- small = 1–2 files, cosmetic changes; medium = multiple files, logic changes; large = architectural rework or significant scope change -->

---

### Task {{NNN}} — {{task_title}}

**Category**: `amend`

**Reason**: {{1-2 sentences explaining why minor updates are needed — e.g., a function name changed, a new constraint was added, an interface was updated.}}

**Required changes**:
- {{specific change — e.g., "Update call sites from `getSession()` to `verifyJWT()`"}}

**Estimated effort**: small | medium | large
<!-- small = 1–2 files, cosmetic changes; medium = multiple files, logic changes; large = architectural rework or significant scope change -->

---

### Task {{NNN}} — {{task_title}}

**Category**: `leave`

**Reason**: This task operates on `{{component_or_area}}` which was not affected by the upstream changes. No changes needed.

---

## Summary

| Category | Count | Task IDs |
|---|---|---|
| `leave` | {{N}} | {{comma-separated task IDs, e.g. 001, 004, 007}} |
| `amend` | {{N}} | {{comma-separated task IDs}} |
| `redo`  | {{N}} | {{comma-separated task IDs}} |

**Total tasks reviewed**: {{total}}

---

## Recommended Next Steps

1. {{Specific first recommendation — e.g., "Start with Task {{NNN}} (redo) as it is a prerequisite for Tasks {{NNN}} and {{NNN}}."}}
2. {{Second recommendation — e.g., "Tasks {{NNN}} and {{NNN}} (amend) can be done in parallel."}}
3. Run `/approve {{impl-stage}}/change-impact-report.md` to acknowledge this report, then use `/advance` to resume the pipeline.

---

> **Important**: This report does not modify any implementation files or restart the
> implementation loop. After acknowledging it with `/approve`, decide which tasks to
> re-run and resume the pipeline with `/advance`.
