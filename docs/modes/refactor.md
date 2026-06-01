# Refactor Mode

> **Use when:** You need to restructure existing code without changing its
> observable behavior — to improve maintainability, testability, or clarity.
>
> **Not for:** Fixing bugs (use bugfix). Adding features (use feature).
> Emergency cleanup (if it can wait a week, it's not a hotfix).

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| Restructuring code, behavior unchanged | **refactor** |
| Fixing a concrete bug | bugfix |
| Building something new | feature |
| "Should we even refactor this?" — unknown | spike |

## Pipeline

```
01-intake → 02-current-state → 03-target-design → 04-migration-plan → 05-implementation → 06-review → 07-launch
```

| Stage | Agent | Key Artifacts | Est. Time |
|---|---|---|---|
| 01 Intake | Orchestrator | `motivation.md`, `scope.md` | 15 min |
| 02 Current State | Researcher | `current-state.md`, `impacted-files.md` | 1–2 hrs |
| 03 Target Design | Architect | `target-design.md`, `adrs/` | 1–2 hrs |
| 04 Migration Plan | Architect | `INDEX.md`, task files | 30–60 min |
| 05 Implementation | Implementer | Code commits, `progress.md` | varies |
| 06 Code Review | Reviewer | `self-review-<task>.md` | per task |
| 07 Launch | Orchestrator | `dossier.md` | 5 min |

## Gate Summary

| Stage | Hard Gates | Soft Gates |
|---|---|---|
| 01 | has_motivation, has_scope | — |
| 02 | has_pain_points | has_impacted_files |
| 03 | has_target_design | has_adrs |
| 04 | each_task_has_acceptance_criteria, dependency_graph_valid | — |
| 05 | tests_pass | lint_clean |
| 06 | no_critical_issues | — |
| 07 | rollback_plan_exists | — |

## Quick Start

```
/start-project auth-service-refactor --mode refactor --repo web-api
```

## Tips

- Stage 02 is critical: "the code is messy" is not a pain point. Cite
  files, line ranges, and the concrete problem they cause.
- Stage 04 (migration plan) must decompose into steps each independently
  mergeable. Refactors fail when they become "big bang" changes.
- Verify behavior preservation with tests — if there are none, writing them
  is part of the refactor, not a bonus.
