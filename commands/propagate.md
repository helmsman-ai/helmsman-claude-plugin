---
name: propagate
description: >
  Re-run all stale stages in pipeline order. For each stale doc stage: snapshot,
  re-run specialist agent, diff, present for approval. For the implementation stage:
  produce a Change Impact Report instead. Never auto-reruns implementation.
arguments:
  - name: --abort
    description: "Optional. Abort an in-progress propagation and restore all stale snapshots."
    required: false
---

# `/propagate` Command

## Purpose

Drive forward propagation after a `/jump-back`. Processes each stale stage in pipeline
order: takes a snapshot, re-runs the specialist agent with updated upstream context,
produces a diff, and asks for user approval before committing the new version.

**Critical invariants** (from `docs/PROPAGATION.md §9`):
- Implementation stage is **never** re-run — a Change Impact Report is produced instead.
- Every stage change requires explicit user approval — no silent overwrites.
- Snapshot is always taken before agent re-run — data is never lost.
- If a snapshot cannot be written, propagation aborts for that stage.

## Syntax

```
/propagate
/propagate --abort
```

---

## Step-by-Step Behavior

### Step 1 — Check prerequisites

Read `state.yaml`:

| Condition | Response |
|---|---|
| `propagation.stale_stages` is empty | "No stale stages. Nothing to propagate. Run `/jump-back <stage>` first." |
| `propagation.in_progress: true` | "Propagation was interrupted. Run `/propagate` to resume from the next stale stage, or `/propagate --abort` to cancel and restore all snapshots." |
| No active project | "No active project. Use `/switch <name>` or `/start-project`." |

### Step 2 — Set `in_progress: true`

Update `state.yaml`:
```yaml
propagation:
  in_progress: true
```

Append to `history`:
```yaml
- at: "<ISO 8601 timestamp>"
  action: propagation_started
  stage: "<first stale stage in stage_order>"
  note: "Propagation started. Stale stages: [<list>]"
```

Append to `decisions.log.md`:
```markdown
## <YYYY-MM-DD HH:MM> — Propagation started

Stage: <first stale stage>
Action: propagation_started

Propagation initiated. Stale stages to process in order: <list>.
Reason for original jump-back: <propagation.last_jump_back.reason>.
```

### Step 3 — Process each stale stage in order

Determine the order by reading `stage_order` and filtering to only stages in `propagation.stale_stages`. Process from earliest to latest.

**Gate: only process the implementation stage after all doc stages in `stale_stages` are approved.** If any doc stage is still pending, skip the implementation stage in this pass.

#### 3a. If the stage is the implementation stage (agent is `implementer`)

Skip to **Step 4 — Change Impact Report**.

#### 3b. For all other stale stages (doc stages)

##### i. Snapshot

1. Collect all files currently in `projects/<name>/<stage-id>/` (including subdirectories).
2. Create directory: `projects/<name>/.snapshots/<YYYYMMDD-HHMMSS>-<stage-id>/files/`.
3. Copy all collected files into that directory, preserving subdirectory structure.
4. Write `projects/<name>/.snapshots/<YYYYMMDD-HHMMSS>-<stage-id>/MANIFEST.yaml` using `templates/snapshot-manifest.template.yaml`. Populate all fields: `id`, `project`, `stage`, `created_at`, `trigger: "propagate"`, `reason`, `files` (list of paths), `diff_path: null`, `restored: false`, `upstream_context` (approved_at for each upstream stage).
5. Append snapshot entry to `state.yaml.snapshots[]`.
6. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: snapshot_created
     stage: "<stage-id>"
     note: "Snapshot <id> created before propagation re-run"
   ```
7. **If the snapshot cannot be written** (disk error, permission error): set `propagation.in_progress: false`; report error to user; do not proceed to the re-run step.

##### ii. Re-run agent

Invoke the stage's specialist sub-agent (read `stages[stage-id].agent` from `state.yaml`). Curate context:
- Stage's `SKILL.md` + `INSTRUCTIONS.md`
- All approved upstream stage artifacts (current versions, not snapshots)
- Project memory (`CLAUDE.md`)
- Global memory

Add the propagation context block to the agent's instructions:
```
## ⚠️ Propagation Context

