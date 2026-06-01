---
name: code-review
stage: 07-review
agent: reviewer
description: >
  Post-implementation review of each task's code against acceptance criteria,
  conventions, security requirements, and edge cases. Produces a structured
  report with severity-rated issues. Gate requires no Critical issues before
  presenting to the developer.
---

# Skill: Code Review (Stage 07)

## Purpose

Catch real problems before they reach the developer or production. Review code as a picky senior engineer who assumes bugs exist until proven otherwise.

## When This Skill Is Active

- Stage 07 is active after an implementation task is committed
- The `reviewer` agent has been invoked by the Orchestrator with the task spec + diff

## What Gets Produced Per Task

| Artifact | Path | Gate |
|---|---|---|
| Review report | `07-review/self-review-NNN-<slug>.md` | Hard: no Critical issues open when presented to developer |

## Verdict Options

- **PASS** — all ACs met, no Critical/Major issues
- **PASS WITH COMMENTS** — ACs met, observations for developer
- **FAIL** — Critical issue or unmet AC — must return to Implementer

## Quick Reference for the Agent

1. Read the task spec (`05-tasks/NNN-<slug>.md`) — know what should have been built
2. Read `task-notes/NNN-<slug>.md` — know what the Implementer noted
3. Check acceptance criteria one by one — find the code, verify it works
4. Check convention compliance against repo memory
5. Check correctness: nulls, concurrency, failure modes
6. Check security: auth, authz, injection, data exposure
7. Check test quality: do tests verify behaviour or just existence?
8. Assign severity to every issue found
9. For full process → `INSTRUCTIONS.md`
10. For gate check → `checklists/review-gate-checklist.md`

## Override

Drop `override.md` here for custom review requirements (e.g., mandatory performance benchmarks, specific security checklist additions, domain-specific review criteria).
