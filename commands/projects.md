---
name: projects
description: >
  Quick-reference dashboard of all Helmsman projects: name, mode, current
  stage, status, and direct-action commands. Lighter than /status — one
  line per project, no artifact details. Read-only.
arguments:
  - name: --all
    description: Include completed and archived projects (default hides them).
    required: false
  - name: --blocked
    description: Show only projects with a hard gate failure or stale propagation.
    required: false
  - name: --mode
    description: Filter by mode (e.g., --mode bugfix). Can be combined with other filters.
    required: false
---

# `/projects` Command

## Purpose

Get a fast, scannable overview of every project in the workspace — without the artifact and gate detail that `/status` provides. Useful when juggling several parallel workstreams.

## Syntax

```
/projects
/projects --all
/projects --blocked
/projects --mode bugfix
```

---

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 HELMSMAN PROJECTS  ·  5 total  (3 active · 1 blocked · 1 complete)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #  Project                Mode        Stage                   Status        Action
 ──────────────────────────────────────────────────────────────────────────
 1  payments-v2            feature     04 · Tech Design        ▶️ in-review   /approve or /comment
 2  login-crash-ios        bugfix      02 · Reproduce          ▶️ in-progress  /status for details
 3  cache-refactor         refactor    03 · Target Design      🚫 gate failed  /status --gates
 4  redis-hotfix           hotfix ⚡   04 · Deploy             ✅ complete     /dossier
 5  q2-auth-spike          spike       03 · Findings           ▶️ in-review   /approve or /comment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Run /status <project> for full detail · /start-project <name> to add one
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Column definitions:**

| Column | Source | Notes |
|---|---|---|
| `#` | Index | Stable within one `/projects` call; not persisted |
| Project | `state.yaml.project` | |
| Mode | `state.yaml.mode` + `fast_track` | Append ` ⚡` for fast_track |
| Stage | `current_stage` index + label | Format: `<NN> · <label>` |
| Status | `stages[current_stage].status` | Icon + text; see icon table |
| Action | Derived | One suggested next command (see Action column rules) |

**Status icons** (same as `/status`):

| Icon | Status |
|---|---|
| ✅ | `complete` |
| ▶️ | `in-review` or `in-progress` |
| ⏳ | `pending` (stage not yet started) |
| ⏸ | `skipped` |
| 🔁 | `stale` |
| 🚫 | hard gate failed in last gate check |

**Action column rules:**

| Condition | Suggested action |
|---|---|
| Status `in-review`, no failing gates | `/approve or /comment` |
| Status `in-progress` | `/status <project> for details` |
| Hard gate failed | `/status <project> --gates` |
| Status `complete` (all stages done) | `/dossier` |
| Propagation stale | `/propagate` |
| Status `pending` (not started) | `/advance` |

---

## Filters

### Default (no flags)

Shows all projects except those where **all** stages are `complete`. Completed projects are shown as a count only:

```
 + 2 completed projects (--all to show)
```

### `--all`

Shows every project including fully completed ones. Completed projects show the date of the final stage approval.

### `--blocked`

Shows only projects that have:
- A hard gate with status `fail` in the current stage's `gate_results`, OR
- `propagation.stale_stages` non-empty, OR
- `propagation.in_progress: true`

If no blocked projects: "No blocked projects. All active projects are making progress."

### `--mode <mode>`

Filters the list to projects with the given `mode` value. Case-insensitive. Multiple `--mode` flags are OR'd together.

Example: `/projects --mode bugfix --mode hotfix` shows only bugfix and hotfix projects.

---

## Summary Line

The header summary line shows:

```
N total  (A active · B blocked · C complete)
```

- `total` = all projects found (respecting filters)
- `active` = `in-progress` or `in-review` at current stage
- `blocked` = hard gate failed or stale propagation
- `complete` = all stages at status `complete`

A project can only be in one category. Priority: blocked > complete > active > pending.

---

## Error Cases

| Situation | Response |
|---|---|
| No `projects/` directory | "No workspace found. Run `/helmsman-init` to set up Helmsman." |
| `projects/` directory is empty | "No projects yet. Start one with `/start-project <name>`." |
| A `state.yaml` is unreadable | Skip that project and append: "(1 project unreadable — check `projects/<name>/state.yaml`)" |
| Unknown `--mode` value | Show all projects with a note: "No projects match mode `<mode>`." |

## State Changes

None. `/projects` is read-only.
