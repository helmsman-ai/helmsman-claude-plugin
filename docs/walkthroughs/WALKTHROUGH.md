# Helmsman Walkthrough — End-to-End Feature Project

> This document is both a tutorial and a manual test plan.
> Follow it top-to-bottom to verify that Helmsman works correctly end-to-end.
>
> **Feature**: Add an idempotency key to the `/charge` endpoint in `payments-service`.
> **Mode**: `feature`
> **Time**: ~30 minutes to run through manually

---

## Prerequisites

- Helmsman plugin installed
- A `payments-service` repo registered in `manifest.yaml` (or use any repo path)
- Claude Code session open in the Helmsman workspace directory

---

## Part 0 — First-Time Setup

If this is your first time using Helmsman, run the init wizard.

**You type:**
```
/helmsman-init
```

**Helmsman responds:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HELMSMAN SETUP WIZARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Welcome! This wizard will set up your Helmsman workspace.
...
```

**You provide:**
- Workspace path: `~/helmsman-workspace` (Enter to accept default)
- First repo: `~/code/payments`, name: `payments-service`, language: `typescript`, stack: `node, postgres, stripe`, conventions file: `CONVENTIONS.md`

**Files created:**
```
~/helmsman-workspace/
├── manifest.yaml
├── memory/
│   ├── CLAUDE.md
│   └── repos/
│       └── payments-service.md
├── projects/
└── templates/   (all 19 template files)
```

**Verify**: Run `ls ~/helmsman-workspace/` — all directories present.

✅ **Checkpoint**: Workspace exists, manifest.yaml has payments-service registered.

---

## Part 1 — Start the Project

**You type:**
```
/start-project payments-idempotency --mode feature --repo payments-service
```

**Helmsman asks:**
```
Please provide the PRD for `payments-idempotency`.
```

**You paste:**
```
We need to add idempotency support to the /charge endpoint. Right now if a
network error causes the client to retry, they get double-charged. We need
an idempotency_key field that lets callers safely retry without duplicate charges.
```

**Helmsman responds:**
```
Project `payments-idempotency` created (feature mode, linked to: payments-service).

Stage 1 (PRD Intake): ✅ Complete — input saved to 01-prd/input.md
Stage 2 (PRD Review): 🔄 In progress — PRD Reviewer agent running
```

**Files created:**
```
projects/payments-idempotency/
├── state.yaml                    ← current_stage: 02-prd-clean, status: in-progress
├── CLAUDE.md
├── decisions.log.md              ← first entry: "Project started"
├── 01-prd/
│   └── input.md                  ← your PRD text, verbatim, immutable
├── 02-prd-clean/                 ← (being populated by prd-reviewer)
├── 03-discovery/
...
```

✅ **Checkpoint**: `projects/payments-idempotency/state.yaml` exists. `01-prd/input.md` contains your PRD text.

---

## Part 2 — PRD Review (Stage 02)

The `prd-reviewer` agent runs and produces five artifacts.

**Agent output — `02-prd-clean/open-questions.md` (excerpt):**
```markdown
## Blocking

| # | Question | Owner | Deadline |
|---|---|---|---|
| Q-01 | What is the format of idempotency_key? UUID? Caller-generated string? Max length? | PM | Before tech design |
| Q-02 | What happens when the same key is used with different request bodies? Error or first-wins? | PM | Before tech design |
| Q-03 | Is idempotency_key required or optional? | PM | Before tech design |
```

**Agent output — `02-prd-clean/clean-prd.md` (Goals excerpt):**
```markdown
## 2. Goals

- [ ] Callers can include an `idempotency_key` [PENDING Q-01: format TBD] in POST /charge requests
- [ ] Duplicate requests with the same key and identical body return the original response without calling Stripe twice
- [ ] The /charge endpoint responds within 2000ms p95 including idempotency check overhead
- [ ] All charge attempts are recorded in the audit log regardless of idempotency outcome
```

**You review the artifacts**, then answer the open questions:

**You type:**
```
/comment "Q-01: UUID v4, caller-generated, max 64 chars. Q-02: first-wins — return original response. Q-03: optional for now, required in v2."
```

**Helmsman responds:**
```
💬 Comment received on Stage 2 — PRD Review.
PRD Reviewer is incorporating your answers...
```

**Agent updates `clean-prd.md`** — acceptance criteria now have concrete values:
```markdown
| AC-01 | Duplicate POST /charge with identical idempotency_key (UUID v4, ≤64 chars) returns original transaction_id with HTTP 200; Stripe called exactly once | US-01 | Must Have |
```

**You type:**
```
/approve
```

**Helmsman responds:**
```
✅ Stage 2 — PRD Review approved.

