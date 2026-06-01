---
name: prd-review
stage: 02-prd-clean
agent: prd-reviewer
description: >
  Senior-engineer critique of a raw PRD. Produces five implementation-ready
  artifacts: clean PRD, assumptions, open questions, out-of-scope, and risks.
---

# Skill: PRD Review (Stage 02)

## Purpose

Turn a raw, ambiguous PRD into a specification a developer can implement without guessing. Find every gap, contradiction, and hidden assumption before the first line of code is written.

## When This Skill Is Active

- Stage 02 has started (after `/start-project` saves `01-prd/input.md`)
- The `prd-reviewer` agent has been invoked by the Orchestrator
- The developer has run `/comment` with feedback and the agent is revising

## What Gets Produced

| Artifact | Path | Gate |
|---|---|---|
| Clean PRD | `02-prd-clean/clean-prd.md` | Hard: must have Goals, Non-Goals, User Stories, Acceptance Criteria, Constraints |
| Assumptions | `02-prd-clean/assumptions.md` | Soft: must be non-empty |
| Open questions | `02-prd-clean/open-questions.md` | Soft: blocking questions must have an owner |
| Out of scope | `02-prd-clean/out-of-scope.md` | Soft |
| Risks | `02-prd-clean/risks.md` | Soft: must be non-empty |

## Quick Reference for the Agent

1. Read `01-prd/input.md` as a skeptical senior engineer
2. Identify: ambiguities, missing requirements, contradictions, infeasible parts, missing acceptance criteria
3. Produce all five artifacts — no placeholders remaining
4. For detailed process → read `INSTRUCTIONS.md`
5. For gate check → read `checklists/prd-gate-checklist.md`
6. For a worked example → read `examples/example-clean-prd.md`

## Override

Drop `override.md` in this directory to customise behaviour for a specific project or team. Example overrides: stricter acceptance criteria format, additional required sections, domain-specific risk categories.
