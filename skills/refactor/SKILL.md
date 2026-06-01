---
name: refactor
stages: [02-current-state, 03-target-design]
description: >
  Researcher maps the existing messy state. Architect designs the clean
  target state and records the key decisions as ADRs.
---

# Skill: Refactor (Stages 02–03)

## Purpose

Ensure a refactor is grounded in a clear picture of what exists today and
a specific design for where it should end up — not just "make it cleaner."

## Stage 02 — Current State

**Agent:** researcher
**Produces:**
| Artifact | Path | Gate |
|---|---|---|
| Current state map | `02-current-state/current-state.md` | Hard: must identify pain points |
| Impacted files | `02-current-state/impacted-files.md` | Soft |

## Stage 03 — Target Design

**Agent:** architect
**Produces:**
| Artifact | Path | Gate |
|---|---|---|
| Target design | `03-target-design/target-design.md` | Hard |
| ADRs | `03-target-design/adrs/` | Soft |

## Quick Reference

1. Stage 02: Map what exists — be specific about what is painful and why.
2. Stage 03: Design the target — must be achievable in atomic steps.
3. Stage 04 uses the standard `task-breakdown` skill to produce the migration plan.
4. For detailed process → `INSTRUCTIONS.md`
