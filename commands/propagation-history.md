---
name: propagation-history
description: >
  Display a timeline of all jump-backs, propagations, snapshot operations, and CIR
  events for the current project. Read-only — changes nothing.
arguments: []
---

# `/propagation-history` Command

## Purpose

Show a human-readable timeline of all propagation events for the current project:
jump-backs, propagation runs, per-stage approvals and rejections, snapshot creates
and restores, and CIR events.

Useful for understanding how the project arrived at its current state after one or
more change cycles.

## Syntax

```
/propagation-history
```

No arguments. Read-only — changes nothing.

---

## Step-by-Step Behavior

### Step 1 — Read state

Read `state.yaml.history[]`. Filter to only propagation-related action types:

```
jumped_back
propagation_started
propagation_stage_approved
propagation_stage_rejected
propagation_aborted
snapshot_created
snapshot_restored
cir_produced
cir_acknowledged
```

Sort by `at` timestamp (ascending). If no matching entries: show the empty message from Step 3.

### Step 2 — Format the timeline

For each filtered history entry, format as one timeline block:

```
<timestamp>  <EVENT>      <details>
```

Use these labels for each action type:

| Action | Label | Details |
|---|---|---|
| `jumped_back` | `JUMP-BACK` | `<from_stage> → <to_stage>` — then a new line indented: `Reason: "<note>"` + `Stale: <stale stages from the note>` |
| `propagation_started` | `PROPAGATION` | `Started (<N> stale stages)` |
| `snapshot_created` | `SNAPSHOT` | `<stage> → <snapshot-id from note>` |
| `propagation_stage_approved` | `APPROVED` | `<stage>` |
| `propagation_stage_rejected` | `REJECTED` | `<stage> (snapshot restored)` |
| `snapshot_restored` | `RESTORED` | `<stage>` |
| `propagation_aborted` | `ABORTED` | `Propagation cancelled` |
| `cir_produced` | `CIR` | `<impl-stage> — change-impact-report.md` |
| `cir_acknowledged` | `CIR ACK` | `<impl-stage> (acknowledged by user)` |

Separate distinct propagation runs with a blank line.

### Step 3 — Show summary line

Below the timeline, print a separator and a totals line:

```
══════════════════════════════════════════════════════════════
Total: <N> jump-back(s) | <N> propagation run(s) | <N> stage(s) re-run | <N> rejection(s) | <N> snapshot(s)
```

### Step 4 — Handle empty state

If no propagation events exist in `history[]`:

> No propagation events recorded for project `<name>`.
> Run `/jump-back <stage>` to start a change cycle.

---

## Example Output

```
Propagation History — payments-v2
══════════════════════════════════════════════════════════════

2026-05-23 14:30  JUMP-BACK    04-tech-design → 02-prd-clean
                  Reason: "Changed auth from session tokens to JWT"
                  Stale: 03-discovery, 04-tech-design, 05-tasks, 06-implementation

2026-05-23 15:00  PROPAGATION  Started (4 stale stages)

2026-05-23 15:02  SNAPSHOT     03-discovery → 20260523-150200-03-discovery
2026-05-23 15:05  APPROVED     03-discovery

2026-05-23 15:06  SNAPSHOT     04-tech-design → 20260523-150600-04-tech-design
2026-05-23 15:12  REJECTED     04-tech-design (snapshot restored)

2026-05-23 15:20  SNAPSHOT     04-tech-design → 20260523-152000-04-tech-design
2026-05-23 15:25  APPROVED     04-tech-design

2026-05-23 15:26  SNAPSHOT     05-tasks → 20260523-152600-05-tasks
2026-05-23 15:30  APPROVED     05-tasks

2026-05-23 15:31  CIR          06-implementation — change-impact-report.md
2026-05-23 15:45  CIR ACK      06-implementation (acknowledged by user)

══════════════════════════════════════════════════════════════
Total: 1 jump-back | 1 propagation run | 3 stages re-run | 1 rejection | 4 snapshots
```

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Use `/switch <name>` or `/start-project`." |
| No propagation events in history | Show empty-state message from Step 4. |

---

## State Changes

None. This command is read-only.
