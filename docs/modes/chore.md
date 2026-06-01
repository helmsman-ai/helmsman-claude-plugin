# Chore Mode

> **Use when:** You need to do maintenance work with no design or research
> phase — dependency bumps, config changes, tooling updates, cleanup tasks.
>
> **Not for:** Anything that changes behavior or requires architectural thought.
> If you're unsure, use feature or refactor mode instead.

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| Bumping a dependency version | **chore** |
| Updating CI config | **chore** |
| Renaming files / reorganizing imports | **chore** |
| Fixing a bug | bugfix |
| Restructuring a module | refactor |

## Pipeline

```
01-intake → 02-implementation → 03-review → 04-close
```

| Stage | Agent | Key Artifacts | Est. Time |
|---|---|---|---|
| 01 Chore Intake | Orchestrator | `chore-description.md` | 10 min |
| 02 Implementation | Implementer | Code commits | 15–60 min |
| 03 Review | Reviewer | `self-review.md` (reduced checklist) | 10 min |
| 04 Close | Orchestrator | `dossier.md` | 5 min |

The reviewer uses a **reduced checklist** — security and architecture sections
are skipped. Focus is on completeness and side effects.

## Gate Summary

| Stage | Hard Gates | Soft Gates |
|---|---|---|
| 01 | has_chore_description | — |
| 02 | — | lint_clean |
| 03 | no_critical_issues | completeness_check |
| 04 | — | — |

## Quick Start

```
/start-project bump-node-18 --mode chore --repo web-api
```

## Tips

- If the chore turns out to require architectural decisions, stop and switch
  to feature or refactor mode.
- Always include a rollback plan in `chore-description.md` — even "revert
  the commit" is sufficient for simple chores.