Run /advance to start Stage 3 — Discovery.
```

**`state.yaml` changes:**
```yaml
stages:
  "02-prd-clean":
    status: complete
    approved_at: "2025-01-15T11:30:00Z"
current_stage: "02-prd-clean"
```

✅ **Checkpoint**: `02-prd-clean/` has 5 non-empty files. `state.yaml` shows `02-prd-clean` complete.

---

## Part 3 — Discovery (Stage 03)

**You type:**
```
/advance
```

**Gate check**: Stage 02 hard gates all pass (clean-prd has Goals, ACs, Non-Goals, User Stories, Constraints).

**Helmsman responds:**
```
Stage 2 complete ✅
Stage 3 (Discovery) started 🔄
Researcher agent running...
```

**Agent investigates `payments-service` repo and produces:**

**`03-discovery/codebase-findings.md` (excerpt):**
```markdown
## Existing Payment Code

- `src/services/PaymentService.ts` — `charge()` method calls Stripe directly.
  No idempotency logic. Stripe `idempotency_key` not used.
- `src/models/Transaction.ts` — Transaction model has no `idempotency_key` field.
  Schema migration will be required.
- `src/repositories/TransactionRepository.ts` — has `findById()` and `findByUserId()`.
  Missing: `findByIdempotencyKey()` — must be added.

## Constraints

- All DB access via repository layer (CONVENTIONS.md §3)
- Stripe SDK version: stripe-node v12 (supports idempotency_key natively — useful reference)
```

**`03-discovery/stakeholder-map.md` (excerpt):**
```markdown
## Decision-Makers
| Team | Approval needed for |
|---|---|
| Platform Team | Any changes to PaymentService |
| DBA | Schema migrations on transactions table |
```

**You review** — looks thorough. One addition:

**You type:**
```
/comment "Also check if the audit_log table exists — the PRD requires all attempts to be logged there"
```

**Researcher updates** `codebase-findings.md` — adds finding that `payment_audit_log` table does NOT exist and must be created.

**You type:**
```
/approve
/advance
```

✅ **Checkpoint**: `03-discovery/` has 5 non-empty files. `codebase-findings.md` mentions `idempotency_key`, `TransactionRepository`, and `payment_audit_log`.

---

## Part 4 — Tech Design (Stage 04)

**Helmsman responds to `/advance`:**
```
Stage 3 complete ✅
Stage 4 (Tech Design) started 🔄
Architect agent (designer mode) running...
```

**Agent produces:**

**`04-tech-design/design.md` §1 (Overview):**
```markdown
We add idempotency to POST /charge via a DB-level unique constraint on
`transactions.idempotency_key`, combined with an application-layer pre-check
in `PaymentService`. A new `payment_audit_log` table captures all charge
events. The key architectural decision is idempotency storage location:
our DB rather than delegating entirely to Stripe's idempotency API (see ADR-001).
```

**`04-tech-design/alternatives.md` (Decision: idempotency storage):**
```markdown
### Option A — Our DB unique constraint + app-layer check *(chosen)*
Pros: full audit trail ownership; works if we change payment providers
Cons: adds a DB round-trip per request

### Option B — Rely entirely on Stripe's idempotency API
Pros: no schema change; simpler implementation
Cons: no audit trail on our side; couples us to Stripe; Stripe keys expire after 24h
```

**`04-tech-design/adrs/001-idempotency-storage.md`** — ADR recorded.

**You review** the design. You prefer Option A (as the architect chose). But you have a concern:

**You type:**
```
/comment --on 04-tech-design/design.md "Section 8 (Security) doesn't address what happens if idempotency_key is user-supplied and they try to guess another user's key. Add authorization check."
```

**Architect updates** `design.md` §8 — adds: "idempotency_key is scoped per `user_id`; a key used by user A cannot collide with or be looked up by user B."

**You type:**
```
/approve
/advance
```

✅ **Checkpoint**: `04-tech-design/` has `design.md`, `alternatives.md`, `risks.md`, `adrs/001-idempotency-storage.md`. Gate: ≥2 alternatives ✅, risks non-empty ✅, ADR exists ✅.

---

## Part 5 — Task Breakdown (Stage 05)

**Helmsman:**
```
Stage 4 complete ✅
Stage 5 (Task Breakdown) started 🔄
Architect agent (planner mode) running...
```

**Agent produces 6 task files:**

```
05-tasks/
├── INDEX.md
├── 001-add-idempotency-migration.md        est: 1h
├── 002-update-transaction-model.md         est: 30m
├── 003-add-findbyidempotencykey-repo.md    est: 1h
├── 004-add-idempotency-check-service.md    est: 2h
├── 005-add-audit-log-table-and-writes.md   est: 2h
└── 006-integration-tests-charge-flow.md    est: 2h
```

**`05-tasks/INDEX.md` dependency graph:**
```
001 ──► 002 ──► 003 ──► 004 ──► 006
                              ↑
              005 ────────────┘
