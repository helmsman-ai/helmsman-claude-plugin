# Helmsman Propagation Architecture

> **Status**: v1.M2 canonical spec
> **Scope**: Jump-back, snapshot system, forward propagation, Change Impact Report
> **See also**: `docs/SCHEMAS.md` for state.yaml field reference; `commands/jump-back.md`, `commands/propagate.md` for user-facing behavior

---

## 1. Mental Model

A Helmsman project is a pipeline. Stages flow forward: PRD → Discovery → Design → Tasks → Implementation. Each stage's artifacts are built on the ones before it.

When a requirement changes, you don't start over — you **jump back** to the stage where the change belongs, update the artifacts there, then **propagate** forward. Propagation re-runs each downstream doc stage with the updated upstream context, shows you a diff, and asks for approval before committing the new version.

Implementation is never re-run automatically. Instead, propagation produces a **Change Impact Report** that tells you which tasks need to be redone, amended, or left alone. You decide what to do with them.

---

## 2. Definitions

| Term | Meaning |
|---|---|
| **Jump-back** | Move `current_stage` backward; mark downstream stages `stale` |
| **Stale stage** | A stage whose artifacts may no longer reflect upstream reality. Files retain their pre-propagation content (either original or snapshot-restored after rejection). |
| **Snapshot** | A timestamped copy of a stage's files, taken before any propagation re-run |
| **Propagate** | Re-run stale doc stages in order, diff vs. snapshot, get user approval |
| **Change Impact Report (CIR)** | An analysis (not a re-run) of how upstream changes affect the implementation task list |
| **Diff** | A side-by-side or unified view of old (snapshot) vs. new (re-run) artifact content |

---

## 3. State Machine

```
normal (no stale stages)
  └─► jumped_back
        │  stages[downstream].status = "stale"
        │  propagation.stale_stages populated
        └─► propagating
              │  each stale doc stage:
              │    snapshot → re-run → diff → user approves → non-stale
              │  if rejected: restore snapshot
              └─► normal (stale_stages empty)
                    └─► [impl stage stale]: CIR produced, no auto-rerun
```

> **Note**: `jumped_back` is not a field in `state.yaml` — it is the condition where `propagation.stale_stages` is non-empty and `in_progress` is `false`. The diagram labels this state for readability only.

---

## 4. Propagation Algorithm

### 4.1 When `/jump-back <target>` is called

1. Read `state.yaml`: get `current_stage` and `stage_order`.
2. Validate `<target>` is a valid stage ID that appears **before** `current_stage` in `stage_order`.
3. If any stage between `target` and `current_stage` has `status: in-progress` (agent is mid-run): block and warn.
4. Save the current value of `current_stage` as `previous_stage`.
5. Set `current_stage` to `<target>`.
6. For each stage **after** `<target>` up to and including `previous_stage`:
   - Set `stages[id].status` to `"stale"` (a new status value, after `complete`).
   - Add the stage ID to `propagation.stale_stages`.
7. Record `propagation.last_jump_back` with timestamp, from/to stages, and user-provided reason.
8. Append `jumped_back` action to `history`.
9. Append to `decisions.log.md`.
10. **Do NOT delete any artifact files.**

### 4.2 When `/propagate` is called

Set `propagation.in_progress` to `true` before processing the first stale stage. When `stale_stages` becomes empty, set `propagation.in_progress` back to `false`.

Read `propagation.stale_stages`. Process each stale stage **in stage_order sequence** (earliest first):

**For each stale DOC stage** (any stage before implementation that uses an agent):

1. **Snapshot**: copy all files in `projects/<p>/<stage>/` to
   `projects/<p>/.snapshots/<YYYYMMDD-HHMMSS>-<stage-id>/files/`.
   Write `.snapshots/<id>/MANIFEST.yaml` using the fields from `templates/snapshot-manifest.template.yaml`: `id`, `project`, `stage`, `created_at`, `trigger`, `reason`, `files`, `diff_path` (null initially), `restored` (false initially), `upstream_context` (upstream stage versions at snapshot time).
   Append snapshot metadata to `state.yaml.snapshots`.
   If the snapshot cannot be written (e.g., disk error), abort propagation for this stage: set `in_progress: false` and report the error to the user. Do not proceed to the re-run step.

2. **Re-run**: invoke the stage's specialist sub-agent with:
   - The stage's `SKILL.md` + `INSTRUCTIONS.md`
   - All approved upstream stage artifacts (not snapshotted — the current, possibly changed versions)
   - Project memory (`CLAUDE.md`)
   - The propagation context: what changed and why

3. **Diff**: compare new artifacts (in stage dir) vs. snapshot files.
   Produce a unified diff in Markdown format (see §6).

4. **Present to user**: show the diff; ask for approval or rejection.

5. **If approved**:
   - Remove stage from `propagation.stale_stages`.
   - Set `stages[id].status` back to `complete` (it was already approved before the jump-back).
   - Append `propagation_stage_approved` to `history`.

6. **If rejected**:
   - Restore files from snapshot (copy back from `.snapshots/<id>/files/`).
   - Keep stage in `propagation.stale_stages`.
   - Set `propagation.in_progress` to `false`.
   - Tell user: "Propagation paused. Snapshot restored. Run `/propagate` again after manual edits, or `/jump-back` to a different stage."

**For the implementation stage** (`06-implementation` or equivalent):

