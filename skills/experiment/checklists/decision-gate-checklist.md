# Decision Gate Checklist — Stage 05 (experiment)

## Hard Gates

- [ ] **`05-decision/decision.md` exists and is non-empty**

- [ ] **Contains a clear decision**
  - Must contain one of: SHIP, DISCARD, PIVOT
  - Run: `grep -i "SHIP\|DISCARD\|PIVOT" 05-decision/decision.md`
  - Failure: decision missing or ambiguous

- [ ] **Rationale present** — at least one paragraph explaining the decision

- [ ] **If PIVOT: new hypothesis stated** — not just "try again"

- [ ] **If DISCARD: cleanup plan referenced** — how experiment code will be removed