This is a propagation re-run, not a fresh start. You are re-running a stage
that was previously completed. The upstream context has changed.

Reason for change: <propagation.last_jump_back.reason>

Your previous output has been snapshotted to:
  .snapshots/<snapshot-id>/files/

Please re-analyze the updated upstream artifacts and produce new artifacts
for this stage. Focus on what has actually changed — do not rewrite content
that is still accurate.
```

##### iii. Produce diff

Compare new artifacts (in `projects/<name>/<stage-id>/`) against snapshot files (in `.snapshots/<id>/files/`):
- File in both: produce a unified diff per `docs/PROPAGATION.md §6` rules (3-line context, 150-line truncation with note).
- File only in new artifacts: label `[NEW FILE]`.
- File only in snapshot: label `[DELETED FILE]`.

Concatenate all file diffs into a single Markdown document and write it to `.snapshots/<id>/DIFF.md`. Set `snapshots[<id>].diff_path` in `state.yaml`.

##### iv. Present diff and ask for approval

> ## Propagation: Stage `<N>` — `<label>`
>
> The `<agent-name>` agent has re-run this stage with updated upstream context.
> Diff vs. previous version:
>
> <diff content>
>
> ---
> **Accept this change?** Type `yes` to accept, `no` to reject and restore, or `edit` to pause for manual edits.

##### v. Handle user response

**`yes` — Approved:**
1. Remove stage from `propagation.stale_stages`.
2. Set `stages[id].status` to `complete`.
3. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: propagation_stage_approved
     stage: "<stage-id>"
     note: "Propagated changes approved by user. Snapshot: <snapshot-id>"
   ```
4. Append to `decisions.log.md`:
   ```markdown
   ## <YYYY-MM-DD HH:MM> — Propagation approved: <stage-label>

   Stage: <stage-id>
   Action: propagation_stage_approved

   User approved the re-run of Stage <N> (<label>) during propagation.
   Snapshot: <snapshot-id>. Diff: .snapshots/<id>/DIFF.md.

   Key decisions:
     - Accepted propagated version of <stage-id> over snapshot

   Artifacts affected:
     - <stage-dir>/<file>: updated by propagation re-run
   ```
5. Continue to the next stale stage (repeat Step 3).

