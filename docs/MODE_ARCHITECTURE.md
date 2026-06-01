# Helmsman Mode Architecture

> **Status**: Design approved — v1.M1 Phase 1
> **Scope**: How all 7 pipeline modes plug into Helmsman's state machine
> **Out of scope**: Jump-back/propagation (M2), multi-repo (M3), hooks (M4)

---

## 1. Overview

MVP Helmsman supported only `feature` mode with a hardcoded 9-stage pipeline. v1.M1 adds 6 additional modes: `bugfix`, `refactor`, `spike`, `experiment`, `hotfix`, `chore`.

Each mode owns its complete stage list independently — no shared stage IDs across modes. The Orchestrator becomes mode-aware by reading a structured `modes/<mode>.yaml` at project creation time and baking the result into `state.yaml`. From that point, the Orchestrator reads only `state.yaml` — it never re-reads the mode YAML mid-flight.

---

## 2. Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Stage ID ownership | Fully independent per mode | Honest about what each mode does; avoids padding with empty stages |
| Mode definition format | Structured `modes/<mode>.yaml` + `docs/modes/<mode>.md` | Machine-readable config + human-readable documentation, separated |
| `state.yaml` stage structure | Dynamic dict keyed by mode-defined IDs + `stage_order` array | Consistent with existing YAML idioms; Orchestrator stays self-contained |
| Agent/skill storage | Baked into `state.yaml` at project creation | State file fully self-contained; no mid-flight mode YAML lookups |
| Hotfix fast-track | `fast_track: true` flag with auto-advance + gate downgrade | Makes emergency nature explicit and enforceable, not just conventional |

---

## 3. `modes/<mode>.yaml` Schema

Lives at `helmsman/modes/<mode>.yaml`. One file per mode. Read by the Orchestrator at `/start-project` time only.

```yaml
mode: bugfix                          # must match filename
label: "Bug Fix"                      # display name
description: "..."                    # one sentence
fast_track: false                     # true only for hotfix

defaults:
  gate_strictness: balanced           # strict | balanced | lenient
  require_tests: true
  branch_pattern: "helmsman/{project}"

stages:
  - id: "01-bug-intake"               # unique within this mode; lowercase-hyphenated
    label: "Bug Intake"               # display name shown in /status
    agent: null                       # null = Orchestrator handles directly
    skill: null                       # null = no skill loaded for this stage
    gates:
      - id: has_reproduction_steps
        severity: hard                # hard | soft
      - id: has_expected_vs_actual
        severity: hard
      - id: has_affected_version
        severity: soft

  - id: "02-reproduce"
    label: "Reproduce & Diagnose"
    agent: researcher
    skill: "bugfix/reproduce"         # path under skills/; new skills added in Phase 3
    gates:
      - id: has_root_cause
        severity: hard
      - id: has_impacted_code_paths
        severity: soft
```

### Field Reference

| Field | Type | Required | Description |
|---|---|---|---|
| `mode` | string | yes | Must match filename. Lowercase, no spaces. |
| `label` | string | yes | Human-readable name shown in `/status` output. |
| `description` | string | yes | One-sentence description for `CHOOSING_A_MODE.md`. |
| `fast_track` | boolean | yes | `true` only for `hotfix`. Changes gate and advance behavior. |
| `defaults.gate_strictness` | string | yes | Default gate strictness: `strict`, `balanced`, or `lenient`. |
| `defaults.require_tests` | boolean | yes | Block implementation advance if no tests exist. |
| `defaults.branch_pattern` | string | yes | Git branch naming template. `{project}` replaced with project name. |
| `stages[].id` | string | yes | Unique stage identifier within this mode. Used as key in `state.yaml`. |
| `stages[].label` | string | yes | Display name for `/status` output. |
| `stages[].agent` | string or null | yes | Sub-agent to invoke. `null` = Orchestrator handles directly. |
| `stages[].skill` | string or null | yes | Skill path under `skills/`. `null` = no skill for this stage. |
| `stages[].gates[]` | array | yes | Gate list for this stage. May be empty (`[]`). |
| `stages[].gates[].id` | string | yes | Gate identifier. Used as key in `state.yaml.stages.<id>.gate_results`. |
| `stages[].gates[].severity` | string | yes | `hard` blocks `/advance`. `soft` warns but does not block. |

