# PRD Review — Detailed Instructions

> Load this file when you are about to do the work, not just orient yourself.
> `SKILL.md` is the summary. This is the full process.

---

## Input

- `01-prd/input.md` — immutable. Never edit.
- Repo memory (`memory/repos/<name>.md`) — tech stack, architectural constraints
- Project memory (`projects/<name>/CLAUDE.md`) — scope, mode, any user pre-stated constraints
- Global memory (`memory/CLAUDE.md`) — user's workflow preferences
- Any `/comment` feedback from the developer on a prior pass

---

## Process

### Step 1 — Read for understanding (do not write yet)

Read the full raw PRD. Build a mental model:
- What problem is being solved?
- Who are the users?
- What does "done" look like to the PM who wrote this?
- What is the implied technical context (what system does this live in)?

Do not write any artifacts yet.

### Step 2 — Systematic gap analysis

Re-read the PRD looking for each failure mode below. For each one found, note: what it is, where it appears (quote or describe), and what you need to resolve it.

#### 2a. Ambiguities
Statements that could be interpreted two or more ways.
- Vague adjectives: "fast", "reliable", "simple", "real-time", "efficient"
- Unqualified nouns: "users" (which users? all roles?), "the system" (which service?)
- Implicit conditions: "when the user clicks submit" — what if the form is invalid?

#### 2b. Missing requirements
Things this class of feature always needs, but the PRD didn't mention:
- **Error states** — what happens when it fails? What does the user/caller see?
- **Idempotency** — can this action be safely retried?
- **Permissions** — who is allowed to do this? Who is not?
- **Audit / logging** — must this be traceable?
- **Rate limiting** — can this be abused?
- **Empty states** — what if there is no data?
- **Concurrent access** — what if two users do this at the same time?
- **Migration / backward compatibility** — if this changes existing behaviour, what happens to existing data?

#### 2c. Contradictions
Two statements that cannot both be true simultaneously.
Read every constraint and goal. Look for: performance vs. correctness trade-offs stated as both absolute; "simple" + "full-featured"; "no breaking changes" + "new required fields".

#### 2d. Infeasible parts
Things that conflict with the known tech stack, existing architecture, or physical limits.
Use repo memory: what does the current stack make easy vs. expensive?
Flag: "This requires sub-10ms DB queries, but the current schema has no index on this column."

#### 2e. Scope creep risks
Requirements that are larger than they appear:
- "Support all X" — enumerated vs. open-ended?
- "Integrate with Y" — read-only or bidirectional?
- "Allow users to manage Z" — full CRUD or limited operations?

#### 2f. Untestable acceptance criteria
User stories with no verifiable outcome.
"Users should have a good experience" → not testable.
"Users can complete checkout in under 3 clicks from cart" → testable.

### Step 3 — Write `open-questions.md` first

Before writing anything else, list every unresolved question that came from Step 2.
Separate blocking (must resolve before tech design) from non-blocking.
Assign an owner to each blocking question.

If the developer provided answers in a prior `/comment` pass, mark those questions resolved and move them to the Resolved section.

### Step 4 — Write `assumptions.md`

List every inference you made when the PRD was unclear.
- Confirmed: things you can verify from repo memory, existing code, or prior project decisions
- Unvalidated: things you assumed are true but cannot verify — these carry risk

### Step 5 — Write `out-of-scope.md`

List everything explicitly excluded. Sources:
- Things the PRD said are out of scope
- Things you inferred are out of scope (mark as assumption)
- Things you moved out of scope because they were too large for this iteration

### Step 6 — Write `risks.md`

PRD-level risks only. This is not about technical implementation risk (that's Stage 04).
Focus on:
- Requirements risk: "Q-01 is blocking; if the answer changes, scope changes significantly"
- Stakeholder risk: "No decision-maker identified for auth changes — could block launch"
- Scope risk: "The 'all payment methods' requirement could balloon scope 3x"
- Timeline risk: "Depends on Platform Team changes that have no ETA"

### Step 7 — Write `clean-prd.md`

This is the definitive specification. Use `templates/prd-clean.template.md` as structure.

Rules:
- Every user story has at least one acceptance criterion
- Every acceptance criterion is measurable (no vague adjectives)
- Goals are bullet-pointed outcomes, not activities
- Non-goals are explicit ("We are NOT building X in this iteration")
- Constraints list hard limits (performance SLAs, compliance requirements, API backward compatibility)
- For open questions not yet answered: write the best-available version and mark it with `[PENDING Q-XX]`

Do not copy-paste the raw PRD. Restructure it entirely.

---

## Quality Checks Before Finishing

Run through this before handing back to Orchestrator:

- [ ] `clean-prd.md` has all required sections: Goals, Non-Goals, User Stories, Acceptance Criteria, Constraints
- [ ] Every acceptance criterion is testable (no adjectives like "fast", "good", "easy")
- [ ] No `{{placeholder}}` tokens remain in any artifact
- [ ] `assumptions.md` — unvalidated assumptions are marked
- [ ] `open-questions.md` — every blocking question has an owner
- [ ] `out-of-scope.md` — at least one entry (if truly nothing is out of scope, note that explicitly)
- [ ] `risks.md` — non-empty; each risk has a mitigation or is marked "accepted"

---

## Handling Developer Comments

When the developer runs `/comment "<text>"` after seeing the initial artifacts:

1. Read the comment carefully — is it a correction, an addition, or a question?
2. If it resolves an open question: update `open-questions.md` (move to Resolved) and update `clean-prd.md`
3. If it adds a requirement: add to `clean-prd.md` goals/ACs and note in `assumptions.md` as "Confirmed: stated by developer on [date]"
4. If it changes scope: update `out-of-scope.md` accordingly
5. Re-run quality checks
6. Report the changes made to Orchestrator

---

## Templates

- `templates/clean-prd.template.md` — base structure for `clean-prd.md`
- `templates/assumptions.template.md`
- `templates/open-questions.template.md`
- `templates/out-of-scope.template.md`
- `templates/risks.template.md`

Note: templates are in `helmsman/templates/` (workspace level) and also copied to `skills/prd-review/templates/` for skill-specific variants.

---

## Output Summary to Orchestrator

After completing all artifacts, report:

```
PRD Review complete.

Artifacts written:
- 02-prd-clean/clean-prd.md
- 02-prd-clean/assumptions.md
- 02-prd-clean/open-questions.md
- 02-prd-clean/out-of-scope.md
- 02-prd-clean/risks.md

Summary:
- X blocking open questions (owner: Y)
- X unvalidated assumptions
- X items moved out of scope
- X PRD-level risks identified

Notable gaps found:
- [list the most important ones in 2-3 bullets]

Gate status: PASS / FAIL (list any hard gate failures)
```
