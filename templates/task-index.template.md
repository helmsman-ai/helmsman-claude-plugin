# Task Index — {{project_name}}

> **Stage**: 05-tasks
> **Produced by**: Architect agent
> **Last updated**: {{date}}
>
> This is the ordered, dependency-aware list of all implementation tasks.
> Each task has its own file: `NNN-<slug>.md`.
> The Implementer works through tasks in the order listed here, respecting dependencies.

---

## Summary

| Stat | Value |
|---|---|
| Total tasks | {{total_count}} |
| Estimated effort | {{total_effort}} |
| Critical path | {{critical_path_tasks}} |

---

## Task List

| # | Task | Depends on | Effort | Status | Notes |
|---|---|---|---|---|---|
| [001](001-{{slug}}.md) | {{title}} | — | {{effort}} | pending | |
| [002](002-{{slug}}.md) | {{title}} | 001 | {{effort}} | pending | |
| [003](003-{{slug}}.md) | {{title}} | 001, 002 | {{effort}} | pending | |

**Status values**: `pending` · `in-progress` · `in-review` · `complete`

---

## Dependency Graph

```
001 ──► 002 ──► 004
         │
         └──► 003 ──► 005
```

> Update this graph when tasks are split or merged.

---

## Parallelizable Groups

> Tasks that can be worked on simultaneously once their dependencies are met.

| Wave | Tasks | Unblocked after |
|---|---|---|
| Wave 1 | 001 | (start) |
| Wave 2 | 002, 003 | 001 complete |
| Wave 3 | 004, 005 | Wave 2 complete |