**Only process the implementation stage after all doc stages in `stale_stages` have been approved. If any doc stage is still pending, skip the implementation stage in this pass and process it after the remaining doc stages complete.**

- **Never re-run the implementer.**
- Instead, produce a **Change Impact Report** (§5).
- The CIR is written to `projects/<p>/<impl-stage>/change-impact-report.md`.
- Remove the implementation stage from `propagation.stale_stages` only after the user runs `/approve <impl-stage>/change-impact-report.md` to acknowledge the CIR.

### 4.3 Abort Recovery

If `propagation.in_progress` is `true` when the Orchestrator starts up (indicating a crash or abort mid-propagation):

1. Read `propagation.stale_stages` to find which stages are still pending.
2. Read `snapshots[]` to find which snapshots exist.
3. Tell the user: "It looks like propagation was interrupted. You can: (a) run `/propagate` to resume from the next stale stage, or (b) run `/propagate --abort` to restore all snapshots and cancel propagation."
4. On `--abort`: restore all snapshots for stages still in `stale_stages`; set `in_progress: false`.

---

## 5. Change Impact Report (CIR)

Produced when the implementation stage is stale after propagation of doc stages.

### 5.1 When it's produced

After all doc stages have been propagated and approved, if `06-implementation` (or the mode's equivalent) is in `stale_stages`, the Orchestrator generates the CIR by:

1. Reading every task file in `05-tasks/` (or equivalent).
2. Reading the diffs from all upstream propagations (stored in `.snapshots/<id>/DIFF.md`).
3. Analyzing each task against the upstream changes.
4. Categorizing each task as `redo`, `amend`, or `leave`.

### 5.2 CIR Format

See `templates/change-impact-report.template.md`.

### 5.3 CIR Approval

The user runs `/approve <impl-stage>/change-impact-report.md` to acknowledge the CIR.
This removes the implementation stage from `stale_stages` but does NOT restart the implementation loop.
The user decides which tasks to re-run by running `/advance` to resume normal pipeline flow from the current point.

---

## 6. Diff Format

Diffs are stored in Markdown with unified-diff fencing. Example:

````markdown
### Diff: `03-discovery/research-findings.md`

```diff
- The system currently uses session tokens stored in Redis.
+ The system currently uses JWTs stored client-side (changed: auth requirement updated).
  Rate limiting is handled by the API gateway.
- No external identity provider is used.
+ Auth0 is the external identity provider (new requirement from PRD change).
```
````

Rules:
- Lines prefixed `-` are from the snapshot (old).
- Lines prefixed `+` are from the re-run (new).
- Lines with no prefix are unchanged context.
- Limit context to 3 surrounding lines per change block.
- If a file is entirely new or entirely deleted, say so explicitly rather than diffing.
- Maximum diff length before truncation: 150 lines. Truncate with a note: `[... N additional lines changed — see full file at <path>]`.

---

## 7. Snapshot Directory Structure

```
projects/<project-name>/
└── .snapshots/
    └── 20260523-143022-04-tech-design/
        ├── MANIFEST.yaml        ← snapshot metadata
        ├── DIFF.md              ← diff produced after re-run (written post-propagation)
        └── files/
            ├── design.md
            ├── alternatives.md
            └── adrs/
                └── 001-use-postgres.md
```

Snapshots are **never deleted automatically**. The `/snapshots` command can list them and optionally restore one.

---

## 8. state.yaml New Fields

### `propagation` (top-level)

```yaml
propagation:
  stale_stages: []             # list of stage IDs currently stale; empty = normal state
  in_progress: false           # true while /propagate is executing
  last_jump_back:              # null if no jump-back has occurred
    at: "2026-05-23T14:30:00Z"
    from_stage: "04-tech-design"
    to_stage: "02-prd-clean"
    reason: "Changed auth requirement from session tokens to JWT"
```

### `snapshots` (top-level)

```yaml
snapshots:
  - id: "20260523-143022-04-tech-design"
    stage: "04-tech-design"
    created_at: "2026-05-23T14:30:22Z"
    trigger: "propagate"       # "propagate" | "manual"
    reason: "Propagating jump-back from 02-prd-clean"
    diff_path: ".snapshots/20260523-143022-04-tech-design/DIFF.md"   # null until diff produced
    restored: false            # true if snapshot was restored (rejection)
```

### New `history` action types

- `jumped_back` — already defined in MVP schema
- `propagation_started` — `/propagate` invoked
- `propagation_stage_approved` — user approved a stage's diff
- `propagation_stage_rejected` — user rejected; snapshot restored
- `propagation_aborted` — user ran `/propagate --abort`
- `snapshot_created` — a snapshot was taken
- `cir_produced` — Change Impact Report generated
- `cir_acknowledged` — user ran `/approve` on the CIR

### New `stages[].status` value

- `stale` — artifacts exist but may not reflect current upstream; downstream of a jump-back

---

## 9. Invariants (Never Violate)

1. **Original artifacts are never lost**: snapshot before every re-run.
2. **Implementation is never auto-rerun**: only CIR is produced.
3. **Every propagation step requires explicit user approval**: no silent overwrites.
4. **`state.yaml` is the source of truth for propagation state**: `stale_stages` + `snapshots` are always consistent.
5. **Partial propagation is recoverable**: `in_progress` flag + snapshot audit log enable resume or abort.
6. **Diffs are stored durably**: every diff is written to `.snapshots/<id>/DIFF.md` so it can be reviewed later.