```

**You review `004-add-idempotency-check-service.md`** and notice the acceptance criteria are clear and testable. The "files to touch" section is specific.

**You type:**
```
/approve
/advance
```

✅ **Checkpoint**: `05-tasks/INDEX.md` exists with dependency graph. 6 task files, each with goal, files-to-touch, ACs, test requirements.

---

## Part 6 — Implementation (Stage 06)

**Helmsman:**
```
Stage 5 complete ✅
Stage 6 (Implementation) started 🔄
Implementer agent running — Task 001: add-idempotency-migration
```

### Task 001 — Migration

**Implementer works on task 001.** It:
1. Reads `05-tasks/001-add-idempotency-migration.md`
2. Opens `db/migrations/` — sees existing migration pattern
3. Writes `db/migrations/20250115_add_idempotency_key.ts`
4. Updates `src/models/Transaction.ts`
5. Writes migration test
6. Commits: `feat(transactions): add idempotency_key column and unique index`
7. Updates `progress.md`

**Implementer reports:** `DONE`

**Helmsman:**
```
Task 001 complete ✅ (commit a1b2c3d)
Code Review (Stage 07) running for task 001...
```

### Reviewer for Task 001

**Reviewer produces** `07-review/self-review-001-add-idempotency-migration.md`:
```
Verdict: PASS

Acceptance criteria: all ✅
Issues: none
Security: migration is non-destructive; no data exposure; ✅
```

**Helmsman:**
```
Task 001 review: PASS ✅
Moving to Task 002...
```

### Tasks 002–005 — (abbreviated)

The loop continues. Each task:
- Implementer runs → commits → reports DONE
- Reviewer checks → PASS or PASS WITH COMMENTS
- Developer reviews reviewer report
- `/approve` advances to next task

**Notable moment — Task 004, Reviewer finds a Major issue:**

```
Verdict: PASS WITH COMMENTS

Issues:
I-01 🟠 Major | PaymentService.ts:L61 | ER_DUP_ENTRY is MySQL-specific;
               will silently fail in test environments using SQLite
               Recommendation: use ORM-level duplicate detection
```

**You see the review report and type:**
```
/comment --on 07-review/self-review-004-add-idempotency-check-service.md "Fix I-01 before we proceed"
```

**Helmsman routes the comment back to the Implementer.** Implementer updates `PaymentService.ts` to use ORM-level detection, recommits, Reviewer re-runs → PASS.

### Task 006 — Integration Tests

After all 6 tasks complete:

**`06-implementation/progress.md`:**
```
| Tasks complete | 6 / 6 |
...
| 006 integration-tests | complete | m0n1o2p | All 8 integration tests pass |
```

**Helmsman:**
```
All 6 tasks complete ✅
Implementation stage done.
Run /advance to proceed to Pre-Launch (Stage 08).
```

✅ **Checkpoint**: `progress.md` shows 6/6 tasks complete. `07-review/` has 6 `self-review-*.md` files, all PASS. Branch `helmsman/payments-idempotency` has all commits.

---

## Part 7 — Pre-Launch (Stage 08) — MVP Stub

**You type:**
```
/advance
```

**Helmsman (MVP stub — no specialist skill yet):**
```
Stage 7 (Code Review) complete ✅
Stage 8 (Pre-Launch) started 🔄

In MVP, Stage 08 is minimally guided. Please create the following
artifacts manually or with your team:

  08-pre-launch/test-plan.md           — unit + integration + manual test list
  08-pre-launch/rollout-plan.md        — feature flag or % rollout plan
  08-pre-launch/rollback-plan.md       — steps to revert if needed
  08-pre-launch/monitoring-checklist.md — what to watch after deploy
  08-pre-launch/pre-mortem.md          — what could go wrong

Templates available at: templates/pre-mortem.template.md (and others)

Run /approve when all five artifacts are ready.
```

**You create the 5 artifacts** (manually or by asking Claude to help, providing the design doc as context).

**You type:**
```
/approve
```

✅ **Checkpoint**: `08-pre-launch/` has 5 non-empty files.

---

## Part 8 — Launch & Dossier (Stage 09)

**You type:**
```
/advance
```

**Helmsman:**
```
Stage 8 complete ✅
Stage 9 (Launch) started.

You're ready to ship. When you're done with final checks, run:
  /dossier     — to compile the final project record
  /approve     — to mark the project complete
```

**You type:**
```
/dossier
```

**Helmsman compiles and writes** `projects/payments-idempotency/dossier.md`:

```markdown
# Project Dossier — payments-idempotency

