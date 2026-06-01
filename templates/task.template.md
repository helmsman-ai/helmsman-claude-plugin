# Task {{number}}: {{title}}

> **Stage**: 05-tasks → 06-implementation
> **Project**: {{project_name}}
> **Produced by**: Architect agent (task spec) · Implementer agent (implementation)
> **Effort estimate**: {{effort}} (e.g., 1h · 2h · 4h · half-day)
> **Status**: pending | in-progress | in-review | complete

---

## Goal

> One or two sentences. What does completing this task achieve?

{{goal}}

---

## Context

> What the Implementer needs to know to start without re-reading the full design.
> Include: where this fits in the feature, relevant prior decisions, key constraints.

{{context}}

---

## Files to Touch

> Be specific. Guides the Implementer and scopes the review.

| Action | File | Notes |
|---|---|---|
| create | `{{path}}` | {{notes}} |
| modify | `{{path}}` | {{notes}} |
| delete | `{{path}}` | {{notes}} |

---

## Target Repo

> Which registered repo this task is implemented in. Must match a `name` in `manifest.yaml`.
> For single-repo projects, this is always the one linked repo.
> For multi-repo projects, each task targets exactly one repo.
> If absent, the Implementer defaults to the sole `linked_repos` entry. For multi-repo projects, this field is required.

target_repo: {{repo_name}}

---

## Acceptance Criteria

> Each item must be verifiable by reading code or running tests.
> Gate: all must be checked before this task can be marked complete.

- [ ] {{criterion_1}}
- [ ] {{criterion_2}}
- [ ] {{criterion_3}}

---

## Test Requirements

> Specific tests that must exist and pass before this task is considered done.

- [ ] Unit test: `{{test_description}}`
- [ ] Integration test: `{{test_description}}` *(if applicable)*
- [ ] Edge case: `{{edge_case}}`

---

## Dependencies

> Other tasks that must be complete before starting this one.

- Depends on: {{task_numbers_or_none}}
- Blocks: {{task_numbers_or_none}}

---

## Implementation Notes

> Hints, gotchas, or architectural constraints the Implementer should know.
> Not a prescription — the Implementer decides how; this is context.

{{implementation_notes}}

---

## Review Checklist (filled by Reviewer agent)

- [ ] Acceptance criteria met
- [ ] Tests written and passing
- [ ] No unintended side effects
- [ ] Conventions followed
- [ ] No security issues introduced
