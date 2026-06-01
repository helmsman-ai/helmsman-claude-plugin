# Helmsman Schema Reference

This document is the authoritative reference for `manifest.yaml` and `state.yaml`.
See the annotated examples in `templates/manifest.yaml.example` and `templates/state.yaml.example`.

---

## `manifest.yaml`

Lives at the workspace root. One file per workspace. **Gitignored** — use `manifest.yaml.example` as the committed template.

### Top-level fields

| Field | Type | Required | Description |
|---|---|---|---|
| `version` | integer | yes | Schema version. Currently `1`. |
| `defaults` | object | yes | Global defaults applied to all projects. |
| `repos` | array | yes | List of registered repositories. |

### `defaults` object

| Field | Type | Default | Description |
|---|---|---|---|
| `default_mode` | string | `feature` | Mode used when `/start-project` omits `--mode`. One of: `feature`, `bugfix`, `refactor`, `spike`, `experiment`, `hotfix`, `chore`. MVP supports `feature` only. |
| `reviewer_strictness` | string | `balanced` | Gate strictness level: `strict`, `balanced`, or `lenient`. |
| `auto_push` | boolean | `false` | Whether to auto-push after pre-launch approval. Should remain `false`; use `/push` explicitly. |
| `require_tests` | boolean | `true` | Block implementation advance if no tests exist. |
| `default_branch_pattern` | string | `helmsman/{project}` | Git branch naming template. `{project}` is replaced with the project name. |

### `repos[]` entry

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | yes | Short identifier. Used in `state.yaml.linked_repos`. Lowercase, hyphenated. |
| `path` | string | yes | Absolute path or `~`-relative path to the repo root. |
| `primary_language` | string | yes | Main language: `typescript`, `python`, `go`, `java`, etc. |
| `tech_stack` | array of strings | yes | Frameworks, databases, tools. Used by agents to tailor recommendations. |
| `conventions_file` | string or null | no | Path to conventions doc, relative to repo root. If `null`, Helmsman will prompt on first use. |
| `memory_file` | string | yes | Path to the repo memory file, relative to workspace root. Created automatically on first use. |
| `branch_naming_pattern` | string | no | Inferred git branch naming pattern for this repo (e.g. `feature/{slug}`, `bugfix/{slug}`). Written by Helmsman after the first branch-setup interception. Used to generate branch name suggestions on subsequent projects. If absent, Helmsman infers from `git branch -a` and writes it. |

---

## `state.yaml`

Lives at `projects/<project-name>/state.yaml`. One file per project. **The Orchestrator is the only writer.** Never edit manually.

### Top-level fields

| Field | Type | Description |
|---|---|---|
| `project` | string | Project name. Must match the `projects/` subdirectory name. |
| `mode` | string | Pipeline mode. One of: `feature`, `bugfix`, `refactor`, `spike`, `experiment`, `hotfix`, `chore`. |
| `fast_track` | boolean | Whether this project's pipeline auto-advances (from `modes/<mode>.yaml`). Always `false` except `hotfix`. |
| `stage_order` | array of strings | Ordered list of stage IDs for this project's mode. Set at `/start-project` time. Never changes. |
| `created_at` | ISO 8601 string | When `/start-project` was run. |
| `linked_repos` | array of strings | Repo names from `manifest.yaml`. |
| `repo_branches` | object | Maps each linked repo name to its active branch for this project. Set during `/advance` into the first implementation stage (branch-setup interception — Step 4.5). One entry per linked repo. If not yet set, the field is absent or empty. |
| `linked_jira` | string or null | Optional Jira ticket key (e.g., `PAY-1234`). |
| `current_stage` | string | The currently active stage (e.g., `04-tech-design`). |
| `stages` | object | Per-stage tracking. See below. |
| `skipped_stages` | array of strings | Stages skipped via `/skip-stage`. Always empty in MVP. |
| `gates_overridden` | array of objects | Gate overrides with reasons. Always empty in MVP. |
| `history` | array of objects | Append-only log of every state transition. |

### `stages.<stage-id>` object

Stage IDs: `01-prd`, `02-prd-clean`, `03-discovery`, `04-tech-design`, `05-tasks`, `06-implementation`, `07-review`, `08-pre-launch`, `09-launch`.