**`no` — Rejected:**
1. Restore files: copy `.snapshots/<id>/files/` back to `projects/<name>/<stage-id>/`, preserving subdirectory structure.
2. Set `snapshots[<id>].restored = true` in `state.yaml`.
3. Keep stage in `propagation.stale_stages`.
4. Set `propagation.in_progress: false`.
5. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: propagation_stage_rejected
     stage: "<stage-id>"
     note: "Propagated changes rejected; snapshot restored"
   ```
6. Append to `decisions.log.md` (same format as approved, but `Action: propagation_stage_rejected` and note the restore).
7. Tell user:
   > ❌ **Propagation paused.** Stage `<N>` — `<label>` rejected; snapshot restored.
   >
   > Options:
   > - Edit `projects/<name>/<stage-id>/` artifacts manually, then run `/propagate` to resume.
   > - Run `/jump-back <earlier-stage>` to start from further back.
   > - Run `/propagate --abort` to cancel the entire propagation and restore all changed stages.

**`edit` — Pause for manual edits:**
1. Set `propagation.in_progress: false`.
2. Do not restore; do not advance. Files remain as produced by the agent.
3. Tell user:
   > ⏸️ **Propagation paused for manual edits.**
   > Edit files in `projects/<name>/<stage-id>/`, then run `/propagate` to resume from this stage.

### Step 4 — Change Impact Report (implementation stage)

Only reached when all doc stages in `stale_stages` are approved and the implementation stage remains.

1. Read all task files from the tasks stage directory (e.g., `projects/<name>/05-tasks/`).
2. Read all diffs produced in Steps 3b-iii (from `.snapshots/*/DIFF.md` for each approved stage).
3. For each task, analyze against the upstream diffs:
   - Does this task reference areas that changed in the upstream diffs?
   - Is the task's acceptance criteria still valid?
   - Does the task's approach conflict with any new design decisions?
4. Categorize each task:
   - `leave`: No meaningful impact. Task can proceed as written.
   - `amend`: Minor updates needed (interface names, new constraints). Task is largely intact.
   - `redo`: Significant rework needed. Core approach or scope is invalidated.
5. Write the CIR to `projects/<name>/<impl-stage>/change-impact-report.md` using `templates/change-impact-report.template.md`.
6. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: cir_produced
     stage: "<impl-stage>"
     note: "Change Impact Report written to <impl-stage>/change-impact-report.md"
   ```
7. Append to `decisions.log.md`:
   ```markdown
   ## <YYYY-MM-DD HH:MM> — Change Impact Report produced

   Stage: <impl-stage>
   Action: cir_produced

   Change Impact Report generated for the implementation stage after upstream propagation.
   Report: <impl-stage>/change-impact-report.md

   Summary:
     - leave: <N> tasks
     - amend: <N> tasks
     - redo: <N> tasks
   ```
8. Set `propagation.in_progress: false`.
9. Present to user:
   > ## Change Impact Report Ready
   >
   > Upstream changes have been analyzed against your implementation tasks.
   > See: `projects/<name>/<impl-stage>/change-impact-report.md`
   >
   > Summary: X leave · Y amend · Z redo
   >
   > **Review the report, then run `/approve <impl-stage>/change-impact-report.md` to acknowledge it.**
   > This does NOT restart the implementation loop — you decide which tasks to re-run.

### Step 5 — CIR acknowledgement (triggered by `/approve <impl-stage>/change-impact-report.md`)

When the user runs `/approve` on the CIR file:
1. Remove the implementation stage from `propagation.stale_stages`.
2. Verify `propagation.stale_stages` is now empty.
3. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: cir_acknowledged
     stage: "<impl-stage>"
     note: "User acknowledged Change Impact Report; propagation complete"
   ```
4. Append to `decisions.log.md`.
5. Tell user:
   > ✅ **Propagation complete.** All stale stages have been re-run and approved.
   >
   > Resume the pipeline with `/advance`, or re-run specific tasks by referencing them.

---

## Aborting Propagation (`/propagate --abort`)

1. Read `propagation.stale_stages` and `state.yaml.snapshots[]`.
2. For each stale stage that has a snapshot with `restored: false`:
   - Copy `.snapshots/<id>/files/` back to `projects/<name>/<stage>/`.
   - Set `snapshots[<id>].restored = true`.
3. Set `propagation.in_progress: false`.
4. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: propagation_aborted
     stage: "<first stale stage>"
     note: "Propagation aborted by user. Snapshots restored for: [<list>]"
   ```
5. Append to `decisions.log.md`.
6. Tell user:
   > 🛑 **Propagation aborted.** Snapshots restored for all re-run stages:
   > - `<stage>`: restored from `<snapshot-id>`
   >
   > Stale stages remain stale. Run `/propagate` again when ready.

---

## Error Cases

| Situation | Response |
|---|---|
| No stale stages | "Nothing to propagate. Run `/jump-back` first." |
| No active project | "No active project." |
| Agent fails to produce artifacts | "Agent did not produce expected artifacts for `<stage>`. Check the output and run `/propagate` to retry." |
| Snapshot write fails | Set `in_progress: false`; report error; do not re-run the agent. |
| Snapshot ID collision (already exists) | Append `-v2` suffix to snapshot ID and proceed. |

---

## State Changes

| File | What changes |
|---|---|
| `state.yaml` | `in_progress` toggled; `stale_stages` updated; `snapshots[]` appended; stage statuses updated; history appended |
| `decisions.log.md` | Entry appended for each stage processed |
| `projects/<name>/<stage>/` | Overwritten by agent (or restored from snapshot on rejection) |
| `projects/<name>/.snapshots/<id>/` | Created with files + MANIFEST.yaml + DIFF.md |
| `projects/<name>/<impl-stage>/change-impact-report.md` | Written when impl stage is stale |
