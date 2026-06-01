# Propagation Walkthrough — Helmsman v1.M2

> **Purpose**: End-to-end integration test and narrative documentation for the jump-back
> and change propagation system.
>
> **Scenario**: A feature project at Stage 06 (Implementation) discovers a key requirement
> changed — auth switches from session tokens to JWT. The developer jumps back to Stage 02
> (PRD Clean), updates the requirement, then propagates forward through Discovery, Tech
> Design, and Tasks before resuming implementation.
>
> **Time to complete**: ~30 minutes for a full manual run.

---

## Prerequisites

Before starting this walkthrough:

- A Helmsman workspace exists (`manifest.yaml` is configured).
- A project named `auth-refactor` has been started in `feature` mode.
- The project has advanced through all stages up to and including Stage 06 (Implementation).
- Stages 02 through 05 have `status: complete` in `state.yaml`.
- At least 5 tasks exist in `projects/auth-refactor/05-tasks/`.
- Stage 06 (Implementation) is `in-progress` with at least 3 tasks complete.

---

## Step 1: Verify Initial State

Run: `/status`

**Expected output** (abbreviated):
```
Project: auth-refactor
Mode: feature
Current stage: 06-implementation (in-progress)
  Tasks: 3/10 complete

  ✅ 01-prd         complete
  ✅ 02-prd-clean   complete
  ✅ 03-discovery   complete
  ✅ 04-tech-design complete
  ✅ 05-tasks       complete
  🔄 06-implementation in-progress
```

**Verify in `state.yaml`**:
- [ ] `current_stage: "06-implementation"`
- [ ] `propagation.stale_stages: []`
- [ ] `propagation.in_progress: false`
- [ ] `snapshots: []`

---

## Step 2: Jump Back to PRD Clean

Run:
```
/jump-back 02-prd-clean --reason "Auth requirement changed: switching from session tokens to JWT per security team decision"
```

**Expected confirmation prompt**:
```
You are about to jump back to Stage 02-prd-clean — PRD Clean.

The following stages will be marked stale (files preserved, flagged for re-run):
- 03-discovery — Discovery & Research
- 04-tech-design — Technical Design
- 05-tasks — Task Breakdown
- 06-implementation — Implementation

Type yes to confirm, or anything else to cancel.
```

Type: `yes`

**Expected response**:
```
✅ Jumped back to Stage 02-prd-clean — PRD Clean.

Stale stages (files preserved, pending re-run):
- 03-discovery
- 04-tech-design
- 05-tasks
- 06-implementation

Next steps:
1. Update the artifacts in projects/auth-refactor/02-prd-clean/ as needed.
2. Run /propagate to re-run all stale stages in order.
```

**Verify `state.yaml`**:
- [ ] `current_stage: "02-prd-clean"`
- [ ] `propagation.stale_stages: ["03-discovery", "04-tech-design", "05-tasks", "06-implementation"]`
- [ ] `propagation.last_jump_back.from_stage: "06-implementation"`
- [ ] `propagation.last_jump_back.to_stage: "02-prd-clean"`
- [ ] `propagation.last_jump_back.reason` contains "JWT"

**Verify `decisions.log.md`**:
- [ ] Contains a `jumped_back` entry with the reason

**Verify artifacts**:
- [ ] `projects/auth-refactor/03-discovery/` files still exist (not deleted)
- [ ] `projects/auth-refactor/04-tech-design/` files still exist (not deleted)

---

## Step 3: Update the PRD

Manually edit `projects/auth-refactor/02-prd-clean/clean-prd.md`:
- Change: "Auth uses session tokens stored in Redis" → "Auth uses JWT stored client-side"
- Add constraint: "JWT secret must be rotated every 90 days"
- Add constraint: "JWTs must expire after 1 hour"

Save the file.

Run `/approve 02-prd-clean/clean-prd.md` to mark the updated artifact as accepted.

**Verify**: No error. The PRD artifact is now the updated version.

---

## Step 4: Run Propagate — Discovery Stage

Run: `/propagate`

