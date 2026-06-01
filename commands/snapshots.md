---
name: snapshots
description: >
  List snapshots for the current project, or restore a specific snapshot.
  Snapshots are taken automatically before each propagation re-run.
arguments:
  - name: snapshot-id
    description: Optional. The snapshot ID to restore. If omitted, lists all snapshots.
    required: false
  - name: --restore
    description: "Flag. Required when restoring a snapshot. Example: /snapshots 20260523-143022-04-tech-design --restore"
    required: false
---

# `/snapshots` Command

## Purpose

List all snapshots taken for the current project, or restore a specific snapshot to recover
from an unwanted propagation outcome.

Snapshots are created automatically by `/propagate` before every agent re-run. They are never
deleted automatically — they accumulate as a complete history of artifact states before each
propagation. The `/snapshots` command is the only way to view or restore them.

## Syntax

```
/snapshots
/snapshots <snapshot-id> --restore
```

**Examples**:
```
/snapshots
/snapshots 20260523-143022-04-tech-design --restore
```

---

## Step-by-Step Behavior

### Listing snapshots (`/snapshots` with no argument)

1. Read `state.yaml.snapshots[]`.
2. If empty:
   > No snapshots exist for project `<name>`. Snapshots are created automatically when `/propagate` is run.
3. If non-empty: display a table:
   ```
   Snapshots for project: payments-v2

   ID                                    Stage            Created              Trigger     Restored
   ────────────────────────────────────  ───────────────  ───────────────────  ──────────  ────────
   20260523-143022-04-tech-design        04-tech-design   2026-05-23 14:30:22  propagate   no
   20260523-151500-03-discovery          03-discovery     2026-05-23 15:15:00  propagate   no

   Restore a snapshot:  /snapshots <id> --restore
   View diff:           projects/<name>/.snapshots/<id>/DIFF.md
   ```
4. Annotate any snapshot where `restored: true` with `[RESTORED]` in the Restored column.

### Restoring a snapshot (`/snapshots <id> --restore`)

**Step 1 — Look up the snapshot**

Read `state.yaml.snapshots[]` to find the entry matching `<id>`.

If not found:
> Snapshot `<id>` not found. Run `/snapshots` to list available snapshots.

**Step 2 — Confirm with user**

> ⚠️ **This will overwrite current files in `projects/<name>/<stage>/` with the snapshotted versions.**
>
> Snapshot: `<id>`
> Taken: `<created_at>` — `<reason>`
> Files that will be overwritten:
> - `<file-1>`
> - `<file-2>`
>
> Type `yes` to confirm, or anything else to cancel.

**Step 3 — Execute restore (on `yes`)**

1. Copy every file from `projects/<name>/.snapshots/<id>/files/` back to its original location in `projects/<name>/<stage>/`, preserving subdirectory structure.
2. Set `snapshots[<id>].restored = true` in `state.yaml`.
3. If `<stage>` is not already in `propagation.stale_stages`, add it.
4. Append to `history`:
   ```yaml
   - at: "<ISO 8601 timestamp>"
     action: snapshot_restored
     stage: "<stage-id>"
     note: "Snapshot <id> restored by user"
   ```
5. Append to `decisions.log.md`:
   ```markdown
   ## <date> — Snapshot restored: <id>

   Stage: <stage-id>
   Action: snapshot_restored

   User manually restored snapshot <id> (taken <created_at>, reason: <reason>).
   Files in <stage-dir>/ reverted to snapshot state. Stage marked stale.

   Artifacts affected:
     - <stage-dir>/<file>: restored from snapshot
   ```
6. Confirm:
   > ✅ Snapshot `<id>` restored. Files in `<stage>/` are now from `<created_at>`.
   > The stage is marked stale. Run `/propagate` to re-run it with the restored artifacts.

**Step 4 — On cancel (anything other than `yes`)**

> Restore cancelled. No files were changed.

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Use `/switch <name>` or `/start-project`." |
| Snapshot ID not found | "Snapshot `<id>` not found. Run `/snapshots` to see valid IDs." |
| `--restore` given without an ID | "Specify a snapshot ID to restore. Example: `/snapshots 20260523-143022-04-tech-design --restore`" |
| User does not confirm | "Restore cancelled. No files were changed." |
| `.snapshots/<id>/files/` directory missing | "Snapshot directory not found on disk: `.snapshots/<id>/files/`. The snapshot log entry exists but the files were not found. Cannot restore." |

---

## State Changes

| File | What changes |
|---|---|
| `state.yaml` | `snapshots[id].restored` set to `true`; stage added to `stale_stages` if needed; `history` appended |
| `decisions.log.md` | Restore entry appended |
| `projects/<name>/<stage>/` | Files overwritten with snapshot versions |

No state changes occur when listing (read-only operation).
