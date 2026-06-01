# Clean PRD — {{project_name}}

> **Stage**: 02-prd-clean
> **Produced by**: PRD Reviewer agent
> **Source**: `01-prd/input.md`
> **Last updated**: {{date}}

---

## 1. Problem Statement

> One paragraph. What problem are we solving and for whom? Why does it matter now?

{{problem_statement}}

---

## 2. Goals

> What success looks like. Each goal must be verifiable.

- [ ] {{goal_1}}
- [ ] {{goal_2}}

---

## 3. Non-Goals

> Explicit scope boundaries. What we are deliberately NOT doing in this iteration.

- {{non_goal_1}}
- {{non_goal_2}}

---

## 4. User Stories

> Format: "As a [role], I want to [action], so that [outcome]."

| # | Role | Action | Outcome |
|---|---|---|---|
| US-01 | {{role}} | {{action}} | {{outcome}} |

---

## 5. Acceptance Criteria

> Each criterion is testable and unambiguous. Ties back to user stories.

| # | Criterion | Story | Priority |
|---|---|---|---|
| AC-01 | {{criterion}} | US-01 | Must Have |
| AC-02 | {{criterion}} | US-01 | Should Have |
| AC-03 | {{criterion}} | US-02 | Nice to Have |

**Priority levels**: Must Have · Should Have · Nice to Have

---

## 6. Constraints

> Hard limits the solution must respect (technical, legal, time, budget, org).

| Type | Constraint | Source |
|---|---|---|
| Performance | {{constraint}} | {{source}} |
| Security | {{constraint}} | {{source}} |
| Deadline | {{constraint}} | {{source}} |

---

## 7. Key Metrics

> How will we know this feature is working in production?

| Metric | Baseline | Target | Measurement Method |
|---|---|---|---|
| {{metric_name}} | {{baseline}} | {{target}} | {{how}} |

---

## 8. Open Questions

> Questions that could not be answered before this PRD was written. See `open-questions.md` for full tracking.

- [ ] {{question}} — owner: {{owner}}

---

## 9. Dependencies on Other Teams / Systems

> Systems, APIs, or teams this feature depends on or affects.

| Dependency | Type | Status | Contact |
|---|---|---|---|
| {{system}} | upstream / downstream / external | {{status}} | {{contact}} |

---

## 10. Timeline (Optional)

| Milestone | Target Date | Notes |
|---|---|---|
| Tech design approved | {{date}} | |
| Implementation complete | {{date}} | |
| Launch | {{date}} | |