**Expected output (phase 1 — Discovery)**:
```
Propagation started. Stale stages to process: 03-discovery, 04-tech-design, 05-tasks, 06-implementation.

--- Propagating Stage 03-discovery: Discovery & Research ---

Snapshot taken: .snapshots/20260523-HHMMSS-03-discovery/
Researcher agent re-running with updated PRD context...
[agent completes]

Diff: 03-discovery/research-findings.md
────────────────────────────────────────
- The system uses session tokens stored in Redis.
+ The system uses JWTs stored client-side (updated per PRD).
  Rate limiting is handled by the API gateway.
- No external identity provider is used.
+ Auth0 is the external identity provider (new per security team decision).
────────────────────────────────────────

Accept this change? Type yes to accept, no to reject and restore, or edit to pause for manual edits.
```

Type: `yes`

**Verify after approval**:
- [ ] `03-discovery` removed from `propagation.stale_stages`
- [ ] `stages["03-discovery"].status: complete`
- [ ] Snapshot directory exists: `projects/auth-refactor/.snapshots/*-03-discovery/`
- [ ] Snapshot has `MANIFEST.yaml` and `DIFF.md`
- [ ] `snapshots[]` in `state.yaml` has one entry with `restored: false`
- [ ] `decisions.log.md` has a `propagation_stage_approved` entry

---

## Step 5: Propagate — Tech Design Stage

Propagation continues automatically to Stage 04.

**Expected output**:
```
--- Propagating Stage 04-tech-design: Technical Design ---

Snapshot taken: .snapshots/20260523-HHMMSS-04-tech-design/
Architect agent re-running...
[agent completes]

Diff: 04-tech-design/design.md
[diff content shown]

Accept this change? Type yes to accept, no to reject and restore, or edit to pause for manual edits.
```

Type: `yes`

**Verify**:
- [ ] `04-tech-design` removed from `propagation.stale_stages`
- [ ] Second snapshot created: `*-04-tech-design/`

---

## Step 6: Propagate — Tasks Stage

**Expected output**:
```
--- Propagating Stage 05-tasks: Task Breakdown ---

Snapshot taken: .snapshots/20260523-HHMMSS-05-tasks/
Architect agent re-running...
[agent completes]

Diff: 05-tasks/INDEX.md and task files
[diff shown]

Accept this change? yes / no / edit
```

Type: `yes`

**Verify**:
- [ ] `05-tasks` removed from `propagation.stale_stages`
- [ ] Third snapshot created: `*-05-tasks/`

---

## Step 7: Change Impact Report

After all doc stages are approved, propagation automatically processes the implementation stage.

**Expected output**:
```
## Change Impact Report Ready

Upstream changes have been analyzed against your implementation tasks.
See: projects/auth-refactor/06-implementation/change-impact-report.md

Summary: X leave · Y amend · Z redo

Review the report, then run /approve 06-implementation/change-impact-report.md to acknowledge it.
This does NOT restart the implementation loop — you decide which tasks to re-run.
```

**Verify**:
- [ ] File exists: `projects/auth-refactor/06-implementation/change-impact-report.md`
- [ ] CIR contains "What Changed Upstream" section with 3 stage entries (03, 04, 05)
- [ ] CIR contains per-task analysis for ALL tasks
- [ ] Each task is categorized as `leave`, `amend`, or `redo`
- [ ] CIR contains a Summary table
- [ ] CIR contains Recommended Next Steps ending with `/approve` instruction
- [ ] `propagation.in_progress: false`
- [ ] `06-implementation` still in `stale_stages` (not yet acknowledged)
- [ ] `decisions.log.md` has a `cir_produced` entry with leave/amend/redo counts

---

## Step 8: Acknowledge CIR

Review the Change Impact Report at `projects/auth-refactor/06-implementation/change-impact-report.md`.

Run: `/approve 06-implementation/change-impact-report.md`

**Expected output**:
```
✅ Propagation complete. All stale stages have been re-run and approved.

Resume the pipeline with /advance, or re-run specific tasks by referencing them.
```

