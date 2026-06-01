# Tech Design Gate Checklist — Stage 04

> Load at gate-check time only. Hard failures block `/advance`.

---

## Hard Gates

- [ ] **`design.md` exists and has all 14 required sections**
  - Overview · Goals & Non-Goals · System Context · Component Design · Data Model
  - API/Interface Contracts · Sequence Diagrams · Security · Performance
  - Testing Strategy · Risks · Alternatives Considered · ADRs · Open Questions
  - Check: `grep -c "^## " 04-tech-design/design.md` — must return ≥ 14

- [ ] **≥ 2 alternatives evaluated in `alternatives.md`**
  - Must include pros, cons, and effort for each
  - Failure: only one option described, or alternatives not meaningfully distinct

- [ ] **`risks.md` is non-empty**
  - Must have at least one technical risk with a mitigation
  - Failure: file missing or only has the template header

- [ ] **No `{{placeholder}}` tokens remain**
  - Run: `grep -r "{{" 04-tech-design/`
  - Failure: any unreplaced tokens found

- [ ] **Every clean-PRD acceptance criterion is addressed**
  - For each AC in `02-prd-clean/clean-prd.md`, the design must either satisfy it or flag it
  - Failure: any AC with no corresponding design element

---

## Soft Gates

- [ ] **At least one ADR exists** in `04-tech-design/adrs/`
  - Warn if no ADR despite significant architectural choice

- [ ] **API contracts are specific**
  - Warn if any endpoint has no defined request/response shape

- [ ] **Security section addresses authentication**
  - Warn if new endpoints exist but auth is not discussed

- [ ] **Data model has migration strategy** (if schema changes exist)
  - Warn if schema changes are described but no migration approach is given

- [ ] **Performance section references the SLA** from clean PRD
  - Warn if a latency/throughput SLA was stated in the PRD but not addressed in the design
