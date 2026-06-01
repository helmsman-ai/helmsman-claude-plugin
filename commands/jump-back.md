---
name: jump-back
description: >
  Move the project's current_stage backward to a specified stage. Marks all
  downstream stages as stale. Does not delete artifacts. Logs to decision log.
arguments:
  - name: stage
    description: "Required. The stage ID to jump back to. Example: /jump-back 02-prd-clean"
    required: true
  - name: --reason
    description: "Optional but strongly recommended. Human-readable reason for the jump-back."
    required: false
  - name: --force
    description: "Optional. Skip the in-progress stage warning and proceed anyway."
    required: false
---

# `/jump-back <stage>` Command

## Purpose

Step the pipeline backward to an earlier stage so the user can update artifacts there.
All stages between the target and the old `current_stage` are marked `stale` — their
artifacts remain untouched until `/propagate` is run.

**Common use case**: "I changed my mind about a requirement. I need to update the PRD
and then have Discovery, Tech Design, and Tasks re-analyzed against the new PRD."

## Syntax

```
/jump-back <stage-id>
/jump-back <stage-id> --reason "<reason>"
```

**Examples**:
```
/jump-back 02-prd-clean
/jump-back 02-prd-clean --reason "Changed auth from session tokens to JWT"
/jump-back 03-discovery --reason "New dependency discovered during implementation"
```

---

## Step-by-Step Behavior

### Step 1 — Read current state

Read `state.yaml`:
- `current_stage`
- `stage_order`
- `propagation.stale_stages`

### Step 2 — Validate target stage

| Condition | Response |
|---|---|
| `<stage>` not in `stage_order` | "Stage `<stage>` is not recognized. Valid stages: `<stage_order list>`." |
| `<stage>` equals `current_stage` | "Already at stage `<stage>`. Nothing to do." |
| `<stage>` appears **after** `current_stage` in `stage_order` | "Cannot jump forward with `/jump-back`. Use `/advance` to move forward." |
| `<stage>` already in `propagation.stale_stages` | "Stage `<stage>` is already stale (from a previous jump-back). Run `/propagate` to process it, or use a different target." |

### Step 3 — Check for in-progress stages

Scan all stages between `<stage>` (exclusive) and `current_stage` (inclusive). If any has `status: in-progress` (agent mid-run) and `--force` was NOT given:

> ⚠️ Stage `<stage-id>` is currently in progress (agent running).
> Jumping back now may leave artifacts in an inconsistent state.
> Wait for the agent to complete, then run `/jump-back` again.
> Or, to proceed anyway: `/jump-back <stage> --force --reason "<reason>"`.

If `--force` is given, proceed and note the override in the decision log.

### Step 4 — Confirm with user

> You are about to jump back to **Stage `<target>` — `<label>`**.
>
> The following stages will be marked **stale** (files preserved, flagged for re-run):
> - `<stage-N>` — `<label>`
> - `<stage-N+1>` — `<label>`
> - ...
>
> Run `/propagate` after updating `<target>` artifacts to re-run these stages.
>
> Type `yes` to confirm, or anything else to cancel.

### Step 5 — Execute

On `yes`:

1. Save the current value of `current_stage` as `previous_stage`.
2. Set `current_stage` to `<target>` in `state.yaml`.
3. For each stage ID after `<target>` up to and including `previous_stage`:
   - Set `stages[id].status` to `"stale"`.
   - Append `id` to `propagation.stale_stages` (if not already present).
4. Set `propagation.last_jump_back`:
   ```yaml
   at: "<ISO 8601 timestamp>"
   from_stage: "<previous_stage>"
   to_stage: "<target>"
   reason: "<--reason value, or 'No reason provided'>"
   ```
5. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: jumped_back
     stage: "<target>"
     from_stage: "<previous_stage>"
     to_stage: "<target>"
     note: "Jump-back to <target>. Stale stages: [<list>]. Reason: <reason>"
   ```
6. Append to `decisions.log.md` (see Decision Log section below).

On cancel (anything other than `yes`):
> Jump-back cancelled. No changes were made.

### Step 6 — Confirm to user

> ✅ **Jumped back to Stage `<target>` — `<label>`.**
>
> Stale stages (files preserved, pending re-run):
> - `<stage>` — `<label>`
>
> **Next steps**:
> 1. Update the artifacts in `projects/<name>/<target>/` as needed.
> 2. Run `/propagate` to re-run all stale stages in order.
>
> Run `/snapshots` to view snapshots. Run `/status` to see current state.

---

## Decision Log Entry

Append to `decisions.log.md` in Step 5:

```markdown
## <YYYY-MM-DD HH:MM> — Jump-back to <target>

Stage: <target>
Action: jumped_back

User jumped back from Stage <previous_stage> to Stage <target>. Reason: <reason>.
The following stages are now stale and will be re-run by /propagate: <list>.
No artifact files were deleted or modified.
<If --force was used: "Note: --force flag used; stage <id> was in-progress at time of jump-back.">

Key decisions:
  - Jumped back to <target>: <reason>

Artifacts affected:
  - state.yaml: current_stage = <target>; stale_stages = [<list>]
```

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Use `/switch <name>` or `/start-project`." |
| Invalid stage ID | "Stage `<id>` not recognized. Valid stages: `<list>`." |
| Stage is after current | "Use `/advance` to move forward." |
| Stage equals current | "Already at `<stage>`. Nothing to do." |
| Stage already stale | "Stage `<stage>` is already stale. Run `/propagate` or choose a different target." |
| Agent in progress (no --force) | Show warning with `--force` hint; block. |
| Agent in progress (with --force) | Proceed; log warning in decisions.log.md. |
| User cancels | "Jump-back cancelled. No changes were made." |

---

## State Changes

| File | What changes |
|---|---|
| `state.yaml` | `current_stage` updated; downstream stage statuses set to `stale`; `propagation.stale_stages` populated; `propagation.last_jump_back` set; history appended |
| `decisions.log.md` | Jump-back entry appended |

No artifact files in `projects/<name>/` are modified or deleted by `/jump-back`.