| Field | Type | Description |
|---|---|---|
| `label` | string | Display name for this stage (copied from mode YAML at project creation). |
| `agent` | string or null | Sub-agent for this stage. `null` = Orchestrator handles directly. Copied from mode YAML. |
| `skill` | string or null | Skill path under `skills/`. `null` = no skill. Copied from mode YAML. |
| `gates` | array | Gate list for this stage. Each entry: `{id: string, severity: hard\|soft}`. Copied from mode YAML. |
| `status` | string | `pending` → `in-progress` → `in-review` → `complete` (or `skipped`). |
| `started_at` | ISO 8601 or null | When the agent began work on this stage. |
| `approved_at` | ISO 8601 or null | When `/approve` was called. Null until approved. |
| `approved_by` | string or null | Always `user` (human approval required). |
| `gate_results` | object or null | Per-gate pass/fail. Keys are gate names; values are `pass`, `fail`, or `warn`. Present only when gate check has run. |

**Stage `06-implementation` additional fields:**

| Field | Type | Description |
|---|---|---|
| `tasks_total` | integer or null | Total number of tasks. Set when stage begins. |
| `tasks_complete` | integer or null | Number of tasks with approved implementation. |

### `gate_config` object (top-level)

New in v1.M4. Per-project quality gate configuration. Written by `/override-gate`.

| Field | Type | Default | Description |
|---|---|---|---|
| `strictness` | string | `balanced` | Project-level gate strictness. `strict` = all soft gates become hard. `balanced` = gates use declared severities. `lenient` = all hard gates become soft. Inherits from `manifest.yaml defaults.reviewer_strictness` if not present. |
| `gate_overrides` | array | `[]` | Per-gate severity overrides. Each entry permanently changes one gate's behavior for this project. See below. |

### `gate_config.gate_overrides[]` entry

| Field | Type | Description |
|---|---|---|
| `gate` | string | Gate ID (e.g., `has_adrs`). |
| `stage` | string | Stage ID this gate belongs to (e.g., `04-tech-design`). |
| `severity` | string | New severity: `hard`, `soft`, or `skip`. `skip` causes the gate to be omitted entirely from the checklist. |
| `reason` | string | Required. Why this override was applied. |
| `set_by` | string | Always `user`. |
| `set_at` | ISO 8601 string | When the override was set. |

### `gates_overridden[]` entry (audit log)

Append-only log of one-time gate bypasses. Written when `/advance` proceeds past a failing hard gate with explicit user confirmation, or when `/override-gate --bypass` is run.

| Field | Type | Description |
|---|---|---|
| `at` | ISO 8601 string | When the bypass occurred. |
| `stage` | string | Stage ID where the bypass happened. |
| `gate` | string | Gate ID that was bypassed. |
| `original_severity` | string | The gate's effective severity before bypass (`hard` or `soft`). |
| `override_type` | string | `bypass` (one-time skip at advance), `downgrade` (hard→soft via `gate_config`), or `skip` (gate omitted via `gate_config`). |
| `reason` | string | User-provided reason. |
| `by` | string | Always `user`. |

### `history[]` entry

| Field | Type | Description |
|---|---|---|
| `at` | ISO 8601 string | Timestamp of the action. |
| `action` | string | One of: `approved`, `advanced`, `commented`, `jumped_back`, `skipped`, `gate_failed`, `gate_overridden`. |
| `stage` | string | Stage this action applies to. |
| `from_stage` | string or null | For `advanced` actions: the stage transitioned from. |
| `to_stage` | string or null | For `advanced` actions: the stage transitioned to. |
| `note` | string or null | Human-readable context. Always populated by the Orchestrator. |

### `propagation` object (top-level)

New in v1.M2. Tracks jump-back and propagation state.

| Field | Type | Description |
|---|---|---|
| `stale_stages` | array of strings | Stage IDs currently marked stale. Empty = normal state. |
| `in_progress` | boolean | `true` while `/propagate` is actively running. Allows crash recovery. |
| `last_jump_back` | object or null | Metadata about the most recent jump-back. |
| `last_jump_back.at` | ISO 8601 string | When the jump-back was executed. |
| `last_jump_back.from_stage` | string | The stage that was active before the jump-back. |
| `last_jump_back.to_stage` | string | The stage jumped back to (new `current_stage`). |
| `last_jump_back.reason` | string | User-provided reason for the jump-back. |

### `snapshots[]` entry (top-level)

New in v1.M2. Append-only log of every snapshot taken.

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique snapshot ID: `YYYYMMDD-HHMMSS-<stage-id>`. |
| `stage` | string | Stage ID whose files were snapshotted. |
| `created_at` | ISO 8601 string | When the snapshot was created. |
| `trigger` | string | One of: `"propagate"`, `"manual"`. |
| `reason` | string | Human-readable context for why the snapshot was taken. |
| `diff_path` | string or null | Relative path to `DIFF.md` within the snapshot dir (e.g., `.snapshots/<id>/DIFF.md`). Null until diff is produced. |
| `restored` | boolean | `true` if the snapshot was restored (user rejected the propagated version). |