---

## 4. `state.yaml` Changes

### New and changed fields

**`mode`** was previously written but ignored. Now it drives Orchestrator routing.

**`fast_track`** is new. Copied from `modes/<mode>.yaml` at project creation.

**`stage_order`** is new. An ordered array of stage IDs, copied from the mode's `stages[].id` list at project creation. The Orchestrator uses this to determine next/previous stage without re-reading the mode YAML.

**`stages`** becomes a dynamic dict. Keys are mode-defined stage IDs. Each entry gains `agent` and `skill` fields (copied from the mode YAML at project creation).

### Full schema for a stage entry

```yaml
stages:
  "02-reproduce":
    # --- copied from modes/<mode>.yaml at project creation ---
    label: "Reproduce & Diagnose"
    agent: researcher
    skill: "bugfix/reproduce"
    gates:
      - id: has_root_cause
        severity: hard
      - id: has_impacted_code_paths
        severity: soft

    # --- managed by Orchestrator at runtime ---
    status: in-review               # pending | in-progress | in-review | complete | skipped
    started_at: "2026-05-23T10:05:00Z"
    approved_at: null
    approved_by: null
    gate_results:
      has_root_cause: pass
      has_impacted_code_paths: warn
```

### Full `state.yaml` example for a `bugfix` project

```yaml
project: login-crash-ios
mode: bugfix
fast_track: false
created_at: "2026-05-23T10:00:00Z"
linked_repos:
  - mobile-app
linked_jira: MOB-891

current_stage: "02-reproduce"

stage_order:
  - "01-bug-intake"
  - "02-reproduce"
  - "03-fix-plan"
  - "04-implementation"
  - "05-review"
  - "06-launch"

stages:
  "01-bug-intake":
    label: "Bug Intake"
    agent: null
    skill: null
    gates:
      - id: has_reproduction_steps
        severity: hard
      - id: has_expected_vs_actual
        severity: hard
      - id: has_affected_version
        severity: soft
    status: complete
    started_at: "2026-05-23T10:00:00Z"
    approved_at: "2026-05-23T10:05:00Z"
    approved_by: user
    gate_results:
      has_reproduction_steps: pass
      has_expected_vs_actual: pass
      has_affected_version: warn

  "02-reproduce":
    label: "Reproduce & Diagnose"
    agent: researcher
    skill: "bugfix/reproduce"
    gates:
      - id: has_root_cause
        severity: hard
      - id: has_impacted_code_paths
        severity: soft
    status: in-review
    started_at: "2026-05-23T10:05:00Z"
    approved_at: null
    approved_by: null
    gate_results: null

  "03-fix-plan":
    label: "Fix Plan"
    agent: architect
    skill: "bugfix/fix-plan"
    gates:
      - id: has_fix_approach
        severity: hard
      - id: has_regression_risk
        severity: soft
    status: pending
    started_at: null
    approved_at: null
    approved_by: null
    gate_results: null

  # ... remaining stages follow same pattern

skipped_stages: []
gates_overridden: []

history:
  - at: "2026-05-23T10:00:00Z"
    action: approved
    stage: "01-bug-intake"
    note: "Bug intake complete"
  - at: "2026-05-23T10:05:00Z"
    action: advanced
    from_stage: "01-bug-intake"
    to_stage: "02-reproduce"
    note: "Researcher agent started"
```

### Backward compatibility

Existing `feature` projects keep their existing `state.yaml` files unchanged. The feature mode gets a `modes/feature.yaml` that maps to the existing 9-stage pipeline. The Orchestrator treats a missing `stage_order` field as feature mode (for zero-migration compatibility).

---

## 5. Stage Lists for All 7 Modes

### `feature` (existing — documented for completeness)
```
01-prd → 02-prd-clean → 03-discovery → 04-tech-design → 05-tasks →
06-implementation → 07-review → 08-pre-launch → 09-launch
```
9 stages. Full pipeline. No changes to existing behavior.

---

### `bugfix`
```
01-bug-intake → 02-reproduce → 03-fix-plan → 04-implementation → 05-review → 06-launch
```
6 stages. Researcher confirms root cause before architect proposes a fix. No tech design — fix-plan is a lightweight targeted doc, not a full design with alternatives.

