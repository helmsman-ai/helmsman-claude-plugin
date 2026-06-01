---
name: chore
stages: [03-review]
description: >
  Reduced code review checklist for chores — skips security and
  architecture sections. Used when gate_strictness is lenient.
---

# Skill: Chore Review (Stage 03)

## Purpose

A chore (dependency bump, config change, tooling update) still needs a
review pass — but the review is scoped. Security and architecture sections
are skipped. The reviewer focuses on: does it do what it says, does it
break anything, is it complete?

## Stage 03 — Review

**Agent:** reviewer
**Produces:**
| Artifact | Path | Gate |
|---|---|---|
| Review | `03-review/self-review.md` | Hard: no_critical_issues |

## Reduced Checklist

The reviewer skips:
- Security analysis (not applicable to most chores)
- Architecture review (chores should not introduce new patterns)
- Test coverage requirements (chores often have no new tests)

The reviewer checks:
- Does the change do what `01-intake/chore-description.md` says it does?
- Does it introduce any unintended side effects?
- Are any config values, version pins, or file changes complete and consistent?
