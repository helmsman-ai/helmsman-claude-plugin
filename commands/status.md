---
name: status
description: >
  Show the current state of one or all Helmsman projects: active stage, gate
  status, pending approvals, recent history, and gate override summary.
  Read-only — changes nothing.
arguments:
  - name: project-name
    description: Optional. Show detailed status for a specific project. If omitted, shows compact dashboard of all projects.
    required: false
  - name: --gates
    description: Show full gate results for the current stage (only with a project name).
    required: false
  - name: --history
    description: Show the last N history entries (default 5). Usage -- /status <project> --history 10
    required: false
  - name: --overrides
    description: Show active gate overrides and audit log for this project.
    required: false
---

# `/status` Command

## Purpose

Give the developer an instant, readable snapshot of where a project stands — without opening any files.

## Syntax

```
/status
/status <project-name>
/status <project-name> --gates
/status <project-name> --history [N]
/status <project-name> --overrides
```

---

## Step-by-Step Behavior

### Step 1 — Determine scope

- If `<project-name>` given: read `projects/<project-name>/state.yaml`. If not found: "No project named `<project-name>`. Run `/start-project` to create one."
- If no argument: list all dirs under `projects/` containing a `state.yaml`. If none: show the empty-workspace message. Otherwise render the dashboard (Step 4).

---

### Step 2 — Single project: full view

Read `state.yaml` and produce a structured report. Use the exact format below.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 payments-v2                          feature mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Created   2026-05-15   Repos   payments-svc, web-app
 Jira      PAY-1234     Branch  helmsman/payments-v2

 PIPELINE
 ────────────────────────────────────────────────
  ✅  01  PRD Intake           complete   2026-05-15
  ✅  02  PRD Review           complete   2026-05-15
  ✅  03  Discovery            complete   2026-05-15
 ▶️  04  Tech Design          in-review  ← YOU ARE HERE
  ⏳  05  Task Breakdown       pending
  ⏳  06  Implementation       pending
  ⏳  07  Code Review          pending
  ⏳  08  Pre-Launch           pending
  ⏳  09  Launch               pending

 CURRENT STAGE · 04 Tech Design
 ────────────────────────────────────────────────
  Agent      architect
  Skill      tech-design
  Started    2026-05-15 15:00 UTC
  Approved   —

 GATE STATUS
 ────────────────────────────────────────────────
  ✅  has_2_alternatives     hard    pass
  ✅  has_risks_section      hard    pass
  ⚠️   has_adrs              soft    warn   (no ADR file written yet)

 PENDING ACTION
 ────────────────────────────────────────────────
  Review artifacts in 04-tech-design/, then:
    /approve              accept and mark stage complete
    /comment "<text>"     request changes from the architect
    /advance              run gates and start Task Breakdown

 RECENT DECISIONS  (last 3 — run /status payments-v2 --history for more)
 ────────────────────────────────────────────────
  2026-05-15 15:00   Stage 03 approved — added rate-limiting dependency
  2026-05-15 15:00   Advanced to Tech Design
  2026-05-15 16:30   Architect produced design.md, alternatives.md, risks.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Field sources:**

| Display field | Source in state.yaml |
|---|---|
| Mode | `mode` + `fast_track` |
| Created | `created_at` (date only) |
| Repos | `linked_repos[]` |
| Jira | `linked_jira` (omit row if null) |
| Branch | `repo_branches` values (if all same, show one; if different, show `<repo>:<branch>` per repo) |
| Pipeline stages | `stage_order` + `stages[id].label` + `stages[id].status` + `stages[id].approved_at` |
| Current stage detail | `stages[current_stage].*` |
| Gate status | `stages[current_stage].gate_results` — if not yet run, show each gate from `stages[current_stage].gates` with status `—` (not checked) |
| Recent decisions | Last 3 entries from `history[]` |

**Status icons:**

| Icon | Status |
|---|---|
| ✅ | `complete` |
| ▶️ | `in-review` or `in-progress` (current stage) |
| ⏳ | `pending` |
| ⏸ | `skipped` |
| 🔁 | `stale` (downstream of a jump-back) |

**Gate icons:**

| Icon | Meaning |
|---|---|
| ✅ | pass |
| 🚫 | fail (hard) |
| ⚠️ | warn (soft fail) or not yet checked |
| ⏭ | skipped (via `gate_config`) |
| 🔓 | bypassed (one-time, from `gates_overridden`) |

For hotfix mode, append ` ⚡ fast-track` after the mode name in the header.

---

### Step 3 — Flag section variants

**`--gates` flag** — replace the compact Gate Status block with a full gate detail table:

