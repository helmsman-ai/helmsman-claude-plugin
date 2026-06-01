---
name: spike
stages: [02-investigation, 03-findings, 04-recommendation]
description: >
  Researcher investigates and produces findings. Architect synthesizes a
  clear accept/reject/defer recommendation. No production code is produced.
---

# Skill: Spike (Stages 02–04)

## Purpose

Answer a specific technical question with evidence — not opinion. A spike
that ends with "it depends" is not done. The recommendation must contain
a clear decision the team can act on.

## Stages

| Stage | Agent | Key Artifact | Gate |
|---|---|---|---|
| 02-investigation | Researcher | `codebase-findings.md`, `external-research.md` | Soft |
| 03-findings | Researcher | `findings.md`, `options.md` | Hard: has_findings |
| 04-recommendation | Architect | `recommendation.md` | Hard: has_decision |

## Quick Reference

1. Investigation: gather facts — codebase + external. Do not interpret yet.
2. Findings: synthesize what you found into options with trade-offs.
3. Recommendation: make a decision. Accept / Reject / Defer with rationale.
4. No implementation. No production code. Prototype code in findings is OK.
