# Bugfix Mode

> **Use when:** You have a confirmed bug — a specific symptom, reproduction
> steps, and a codebase to fix.
>
> **Not for:** Vague "something feels wrong" reports (use spike to investigate
> first). Emergency production incidents (use hotfix).

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| Bug confirmed, reproducible, non-urgent | **bugfix** |
| Bug confirmed, production down / critical impact | hotfix |
| "Something seems wrong" — not yet confirmed | spike |
| Fixing bad code structure (no user-visible bug) | refactor |

## Pipeline

```
01-bug-intake → 02-reproduce → 03-fix-plan → 04-implementation → 05-review → 06-launch
```

| Stage | Agent | Key Artifacts | Est. Time |
|---|---|---|---|
| 01 Bug Intake | Orchestrator | `bug-report.md`, `reproduction-steps.md` | 15 min |
| 02 Reproduce & Diagnose | Researcher | `root-cause.md`, `impacted-paths.md` | 30–60 min |
| 03 Fix Plan | Architect | `fix-plan.md`, `regression-risks.md` | 20–30 min |
| 04 Implementation | Implementer | Code commits, `progress.md` | varies |
| 05 Code Review | Reviewer | `self-review.md` | 15 min |
| 06 Launch | Orchestrator | `dossier.md` | 5 min |

## Gate Summary

| Stage | Hard Gates | Soft Gates |
|---|---|---|
| 01 | has_reproduction_steps, has_expected_vs_actual | has_affected_version |
| 02 | has_root_cause | has_impacted_code_paths |
| 03 | has_fix_approach | has_regression_risk |
| 04 | tests_pass | lint_clean |
| 05 | no_critical_issues | — |
| 06 | rollback_plan_exists | — |

## Quick Start

```
/start-project login-crash-ios --mode bugfix --repo mobile-app
```

## Tips

- If you can't reproduce the bug in Stage 02, **stop and escalate** — don't
  fix what you can't verify. Report `NEEDS_CONTEXT`.
- Keep Stage 03's fix scope minimal. A fix that also refactors is harder to
  revert and harder to review.
- The root cause must be specific: file + function/line, not "the payment code."