```
 GATE STATUS · 04 Tech Design  (strictness: balanced)
 ────────────────────────────────────────────────
  ✅  has_2_alternatives     hard     pass
       checked: alternatives.md contains 2 distinct options
  ✅  has_risks_section      hard     pass
       checked: risks.md exists and has ## Risk entries
  ⚠️   has_adrs              soft     warn
       checked: adrs/ directory is empty — no ADR written yet
       suggestion: record at least one architecture decision
  ──
  Gate config:  strictness = balanced (mode default)
  Overrides:    none active for this stage
```

**`--history N` flag** — show last N entries (default 5 if no number given) from `history[]` at full width, with action type coloured:

```
 HISTORY  (last 5)
 ────────────────────────────────────────────────
  2026-05-15 16:30   [agent]    Architect produced artifacts for 04-tech-design
  2026-05-15 15:00   [advanced] 03 → 04 · All gates passed
  2026-05-15 15:00   [approved] Stage 03 approved
  2026-05-15 11:30   [advanced] 02 → 03 · All gates passed
  2026-05-15 11:30   [approved] Stage 02 approved
```

**`--overrides` flag** — append a Gate Overrides block:

```
 GATE OVERRIDES
 ────────────────────────────────────────────────
  Permanent (gate_config):
    04-tech-design / has_adrs        soft → hard    "Team policy"   2026-05-24

  One-time bypasses (audit log):
    none

  Strictness:  balanced  (mode default)
```

If no overrides: "No gate overrides for this project."

---

### Step 4 — Propagation warning (inline)

If `propagation.stale_stages` is non-empty, insert a banner between the Pipeline and Current Stage sections:

```
 ⚠️  PROPAGATION REQUIRED
 ────────────────────────────────────────────────
  Stages 05, 06 are stale (upstream context changed).
  Run /propagate to re-run them, or /propagate --abort to restore snapshots.
```

If `propagation.in_progress: true`:

```
 🔄  PROPAGATION IN PROGRESS
 ────────────────────────────────────────────────
  Propagation was interrupted mid-run.
  Run /propagate to resume, or /propagate --abort to cancel.
```

---

### Step 5 — Implementation loop detail

When `stages[current_stage].agent == "implementer"` or the current stage is immediately after an implementer stage, add a task progress block below the Gate Status:

```
 IMPLEMENTATION PROGRESS  · 3 / 6 tasks
 ────────────────────────────────────────────────
  ✅  001  add-idempotency-key-migration     complete    a1b2c3d
  ✅  002  update-transaction-repository     complete    e4f5g6h
  ✅  003  add-idempotency-check             complete    i7j8k9l
  ▶️  004  update-charge-endpoint           in-review
  ⏳  005  add-wallet-payment               pending
  ⏳  006  integration-tests                pending

 Active: 004 — update-charge-endpoint
 Reviewer running for task 004.
```

Source: `06-implementation/progress.md` (or whichever implementation stage directory).

---

### Step 6 — All projects dashboard (no argument)

When `/status` is run with no argument, render a rich dashboard:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 HELMSMAN · 4 projects  (2 active · 1 blocked · 1 complete)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Project               Mode        Stage                Status
 ─────────────────────────────────────────────────────────────
 payments-v2           feature     04 Tech Design       ▶️  in-review
 login-crash-ios       bugfix      02 Reproduce         ▶️  in-progress
 cache-refactor        refactor    03 Target Design     🚫 gate failed
 redis-hotfix          hotfix ⚡   02 Fix               ✅ complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ATTENTION NEEDED
 ─────────────────────────────────────────────────────────────
  🚫 cache-refactor   Gate failed: has_current_state_doc (hard)
                      Run /status cache-refactor --gates for details

 Run /status <project> for full details · /projects for quick links
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Summary line counts:**
- `active` = stages with status `in-review` or `in-progress`
- `blocked` = projects where any hard gate has `fail` in `gate_results`
- `complete` = all stages `complete`

**Attention Needed section:** list any project with a hard gate failure or a stale propagation. Empty if all projects are clean.

Stage labels and counts are read dynamically from each project's `stage_order` and `stages[id].label`.

---

## Error Cases

| Situation | Response |
|---|---|
| No `projects/` directory | "No workspace found. Run `/helmsman-init` to set up, then `/start-project`." |
| `projects/` exists but empty | "No projects yet. Run `/start-project <name>` to begin." |
| `state.yaml` malformed or missing required fields | "Cannot read state for `<project>`. File may be corrupted — check `projects/<project>/state.yaml`." |
| `--history` value is not a number | Use default of 5; do not error |
| `--gates` used without a project name | "Specify a project: `/status <project-name> --gates`" |

## State Changes

None. `/status` is read-only.
