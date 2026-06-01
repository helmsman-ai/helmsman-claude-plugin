# Feature Mode

> **Use when:** You are building something new — a new feature, a significant
> new behavior, or an entirely new user-facing capability.
>
> **Not for:** Bug fixes (use bugfix), structural code changes with no new behavior
> (use refactor), or production emergencies (use hotfix).

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| New feature or significant new behavior | **feature** |
| Fix a known, confirmed bug | bugfix |
| Restructure existing code, behavior unchanged | refactor |
| Answer a technical question before committing | spike |
| Test a hypothesis, then ship/discard | experiment |
| Production down, every minute costs | hotfix |
| Dependency bump, config, tooling | chore |

## Pipeline

```
01-prd → 02-prd-clean → 03-discovery → 04-tech-design → 05-tasks → 06-implementation → 07-review → 08-pre-launch → 09-launch
```

| Stage | ID | Agent | Key Artifacts | Est. Time |
|---|---|---|---|---|
| PRD Intake | 01-prd | — | `input.md` (your raw PRD) | 5 min |
| PRD Review | 02-prd-clean | PRD Reviewer | `clean-prd.md`, `assumptions.md`, `risks.md`, `open-questions.md`, `out-of-scope.md` | 15–30 min |
| Discovery | 03-discovery | Researcher | `codebase-findings.md`, `stakeholder-map.md`, `dependencies.md`, `prior-art.md`, `open-questions.md` | 30–60 min |
| Tech Design | 04-tech-design | Architect | `design.md`, `alternatives.md`, `adrs/` | 30–60 min |
| Task Breakdown | 05-tasks | Architect | `task-index.md`, `NNN-<slug>.md` per task | 20–30 min |
| Implementation | 06-implementation | Implementer | Code commits, `progress.md`, `task-notes/` | varies |
| Code Review | 07-review | Reviewer | `self-review-NNN-<slug>.md` per task | 15 min/task |
| Pre-Launch | 08-pre-launch | — | Pre-mortem sign-off, rollback plan | 15 min |
| Launch | 09-launch | — | `dossier.md` | 5 min |

## Gate Summary

| Stage | Hard Gates | Soft Gates |
|---|---|---|
| 01 PRD Intake | — | — |
| 02 PRD Review | `has_goals`, `has_acceptance_criteria` | `has_user_stories`, `has_constraints` |
| 03 Discovery | — | `has_decision_makers` |
| 04 Tech Design | `has_2_alternatives`, `has_risks_section` | `has_adrs` |
| 05 Task Breakdown | `each_task_has_acceptance_criteria`, `dependency_graph_valid` | — |
| 06 Implementation | `tests_pass` | `lint_clean` |
| 07 Code Review | `no_critical_issues` | — |
| 08 Pre-Launch | `pre_mortem_complete`, `rollback_plan_exists` | — |
| 09 Launch | — | — |

See [GATES.md](../GATES.md) for what each gate ID checks and how to act when blocked.

## Quick Start

```
/start-project payments-v2 --mode feature --repo payments-service
```

## Tips

- Write the rawest version of your PRD for Stage 01. The PRD Reviewer's job
  is to clean it up — over-polishing before Stage 02 is wasted effort.
- Stage 03 (Discovery) often surfaces surprises — a similar feature already
  exists, a service you didn't know about is involved. Let the Researcher finish
  before you pre-decide architecture.
- The two-alternatives hard gate in Stage 04 (`has_2_alternatives`) is
  intentional: it prevents the Architect from skipping straight to the obvious
  solution. The alternative you reject often teaches you something.
- Stages 08 and 09 have no agents. They exist to force a deliberate pause:
  you, as the developer, own the pre-mortem and the launch decision.
