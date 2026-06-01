---
name: tech-design
stage: 04-tech-design
agent: architect
description: >
  Produce a complete technical design: components, data model, API contracts,
  evaluated alternatives, risk register, and ADRs. Gate requires ≥ 2 alternatives
  and at least one ADR.
---

# Skill: Tech Design (Stage 04)

## Purpose

Give the Implementer a complete, unambiguous blueprint. Every architectural decision must be made and recorded here — not during implementation.

## When This Skill Is Active

- Stage 04 has started (after Stage 03 Discovery is approved)
- The `architect` agent is in designer mode
- The developer has run `/comment` with design feedback

## What Gets Produced

| Artifact | Path | Gate |
|---|---|---|
| Design document | `04-tech-design/design.md` | Hard: must have all 14 sections |
| Alternatives | `04-tech-design/alternatives.md` | Hard: ≥ 2 alternatives evaluated |
| Technical risks | `04-tech-design/risks.md` | Hard: non-empty |
| ADR(s) | `04-tech-design/adrs/NNN-<slug>.md` | Soft: ≥ 1 ADR for major decisions |

## Quick Reference for the Agent

1. Read prior stage outputs: `02-prd-clean/clean-prd.md` + all `03-discovery/` artifacts
2. Identify the **key architectural decision** — what is the one choice that shapes everything else?
3. Generate ≥ 2 alternatives; evaluate honestly; choose
4. Write `alternatives.md` + ADR(s) before writing `design.md`
5. Write `design.md` using the approved approach
6. Write `risks.md` (technical risks — not PRD-level)
7. For full process → `INSTRUCTIONS.md`
8. For gate check → `checklists/design-gate-checklist.md`
9. For example → `examples/example-tech-design.md`

## Override

Drop `override.md` here for project- or team-specific design requirements (e.g., mandatory sequence diagrams, required security review section, microservices-specific component template).
