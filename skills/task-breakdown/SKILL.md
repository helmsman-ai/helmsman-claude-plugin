---
name: task-breakdown
stage: 05-tasks
agent: architect
description: >
  Decompose the approved tech design into atomic, dependency-ordered implementation
  tasks. Each task is 1–4 hours, has acceptance criteria, specifies files to touch,
  and defines test requirements. Gate requires every task to have acceptance criteria.
---

# Skill: Task Breakdown (Stage 05)

## Purpose

Give the Implementer a precise, ordered work queue. Each task must be completable in one focused session with no ambiguity about what "done" means.

## When This Skill Is Active

- Stage 05 has started (after Stage 04 Tech Design is approved)
- The `architect` agent is in planning mode

## What Gets Produced

| Artifact | Path | Gate |
|---|---|---|
| Task index | `05-tasks/INDEX.md` | Hard: dependency graph present; no circular deps |
| Task files | `05-tasks/NNN-<slug>.md` | Hard: every task has goal, files-to-touch, acceptance criteria, test requirements |

## Quick Reference for the Agent

1. Read `04-tech-design/design.md` — decompose along component/layer seams
2. Size each task to 1–4 hours; when in doubt, split
3. Map dependencies explicitly before writing files
4. Write `INDEX.md` with dependency graph first
5. Write each task file using `templates/task.template.md` — fill all sections
6. For full process → `INSTRUCTIONS.md`
7. For gate check → `checklists/task-gate-checklist.md`
8. For example → `examples/example-task.md`

## Override

Drop `override.md` here for custom task formats (e.g., Jira story linking, specific test framework requirements, additional required sections per task).
