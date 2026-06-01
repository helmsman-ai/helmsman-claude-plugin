# Experiment Skill — Detailed Instructions

## Stage 02: Experiment Design

### Input
- `01-hypothesis/hypothesis.md`
- `01-hypothesis/success-metrics.md`
- `01-hypothesis/time-box.md`
- Repo memory

### Process

Write `02-design/experiment-design.md`:
- **What to build**: minimal implementation to test the hypothesis. No more.
- **How to measure**: specific metrics, where they come from, how to collect them.
  These MUST correspond to the success metrics in Stage 01.
- **What to instrument**: logging, analytics events, flags needed.
- **Isolation strategy**: how to run this without affecting production users
  (feature flag, separate endpoint, shadow mode, etc.)
- **Cleanup plan**: how to remove the experiment code if discarded.

Constraint: the design must be implementable within the time-box from Stage 01.
If it isn't, say so now — do not silently design something larger.

## Stage 04: Results

### Input
- `02-design/experiment-design.md`
- `01-hypothesis/success-metrics.md`
- Measurement data (logs, analytics, manual observation)

### Process

Write `04-results/results.md`:
- For each success metric from Stage 01: what was the target? What did we observe?
- Was the hypothesis confirmed, refuted, or inconclusive?
- What unexpected things happened?

Write `04-results/metrics.md`:
- Raw data table (metric, target, observed, delta)
- Source of each measurement (where did the number come from?)

Be honest. Do not cherry-pick metrics. If the experiment was inconclusive, say so.

## Stage 05: Decision (Orchestrator-handled)

The Orchestrator presents the results to the developer and asks for a decision.
The developer writes or dictates `05-decision/decision.md` containing:
- **SHIP**: send to production (with any modifications noted)
- **DISCARD**: remove experiment code (reason required)
- **PIVOT**: change the hypothesis and re-experiment (new hypothesis required)