| Stage | Agent | Key Artifacts |
|---|---|---|
| 01-bug-intake | Orchestrator | `bug-report.md`, `reproduction-steps.md` |
| 02-reproduce | Researcher | `root-cause.md`, `impacted-paths.md` |
| 03-fix-plan | Architect | `fix-plan.md`, `regression-risks.md` |
| 04-implementation | Implementer | Code commits, `progress.md` |
| 05-review | Reviewer | `self-review-<task>.md` |
| 06-launch | Orchestrator | `dossier.md` |

---

### `refactor`
```
01-intake → 02-current-state → 03-target-design → 04-migration-plan →
05-implementation → 06-review → 07-launch
```
7 stages. Researcher maps the messy area (`02-current-state`) before the Architect designs the target state (`03-target-design`). Migration plan breaks the refactor into safe atomic steps — critical because refactors fail by being too large to review safely.

| Stage | Agent | Key Artifacts |
|---|---|---|
| 01-intake | Orchestrator | `motivation.md`, `scope.md` |
| 02-current-state | Researcher | `current-state.md`, `pain-points.md` |
| 03-target-design | Architect | `target-design.md`, `adrs/` |
| 04-migration-plan | Architect | `INDEX.md`, `NNN-task.md` files |
| 05-implementation | Implementer | Code commits, `progress.md` |
| 06-review | Reviewer | `self-review-<task>.md` |
| 07-launch | Orchestrator | `dossier.md` |

---

### `spike`
```
01-question → 02-investigation → 03-findings → 04-recommendation → 05-close
```
5 stages. Produces no production code. Hard gate on `04-recommendation` requires a clear accept/reject/defer decision — spikes that end with "it depends" are not done. `05-close` produces only a dossier.

| Stage | Agent | Key Artifacts |
|---|---|---|
| 01-question | Orchestrator | `question.md`, `success-criteria.md`, `time-box.md` |
| 02-investigation | Researcher | `codebase-findings.md`, `external-research.md` |
| 03-findings | Researcher | `findings.md`, `options.md` |
| 04-recommendation | Architect | `recommendation.md` (must contain accept/reject/defer) |
| 05-close | Orchestrator | `dossier.md` |

---

### `experiment`
```
01-hypothesis → 02-design → 03-implementation → 04-results → 05-decision → 06-close
```
6 stages. Differs from `spike` in that it actually builds code. `05-decision` is a formal accept/reject/pivot stage with its own hard gate (`has_ship_decision`). The dossier records the outcome either way — experiments that fail are as valuable as those that succeed.

| Stage | Agent | Key Artifacts |
|---|---|---|
| 01-hypothesis | Orchestrator | `hypothesis.md`, `success-metrics.md`, `time-box.md` |
| 02-design | Architect | `experiment-design.md` |
| 03-implementation | Implementer | Code commits, `progress.md` |
| 04-results | Researcher | `results.md`, `metrics.md` |
| 05-decision | Orchestrator | `decision.md` (ship / discard / pivot) |
| 06-close | Orchestrator | `dossier.md` |

---

### `hotfix` — `fast_track: true`
```
01-intake → 02-fix → 03-review → 04-deploy
```
4 stages. No reproduce, no fix-plan, no pre-launch. `fast_track: true` means the pipeline auto-advances after each agent completes — no waiting for `/approve`. Hard gates downgrade to warnings. Developer retains full override control via explicit `/approve` or `/comment`.

| Stage | Agent | Key Artifacts |
|---|---|---|
| 01-intake | Orchestrator | `incident.md` |
| 02-fix | Implementer | Code commit |
| 03-review | Reviewer | `self-review.md` |
| 04-deploy | Orchestrator | `dossier.md` |

**`fast_track` gate behavior:**

| Normal | `fast_track: true` |
|---|---|
| Hard gate fails → block | Hard gate fails → warn, continue |
| Soft gate fails → warn | Soft gate fails → silent |
| Waits for `/approve` | Auto-advances after agent reports done |
| Gate results in `state.yaml` | Gate results still written (audit trail preserved) |

---

### `chore`
```
01-intake → 02-implementation → 03-review → 04-close
```
4 stages. No research, no design. Gate strictness defaults to `lenient`. `03-review` uses the standard `reviewer` agent with a reduced checklist — security and architecture sections are skipped.

