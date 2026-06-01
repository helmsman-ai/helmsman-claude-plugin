---
name: experiment
stages: [02-design, 04-results, 05-decision]
description: >
  Architect designs the experiment. Researcher measures and documents
  results. Orchestrator captures a formal ship/discard/pivot decision.
---

# Skill: Experiment (Stages 02, 04, 05)

## Purpose

Build something to test a hypothesis. Record what happened. Make a
formal decision. The dossier is valuable whether the experiment succeeds
or fails — a discarded experiment that documented its failure prevents
the same mistake twice.

## Stages

| Stage | Agent | Key Artifact | Gate |
|---|---|---|---|
| 02-design | Architect | `experiment-design.md` | Hard: has_experiment_design |
| 04-results | Researcher | `results.md`, `metrics.md` | Hard: has_results |
| 05-decision | Orchestrator | `decision.md` | Hard: has_ship_decision |

## Quick Reference

1. Hypothesis is set in Stage 01 with a time-box — do not change it mid-experiment.
2. Design (Stage 02): what to build and how to measure success.
3. Results (Stage 04): measure against the success metrics from Stage 01. Be honest.
4. Decision (Stage 05): ship / discard / pivot — must be recorded with rationale.