### New `stages[].status` values (v1.M2)

| Value | Meaning |
|---|---|
| `stale` | Stage is downstream of a jump-back. Artifacts exist but may not reflect current upstream. |

### New `history[].action` values (v1.M2)

| Value | When set |
|---|---|
| `propagation_started` | `/propagate` was invoked |
| `propagation_stage_approved` | User approved a propagated stage's diff |
| `propagation_stage_rejected` | User rejected; snapshot restored |
| `propagation_aborted` | User ran `/propagate --abort` |
| `snapshot_created` | A snapshot directory was created |
| `cir_produced` | Change Impact Report was generated for the implementation stage |
| `cir_acknowledged` | User ran `/approve` on the CIR |
| `snapshot_restored` | User manually restored a snapshot via `/snapshots <id> --restore` |

### Task `target_repo` field

| Field | Type | Required | Description |
|---|---|---|---|
| `target_repo` | string | Required for multi-repo projects; optional for single-repo | Repo name matching `state.yaml.linked_repos` and `manifest.yaml.repos[].name`. The Implementer uses this to determine which repo directory to work in and which branch to check out. |

Each task file produced by the Architect at Stage 05 includes a `target_repo` field. For single-repo projects, if the field is absent the Implementer defaults to the sole `linked_repos` entry. For multi-repo projects, the field is required — omitting it is a task spec error. The Implementer reads this field to determine which repo directory to work in and which branch to use.

---

## `modes/<mode>.yaml`

Lives at `helmsman/modes/<mode>.yaml`. One file per mode. Read by the
Orchestrator at `/start-project` time only. See `docs/MODE_ARCHITECTURE.md`
for full field documentation and design rationale.

### Top-level fields

| Field | Type | Required | Description |
|---|---|---|---|
| `mode` | string | yes | Must match filename. |
| `label` | string | yes | Display name for `/status`. |
| `description` | string | yes | One-sentence description. |
| `fast_track` | boolean | yes | `true` only for `hotfix`. |
| `defaults.gate_strictness` | string | yes | `strict`, `balanced`, or `lenient`. |
| `defaults.require_tests` | boolean | yes | Block impl advance if no tests. |
| `defaults.branch_pattern` | string | yes | Branch naming template. |
| `stages[]` | array | yes | Ordered list of stage definitions. |
| `stages[].id` | string | yes | Unique stage ID for this mode. |
| `stages[].label` | string | yes | Display name. |
| `stages[].agent` | string or null | yes | Sub-agent name, or null. |
| `stages[].skill` | string or null | yes | Skill path, or null. |
| `stages[].gates[]` | array | yes | Gate list. May be empty. |
| `stages[].gates[].id` | string | yes | Gate identifier. |
| `stages[].gates[].severity` | string | yes | `hard` or `soft`. |

---

## Stage Status Flow

```
pending
  └─► in-progress   (agent begins work; /advance triggered)
        └─► in-review    (agent has produced artifacts; awaiting user)
              └─► complete    (user ran /approve)
              └─► in-progress (user ran /comment; agent revising)
```

`skipped` can be set from `pending` only (cannot skip a stage already in progress).

---

## Gate IDs

Used in `stages.<stage>.gate_results` and `gates_overridden`.

| Stage | Gate ID | Default Severity |
|---|---|---|
| `02-prd-clean` | `has_goals` | hard |
| `02-prd-clean` | `has_acceptance_criteria` | hard |
| `02-prd-clean` | `has_user_stories` | soft |
| `02-prd-clean` | `has_constraints` | soft |
| `03-discovery` | `has_decision_makers` | soft |
| `04-tech-design` | `has_2_alternatives` | hard |
| `04-tech-design` | `has_risks_section` | hard |
| `04-tech-design` | `has_adrs` | soft |
| `05-tasks` | `each_task_has_acceptance_criteria` | hard |
| `05-tasks` | `dependency_graph_valid` | hard |
| `06-implementation` | `tests_pass` | hard |
| `06-implementation` | `lint_clean` | soft |
| `08-pre-launch` | `pre_mortem_complete` | hard |
| `08-pre-launch` | `rollback_plan_exists` | hard |

**Severity:**
- `hard` — blocks `/advance` until resolved or explicitly overridden with reason
- `soft` — warns but does not block
- `skip` — gate is omitted entirely (set via `gate_config.gate_overrides`)

**Strictness levels** (from `gate_config.strictness`):
- `strict` — all `soft` gates are treated as `hard` for this project
- `balanced` — gates use their declared severities (default)
- `lenient` — all `hard` gates are treated as `soft` for this project

Per-gate overrides in `gate_config.gate_overrides` take precedence over the project-level `strictness` setting.
