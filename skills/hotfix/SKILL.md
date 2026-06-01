---
name: hotfix
stages: [02-fix]
description: >
  Emergency fix pipeline. Fast_track mode: pipeline auto-advances,
  hard gates downgrade to warnings. Implementer works from incident
  description directly — no separate fix-plan stage.
---

# Skill: Hotfix (Stage 02)

## Purpose

Ship a fix as fast as safely possible. The reduced process is intentional
— but the audit trail is preserved. Every gate result is still written to
state.yaml, even if it only warns instead of blocks.

## Stage 02 — Fix

**Agent:** implementer
**Produces:**
| Artifact | Path | Gate |
|---|---|---|
| Code commit | branch `helmsman/{project}` | Hard (downgraded to warn): tests_pass |
| Progress notes | `02-fix/notes.md` | — |

## Behavior in fast_track mode

- Gate failures warn instead of blocking
- Pipeline auto-advances after this stage completes — no `/approve` required
- Developer can still pause with `/comment` or explicitly `/approve`

## Quick Reference

1. Read `01-intake/incident.md` — understand the symptom and impact.
2. Find the cause. Fix it. Write a test that proves it's fixed.
3. Keep scope minimal — a hotfix that also refactors is harder to revert.
4. Commit with the incident ID in the message.
