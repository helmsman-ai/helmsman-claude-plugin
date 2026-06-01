# Spike Mode

> **Use when:** You have a specific technical question that must be answered
> before design or implementation can proceed.
>
> **Not for:** Implementing features. Fixing bugs. Open-ended exploration
> with no specific question.

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| "Can we use library X for Y?" | **spike** |
| "What's the best approach for Z?" | **spike** |
| "We know what to build, let's build it" | feature / bugfix |
| "We want to test if approach X works" | experiment |

## Pipeline

```
01-question → 02-investigation → 03-findings → 04-recommendation → 05-close
```

| Stage | Agent | Key Artifacts | Est. Time |
|---|---|---|---|
| 01 Question | Orchestrator | `question.md`, `success-criteria.md` | 10 min |
| 02 Investigation | Researcher | `codebase-findings.md`, `external-research.md` | 1–3 hrs |
| 03 Findings | Researcher | `findings.md`, `options.md` | 30–60 min |
| 04 Recommendation | Architect | `recommendation.md` | 30 min |
| 05 Close | Orchestrator | `dossier.md` | 5 min |

**No production code is produced in spike mode.**

## Gate Summary

| Stage | Hard Gates | Soft Gates |
|---|---|---|
| 01 | has_question, has_success_criteria | has_time_box |
| 02 | — | has_codebase_findings, has_external_research |
| 03 | has_findings | has_options |
| 04 | has_decision (ACCEPT/REJECT/DEFER) | — |
| 05 | — | — |

## Quick Start

```
/start-project websocket-feasibility --mode spike
```

## Tips

- A spike that ends with "it depends" has failed. The recommendation must
  contain a clear ACCEPT / REJECT / DEFER verdict.
- DEFER is a valid verdict — but it must specify *when* to revisit, not
  just "when we have more information."
- Set a time box in Stage 01 and respect it. An unbounded spike is a
  project, not a spike.
