# Project Memory — {{project_name}}

> **Scope**: This project only
> **Updated by**: Orchestrator at each stage approval
> **Location**: `projects/{{project_name}}/CLAUDE.md`
>
> Loaded by all agents working on this project.
> Inherits from repo memory and global memory.

---

## Project Identity

| Field | Value |
|---|---|
| Name | {{project_name}} |
| Mode | {{mode}} |
| Status | {{status}} |
| Started | {{date}} |
| Linked repos | {{repos}} |

---

## Scope Summary

> One paragraph. What this project does and what it explicitly does not do.

{{scope_summary}}

---

## Key Decisions

> The most important decisions made so far. Full history in `decisions.log.md`.

- **{{decision_title}}**: {{one_line_summary}} — see [ADR-{{number}}](04-tech-design/adrs/{{number}}-{{slug}}.md)
- **{{decision_title}}**: {{one_line_summary}}

---

## Active Constraints

> Constraints that agents must respect when doing work for this project.

- {{e.g., "SLA: /charge endpoint must respond in <200ms p95"}}
- {{e.g., "Refunds are out of scope for this iteration — do not implement"}}
- {{e.g., "No changes to the payments schema without DBA review"}}

---

## Current Stage

- **Stage**: {{current_stage}}
- **Status**: {{stage_status}}
- **Next action**: {{what_needs_to_happen_next}}

---

## Artifact Links

| Artifact | Path | Status |
|---|---|---|
| Raw PRD | `01-prd/input.md` | {{status}} |
| Clean PRD | `02-prd-clean/clean-prd.md` | {{status}} |
| Tech design | `04-tech-design/design.md` | {{status}} |
| Task index | `05-tasks/INDEX.md` | {{status}} |
| Progress | `06-implementation/progress.md` | {{status}} |

---

## Notes for Agents

> Context that doesn't fit elsewhere but every agent should know.

- {{e.g., "PM confirmed verbally on 2025-01-15: refunds deferred to v2 even if not in the PRD"}}
- {{e.g., "The web-app repo uses a custom hook pattern — see researcher findings before touching hooks"}}
