# Tech Design — Detailed Instructions

> Load this file when doing the work. `SKILL.md` is the summary.

---

## Inputs

- `02-prd-clean/clean-prd.md` — acceptance criteria and constraints
- `02-prd-clean/assumptions.md` — things being treated as true
- `03-discovery/codebase-findings.md` — what already exists; architectural constraints
- `03-discovery/dependencies.md` — systems this feature depends on
- `03-discovery/prior-art.md` — past ADRs that constrain the design space
- `03-discovery/stakeholder-map.md` — who must sign off on what
- Repo memory — conventions, patterns, known tech debt
- Project memory — scope constraints, mode

---

## Process

### Step 1 — Absorb the constraints

Before designing anything, read every constraint source:

1. Clean PRD constraints section — hard limits you must design within
2. Codebase findings — patterns you must follow; areas you cannot touch freely
3. Prior ADRs — decisions already made that bound your choices
4. Repo memory — architectural rules (e.g., "all DB access via repository layer")

Write down in your working notes: "These are the non-negotiables."

### Step 2 — Identify the key decision

Name the single most important architectural choice this feature requires.
This is the decision that, if wrong, causes the most rework.

Examples:
- "How do we store idempotency state — in our DB or rely on Stripe?"
- "Do we add a new endpoint or extend an existing one?"
- "Synchronous charge flow or async via queue?"

You will write an ADR for this. Everything else follows from it.

### Step 3 — Generate alternatives (do this before designing)

For the key decision, generate ≥ 2 alternatives:
- Include at least one "boring/obvious" option
- Include the option you think is best
- Optionally include a creative/ambitious option

For each alternative, evaluate:
- **Pros**: what does this make easy?
- **Cons**: what does this make hard or risky?
- **Effort**: rough implementation complexity
- **Risk**: what could go wrong?
- **Fit with existing codebase**: does this follow established patterns or diverge?

Then choose. Justify the choice in terms of the specific constraints from Step 1 — not generic principles.

Write `alternatives.md` using `templates/alternatives.template.md`.
Write the ADR using `templates/adr.template.md`.

### Step 4 — Design the components

With the key decision made, design the implementation:

**Components** — what needs to be created or modified?
For each component: purpose, inputs, outputs, which layer it lives in, which existing components it interacts with.

**Data model** — what schema changes are needed?
Be explicit: table name, column name, type, constraints, indexes. Include migration strategy if altering existing data.

**API / interface contracts** — what new or changed interfaces are exposed?
For HTTP: method, path, request shape, response shape, error codes.
For events/queues: event name, payload schema, consumer expectations.
Be precise enough that the Implementer can write the code without asking.

**Sequence flows** — for multi-step or multi-component flows, draw the sequence.
Mermaid or ASCII — whatever renders in your environment.

### Step 5 — Security and performance

**Security**: For every new endpoint, data path, or external integration:
- Authentication: is this endpoint protected? How?
- Authorization: which roles/users can call this?
- Data exposure: is any sensitive field leaking in responses?
- Input validation: where is user input sanitized?

**Performance**: 
- What is the expected load?
- Are there any new synchronous external calls that could blow the SLA?
- Does any new query need an index?
- Is caching appropriate?

### Step 6 — Testing strategy

Define at the design level:
- What must be unit tested? (the logic boundaries)
- What must be integration tested? (the DB and external service interactions)
- What can only be manually tested? (UI flows, third-party webhooks)

This becomes the test requirements in each task file (Stage 05).

### Step 7 — Technical risks

Write `risks.md`. Technical risks only — not PRD risks (those are in Stage 02).

Focus on:
- "This design relies on X working correctly — if X has latency spikes, we blow the SLA"
- "The migration in task 001 is non-destructive but touches a hot table — needs maintenance window or zero-downtime strategy"
- "Idempotency check at app layer only — race condition possible under concurrent load"

For each risk: likelihood, severity, mitigation.

### Step 8 — Write `design.md`

Now write the full design document using `templates/tech-design.template.md`.

Required sections (all must be present to pass the gate):
1. Overview
2. Goals & Non-Goals (technical)
3. System Context (before/after)
4. Component Design
5. Data Model
6. API / Interface Contracts
7. Sequence / Flow Diagrams
8. Security Considerations
9. Performance & Scalability
10. Testing Strategy
11. Risks (link to `risks.md`)
12. Alternatives Considered (link to `alternatives.md`)
13. ADRs (link to `adrs/`)
14. Open Implementation Questions (for the Implementer)

---

## Handling Developer Comments

When the developer runs `/comment` after seeing the design:

- "I prefer approach B" → update `alternatives.md` to mark B as chosen, write a new or updated ADR, update `design.md` to reflect B, log in decisions log
- "This design is missing X" → add X to `design.md`, check if it affects the alternatives decision
- "Can we simplify by removing Y" → remove Y, note in `design.md` why it was removed, check gate compliance

Always log significant direction changes to `decisions.log.md` via the Orchestrator.

---

## Quality Checks Before Finishing

- [ ] `design.md` has all 14 required sections
- [ ] `alternatives.md` documents ≥ 2 options with pros/cons
- [ ] At least one ADR exists in `adrs/`
- [ ] `risks.md` is non-empty
- [ ] No `{{placeholder}}` tokens remain in any artifact
- [ ] Every acceptance criterion from `clean-prd.md` is addressed somewhere in the design
- [ ] Every constraint from `clean-prd.md` is acknowledged (and either satisfied or flagged as needing gate override)
- [ ] API contracts are specific enough that an Implementer needs no further clarification
- [ ] Security section addresses auth and data exposure

---

## Output Summary to Orchestrator

```
Tech Design complete.

Artifacts written:
- 04-tech-design/design.md
- 04-tech-design/alternatives.md
- 04-tech-design/risks.md
- 04-tech-design/adrs/001-<slug>.md

Key decision: [one sentence]
Alternatives rejected: [one sentence each]
Top risks: [2-3 bullets]
Open questions for Implementer: [list]

Gate status: PASS / FAIL
```