**Verify `state.yaml`**:
- [ ] `propagation.stale_stages: []` (empty — all resolved)
- [ ] `propagation.in_progress: false`
- [ ] `history[]` contains a `cir_acknowledged` entry

**Verify `decisions.log.md`**:
- [ ] Contains a `cir_acknowledged` entry

---

## Step 9: Verify Snapshots

Run: `/snapshots`

**Expected**: Table showing 3 snapshots (03-discovery, 04-tech-design, 05-tasks). No `[RESTORED]` annotations.

**Verify on disk**:
- [ ] `projects/auth-refactor/.snapshots/*-03-discovery/MANIFEST.yaml` exists
- [ ] `projects/auth-refactor/.snapshots/*-03-discovery/DIFF.md` exists
- [ ] `projects/auth-refactor/.snapshots/*-03-discovery/files/` directory exists

---

## Step 10: Verify Propagation History

Run: `/propagation-history`

**Expected**: Timeline showing:
- 1 JUMP-BACK event
- 1 PROPAGATION started
- 3 SNAPSHOT events
- 3 APPROVED events
- 1 CIR event
- 1 CIR ACK event

**Summary line should read**: `Total: 1 jump-back | 1 propagation run | 3 stages re-run | 0 rejections | 3 snapshots`

---

## Step 11: Rejection Recovery Test

This optional step verifies the rejection and restore flow.

### 11a: Jump back again

Run: `/jump-back 03-discovery --reason "Testing rejection recovery"`

Type: `yes`

### 11b: Run propagate and reject

Run: `/propagate`

When the diff for `03-discovery` appears, type: `no`

**Expected output**:
```
❌ Propagation paused. Stage 03-discovery rejected; snapshot restored.

Options:
- Edit projects/auth-refactor/03-discovery/ manually, then run /propagate to resume.
- Run /jump-back <earlier-stage> to start from further back.
- Run /propagate --abort to cancel the entire propagation and restore all changed stages.
```

**Verify**:
- [ ] Files in `03-discovery/` are restored to pre-re-run state
- [ ] A new snapshot exists with `restored: true`
- [ ] `03-discovery` still in `stale_stages`
- [ ] `propagation.in_progress: false`

### 11c: Abort propagation

Run: `/propagate --abort`

**Expected output**:
```
🛑 Propagation aborted. Snapshots restored for all re-run stages:
[list of stages]

Stale stages remain stale. Run /propagate again when ready.
```

**Verify**:
- [ ] `propagation.in_progress: false`
- [ ] Stale stages still listed in `propagation.stale_stages`

---

## Data Integrity Checklist

After completing the walkthrough (Steps 1–10), verify all invariants from `docs/PROPAGATION.md §9`:

- [ ] **Invariant 1 — No data lost**: Original artifacts from before propagation are in `.snapshots/*/files/`
- [ ] **Invariant 2 — Implementation not auto-run**: Only the CIR was produced; the `implementer` agent was not invoked
- [ ] **Invariant 3 — Every step required approval**: Each of the 3 stages needed an explicit `yes` before proceeding
- [ ] **Invariant 4 — state.yaml consistent**: `stale_stages: []` at end; `snapshots[]` has 3 entries; all match disk
- [ ] **Invariant 5 — Partial state recoverable**: Tested in Step 11 — rejection + abort works correctly
- [ ] **Invariant 6 — Diffs durable**: Each `.snapshots/*/DIFF.md` is readable and accurately reflects what changed

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `/propagate` says "Nothing to propagate" | `/jump-back` wasn't run, or stale_stages is empty | Run `/jump-back <stage>` first |
| Snapshot directory is empty | Agent failed to write artifacts | Check agent output; re-run `/propagate` |
| CIR shows all tasks as `redo` | Upstream changes were very broad | Review the diffs and reconsider the scope of the jump-back |
| `/propagate --abort` didn't restore a stage | Stage didn't have a snapshot (rejection already restored it) | Check `snapshots[].restored` — stage was already restored on rejection |
| `propagation.in_progress: true` on startup | Orchestrator crashed mid-propagation | Run `/propagate` to resume or `/propagate --abort` to cancel |
