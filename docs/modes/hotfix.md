# Hotfix Mode ⚡

> **Use when:** Production is broken or severely degraded and every minute
> of delay has real user or business impact.
>
> **Not for:** Non-urgent bugs. Anything that can wait for a normal bugfix cycle.
> "This is annoying" ≠ hotfix.

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| Production down / P1 incident | **hotfix** |
| Serious bug, can deploy in hours | **hotfix** |
| Bug is real but can wait until tomorrow | bugfix |
| Security vulnerability with active exploit | **hotfix** |

## Pipeline ⚡ Auto-advancing

```
01-intake → 02-fix → 03-review → 04-deploy
```

| Stage | Agent | Key Artifacts | Est. Time |
|---|---|---|---|
| 01 Incident Intake | Orchestrator | `incident.md` | 5 min |
| 02 Fix | Implementer | Code commit, `02-fix/notes.md` | 15–60 min |
| 03 Review | Reviewer | `self-review.md` | 10 min |
| 04 Deploy | Orchestrator | `dossier.md` | 5 min |

## fast_track Behavior

This mode has `fast_track: true`:

| Normal pipeline | Hotfix pipeline |
|---|---|
| Hard gate fails → blocked | Hard gate fails → warning only |
| Wait for `/approve` between stages | Auto-advances after each agent completes |
| Developer controls pace | Pipeline runs as fast as agents can work |

**You retain full control:** Run `/comment` at any point to pause. Run
`/approve` to confirm a step explicitly. The audit trail is fully preserved.

## Gate Summary (all warn in fast_track)

| Stage | Hard Gates (warn) |
|---|---|
| 01 | has_incident_description |
| 02 | tests_pass |
| 03 | no_critical_issues |
| 04 | — |

## Quick Start

```
/start-project redis-oom-p1 --mode hotfix --repo infra
```

## Tips

- Keep the fix scope minimal. A hotfix that refactors is harder to revert.
- Even in fast_track: **write at least one test**. This is the one rule that
  holds even in emergencies.
- After the hotfix is deployed, consider creating a bugfix or refactor project
  to address the root cause properly.
