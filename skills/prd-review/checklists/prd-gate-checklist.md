# PRD Review Gate Checklist — Stage 02

> **Load this file only at gate-check time** (before `/advance` from Stage 02).
> The Orchestrator runs through this list. Hard failures block advance.

---

## Hard Gates (block advance if failed)

- [ ] **`clean-prd.md` exists** and is non-empty
  - Path: `02-prd-clean/clean-prd.md`

- [ ] **Goals section present** in `clean-prd.md`
  - Must have at least one concrete, outcome-oriented goal
  - Failure: section missing, or only contains `{{placeholder}}`

- [ ] **Non-Goals section present** in `clean-prd.md`
  - Must have at least one explicit exclusion
  - Failure: section missing or empty

- [ ] **User Stories present** in `clean-prd.md`
  - At least one "As a [role], I want to [action], so that [outcome]" statement
  - Failure: no user stories at all

- [ ] **Acceptance Criteria present** in `clean-prd.md`
  - At least one acceptance criterion per user story
  - Each criterion must be testable (no unqualified adjectives: "fast", "good", "simple")
  - Failure: no ACs, or all ACs are untestable

- [ ] **Constraints section present** in `clean-prd.md`
  - At least one hard constraint (performance SLA, legal, compatibility, etc.)
  - If genuinely no constraints: write "No hard constraints identified" explicitly
  - Failure: section missing

- [ ] **All five artifacts present**
  - `02-prd-clean/clean-prd.md` ✓/✗
  - `02-prd-clean/assumptions.md` ✓/✗
  - `02-prd-clean/open-questions.md` ✓/✗
  - `02-prd-clean/out-of-scope.md` ✓/✗
  - `02-prd-clean/risks.md` ✓/✗

- [ ] **No `{{placeholder}}` tokens** in any artifact
  - Run: `grep -r "{{" 02-prd-clean/`
  - Failure: any unreplaced template tokens found

---

## Soft Gates (warn but do not block)

- [ ] **Blocking open questions have owners**
  - Each row in the "Blocking" table of `open-questions.md` has a non-empty Owner column

- [ ] **Unvalidated assumptions are marked**
  - `assumptions.md` clearly distinguishes confirmed from unvalidated

- [ ] **Risks section non-empty**
  - `risks.md` has at least one entry

- [ ] **Acceptance criteria are specific** (no SLA gaps)
  - Performance criteria (latency, throughput) have numbers, not adjectives
  - Warn if any AC contains: "fast", "slow", "quickly", "reliably", "easily", "good", "bad"

---

## Override Policy

A hard gate can be overridden only with an explicit reason stored in `state.yaml.gates_overridden`.
Example valid reason: "PRD is a hotfix intake; full acceptance criteria will be added in a follow-up."
Example invalid reason: "We're in a hurry."