> Compiled 2025-01-18 | Mode: feature | Status: complete

## TL;DR

Added idempotency support to POST /charge in payments-service. Callers can now
include an idempotency_key (UUID v4, ≤64 chars) to safely retry failed requests
without double-charging. Key decision: store idempotency state in our DB with a
unique constraint rather than delegating to Stripe's API, giving us full audit
trail ownership. All 6 implementation tasks complete; 8 integration tests added.

## Key Decisions (ADRs)

| ADR | Decision | Rationale |
|---|---|---|
| ADR-001 | DB-level idempotency storage | Full audit trail; provider-agnostic |

## What Was Built

| Tasks complete | 6 / 6 |
| Git branch | helmsman/payments-idempotency |
| Tests added | 14 (6 unit + 8 integration) |

## Artifacts Index

| Artifact | Path |
|---|---|
| Raw PRD | 01-prd/input.md |
| Clean PRD | 02-prd-clean/clean-prd.md |
| Tech Design | 04-tech-design/design.md |
| Task Index | 05-tasks/INDEX.md |
| Progress | 06-implementation/progress.md |
| Decision Log | decisions.log.md |
```

**Helmsman:**
```
📋 Dossier compiled: projects/payments-idempotency/dossier.md

Run /approve to mark the project complete.
```

**You type:**
```
/approve
```

**Helmsman:**
```
✅ Project payments-idempotency complete.

Stage 09 (Launch) approved.
All 9 stages complete.

Your project dossier is at:
  projects/payments-idempotency/dossier.md

Branch helmsman/payments-idempotency is ready to push/PR.
```

✅ **Checkpoint**: `dossier.md` exists and has all sections populated. `state.yaml` shows all 9 stages complete.

---

## Verification Checklist

Use this table to confirm a complete end-to-end run:

| # | Check | Expected |
|---|---|---|
| 1 | `manifest.yaml` exists | ✅ Has ≥1 repo registered |
| 2 | `projects/payments-idempotency/01-prd/input.md` | ✅ Contains original PRD text verbatim |
| 3 | `02-prd-clean/` has 5 files | ✅ clean-prd, assumptions, open-questions, out-of-scope, risks |
| 4 | `clean-prd.md` has Goals + ACs + Non-Goals + Constraints | ✅ All sections present and non-empty |
| 5 | `03-discovery/` has 5 files | ✅ codebase-findings, external-research, stakeholder-map, dependencies, prior-art |
| 6 | `04-tech-design/alternatives.md` has ≥ 2 options | ✅ Option A and B with pros/cons |
| 7 | `04-tech-design/adrs/` has ≥ 1 ADR | ✅ `001-idempotency-storage.md` |
| 8 | `05-tasks/INDEX.md` has dependency graph | ✅ ASCII or Mermaid graph present |
| 9 | Each task file has acceptance criteria | ✅ All 6 tasks have ≥1 checkbox AC |
| 10 | `06-implementation/progress.md` shows 6/6 complete | ✅ All tasks have commit SHA |
| 11 | `07-review/` has 6 self-review files | ✅ All show PASS or PASS WITH COMMENTS |
| 12 | `decisions.log.md` has ≥8 entries | ✅ Append-only; one per significant action |
| 13 | `state.yaml` shows all 9 stages complete | ✅ `approved_at` set on all stages |
| 14 | `dossier.md` exists and has TL;DR + ADR table | ✅ Compiled from source artifacts |
| 15 | Branch `helmsman/payments-idempotency` exists | ✅ All implementation commits present |

---

## What This Walkthrough Tests

Every major Helmsman workflow has been exercised:

| Workflow | Where demonstrated |
|---|---|
| First-time setup | Part 0 — `/helmsman-init` |
| Project creation + PRD save | Part 1 — `/start-project` |
| Agent → review → comment → revise loop | Part 2 — PRD Review with Q&A |
| Approval and advance | Parts 2–7 — `/approve` + `/advance` |
| Discovery agent with codebase read | Part 3 — Researcher |
| Tech design with alternatives + ADR | Part 4 — Architect (designer) |
| Task breakdown with dependency graph | Part 5 — Architect (planner) |
| Implementation TDD loop | Part 6 — Implementer |
| Code review with issue routing | Part 6 — Reviewer finding Major issue |
| Comment routing back to Implementer | Part 6 — Task 004 fix loop |
| Pre-launch stage (MVP stub) | Part 7 — manual artifact creation |
| Dossier compilation | Part 8 — `/dossier` |
| Project completion | Part 8 — final `/approve` |
| Decision log integrity | Throughout — append-only entries |
| State machine correctness | `state.yaml` checked at each checkpoint |