| Stage | Agent | Key Artifacts |
|---|---|---|
| 01-intake | Orchestrator | `chore-description.md` |
| 02-implementation | Implementer | Code commits, `progress.md` |
| 03-review | Reviewer | `self-review.md` (reduced checklist) |
| 04-close | Orchestrator | `dossier.md` |

---

## 6. Orchestrator Reading Pattern

### At `/start-project <name> --mode <mode>`

1. Read `modes/<mode>.yaml`
2. Validate mode exists — if not, reject with list of valid modes
3. Initialize `state.yaml`:
   - Set `mode`, `fast_track` from mode YAML
   - Build `stage_order` from `stages[].id` list
   - Initialize `stages` dict — copy `label`, `agent`, `skill`, `gates` from mode YAML; set all statuses to `pending`
   - Set first stage to `in-progress`
4. Never read mode YAML again for this project

### On every subsequent message

```
read state.yaml
  → current_stage
  → stages[current_stage].agent     (who does the work)
  → stages[current_stage].skill     (what instructions to load)
  → stages[current_stage].gates     (what to check before advancing)
  → stage_order                     (what comes next)
  → fast_track                      (whether to auto-advance)
```

### Determining next stage

```python
current_index = stage_order.index(current_stage)
next_stage = stage_order[current_index + 1]  # None if at last stage
```

### `fast_track` advance logic

```
agent reports done
  → run gate check
    → if hard gate fails AND fast_track=true: log warning, continue
    → if hard gate fails AND fast_track=false: block, tell user
  → update state.yaml: current stage = complete
  → if fast_track=true: auto-advance to next stage, invoke next agent
  → if fast_track=false: wait for user /approve, then /advance
```

---

## 7. File Layout After v1.M1

```
helmsman/
├── modes/
│   ├── feature.yaml
│   ├── bugfix.yaml
│   ├── refactor.yaml
│   ├── spike.yaml
│   ├── experiment.yaml
│   ├── hotfix.yaml
│   └── chore.yaml
├── docs/
│   ├── SCHEMAS.md              (updated: new state.yaml fields)
│   ├── WALKTHROUGH.md          (unchanged)
│   ├── MODE_ARCHITECTURE.md    (this document)
│   ├── CHOOSING_A_MODE.md      (Phase 5)
│   └── modes/
│       ├── bugfix.md
│       ├── refactor.md
│       ├── spike.md
│       ├── experiment.md
│       ├── hotfix.md
│       └── chore.md
├── skills/
│   ├── prd-review/             (unchanged)
│   ├── tech-design/            (unchanged)
│   ├── task-breakdown/         (unchanged)
│   ├── implementation/         (unchanged)
│   ├── code-review/            (unchanged)
│   ├── bugfix/                 (Phase 3: reproduce, fix-plan)
│   ├── refactor/               (Phase 3: current-state, target-design, migration-plan)
│   ├── spike/                  (Phase 3: investigation, findings, recommendation)
│   ├── experiment/             (Phase 3: design, results, decision)
│   └── hotfix/                 (Phase 3: fix)
├── templates/
│   ├── ...existing...
│   ├── bug-report.template.md
│   ├── root-cause.template.md
│   ├── fix-plan.template.md
│   ├── motivation.template.md
│   ├── current-state.template.md
│   ├── target-design.template.md
│   ├── question.template.md
│   ├── recommendation.template.md
│   ├── hypothesis.template.md
│   ├── experiment-design.template.md
│   ├── results.template.md
│   ├── decision.template.md
│   ├── incident.template.md
│   └── chore-description.template.md
└── agents/
    └── orchestrator.md         (Phase 4: mode-aware routing table)
```

---

## 8. What Is NOT Changing (v1.M1)

- All existing agents (`prd-reviewer`, `researcher`, `architect`, `implementer`, `reviewer`) — unchanged
- All existing skills — unchanged; new skills are additive
- All existing commands except `start-project`, `advance`, `status`, `orchestrator.md` — unchanged
- Existing `feature` mode projects — zero migration required
- `manifest.yaml` schema — unchanged
- `plugin.json` — updated only to register new `modes/` directory
