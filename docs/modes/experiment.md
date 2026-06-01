# Experiment Mode

> **Use when:** You want to test a hypothesis by building something and
> measuring the result. The outcome determines whether to ship, discard, or pivot.
>
> **Not for:** Features you've already decided to ship. Questions that can
> be answered without building (use spike instead).

## When to Use This Mode vs. Alternatives

| Situation | Mode |
|---|---|
| "Will users engage with feature X?" | **experiment** |
| "Does approach Y improve metric Z?" | **experiment** |
| "Can we even build X?" | spike |
| "We know we're building X, let's do it" | feature |

## Pipeline

```
01-hypothesis → 02-design → 03-implementation → 04-results → 05-decision → 06-close
```

| Stage | Agent | Key Artifacts | Est. Time |
|---|---|---|---|
| 01 Hypothesis | Orchestrator | `hypothesis.md`, `success-metrics.md`, `time-box.md` | 20 min |
| 02 Design | Architect | `experiment-design.md` | 30–60 min |
| 03 Implementation | Implementer | Code commits, `progress.md` | varies |
| 04 Results | Researcher | `results.md`, `metrics.md` | 1–2 hrs |
| 05 Decision | Orchestrator | `decision.md` (SHIP/DISCARD/PIVOT) | 20 min |
| 06 Close | Orchestrator | `dossier.md` | 5 min |

## Gate Summary

| Stage | Hard Gates | Soft Gates |
|---|---|---|
| 01 | has_hypothesis, has_success_metrics, has_time_box | — |
| 02 | has_experiment_design | — |
| 03 | tests_pass | lint_clean |
| 04 | has_results, has_metrics_comparison | — |
| 05 | has_ship_decision (SHIP/DISCARD/PIVOT) | — |
| 06 | — | — |

## Quick Start

```
/start-project onboarding-v2-experiment --mode experiment
```

## Tips

- Write the hypothesis before designing the experiment. A hypothesis written
  after seeing results is post-hoc rationalization.
- DISCARD outcomes are as valuable as SHIP — document what you learned so
  the team doesn't run the same experiment twice.
- If PIVOT: write a new hypothesis before closing. Don't just say "try again differently."
