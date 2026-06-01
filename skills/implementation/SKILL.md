---
name: implementation
stage: 06-implementation
agent: implementer
description: >
  Write code for one task at a time: read task spec, follow TDD, commit with a
  structured message, update the progress log. Gate requires all tests to pass
  and lint to be clean before advancing.
---

# Skill: Implementation (Stage 06)

## Purpose

Execute the task plan precisely — one task per session, tests-first, conventions-always, scope-fenced.

## When This Skill Is Active

- Stage 06 is active and the Orchestrator has given the Implementer a specific task file
- Each Implementer instance handles exactly one task; multiple Implementers may run in parallel for tasks in the same dependency wave

## What Gets Produced Per Task

| Artifact | Location | Gate |
|---|---|---|
| Code + tests | Committed to `helmsman/<project>` branch | Hard: tests pass, lint clean |
| Progress update | `06-implementation/progress.md` | Hard: task status updated |
| Task notes | `06-implementation/task-notes/NNN-<slug>.md` | Soft: any deviations documented |

## Quick Reference for the Agent

1. Read the task file **completely** before touching any code
2. Open every file listed in "Files to Touch" — understand current state first
3. Write the test(s) first (TDD) — they should fail
4. Write minimal code to make tests pass
5. Commit: structured message citing the task number
6. Update `progress.md`, write `task-notes/`
7. Report status: `DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`
8. For full process → `INSTRUCTIONS.md`
9. For gate check → `checklists/implementation-gate-checklist.md`

## Override

Drop `override.md` here for project-specific implementation rules (e.g., mandatory integration test pattern, specific commit message format, required coverage threshold).
