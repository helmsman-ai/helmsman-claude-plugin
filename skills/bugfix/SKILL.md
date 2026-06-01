---
name: bugfix
stages: [02-reproduce, 03-fix-plan]
description: >
  Researcher confirms root cause and maps impacted code paths. Architect
  produces a targeted fix plan. Used by bugfix mode only.
---

# Skill: Bugfix (Stages 02–03)

## Purpose

Ensure a fix is based on a confirmed root cause — not a guess. The
Researcher must verify the bug is reproducible and identify exactly what
is broken before the Architect plans the fix.

## Stage 02 — Reproduce & Diagnose

**Agent:** researcher
**Produces:**
| Artifact | Path | Gate |
|---|---|---|
| Root cause analysis | `02-reproduce/root-cause.md` | Hard: must identify root cause |
| Impacted code paths | `02-reproduce/impacted-paths.md` | Soft |

## Stage 03 — Fix Plan

**Agent:** architect
**Produces:**
| Artifact | Path | Gate |
|---|---|---|
| Fix plan | `03-fix-plan/fix-plan.md` | Hard: must have fix approach |
| Regression risks | `03-fix-plan/regression-risks.md` | Soft |

## Quick Reference

1. Stage 02: Reproduce the bug. Find the exact line(s) causing it.
2. Stage 03: Design the minimal fix. Do not refactor beyond the bug scope.
3. For detailed process → `INSTRUCTIONS.md`
4. For gate checks → `checklists/reproduce-gate-checklist.md` and `checklists/fix-plan-gate-checklist.md`
