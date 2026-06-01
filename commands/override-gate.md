---
name: override-gate
description: >
  Change a gate's severity for this project, or bypass a failing gate once.
  Writes to state.yaml and the gate audit log. Requires a reason.
arguments:
  - name: gate-id
    description: Gate identifier (e.g., has_adrs, tests_pass). Required.
    required: true
  - name: --stage
    description: Stage ID the gate belongs to (e.g., 04-tech-design). Required unless --list is used.
    required: false
  - name: --severity
    description: "New permanent severity: hard, soft, or skip. Mutually exclusive with --bypass."
    required: false
  - name: --bypass
    description: One-time bypass of a failing hard gate. Lets /advance proceed past this gate once. Mutually exclusive with --severity.
    required: false
  - name: --reason
    description: Required explanation. Recorded in state.yaml and decisions.log.md.
    required: false
  - name: --list
    description: List all active gate overrides for this project. Read-only.
    required: false
  - name: --remove
    description: Remove a permanent gate_config override (does not erase the audit log entry).
    required: false
---

# `/override-gate` Command

## Purpose

Give developers fine-grained control over quality gates without hacking YAML:

- **Permanent override** (`--severity`): change a gate's severity for the lifetime of this project. Useful when a team policy differs from the mode default, or a gate is inapplicable to this specific project.
- **One-time bypass** (`--bypass`): let `/advance` proceed past a single failing hard gate this one time. The gate remains hard for all future advances.
- **Audit trail**: every override is recorded in `state.yaml.gates_overridden` and `decisions.log.md`. Nothing is silent.

## Syntax

```
/override-gate <gate-id> --stage <stage-id> --severity <hard|soft|skip> --reason "<reason>"
/override-gate <gate-id> --stage <stage-id> --bypass --reason "<reason>"
/override-gate <gate-id> --stage <stage-id> --remove --reason "<reason>"
/override-gate --list
```

**Examples:**

```
# Make has_adrs a hard gate (escalate from soft)
/override-gate has_adrs --stage 04-tech-design --severity hard --reason "Team policy: ADRs required"

# Skip has_user_stories for this internal tool project
/override-gate has_user_stories --stage 02-prd-clean --severity skip --reason "Internal tool, no users"

# One-time bypass of has_2_alternatives (gate stays hard for next advance)
/override-gate has_2_alternatives --stage 04-tech-design --bypass --reason "Trivial color change, only one option makes sense"

# Downgrade tests_pass to soft for a spike-turned-feature (edge case)
/override-gate tests_pass --stage 06-implementation --severity soft --reason "Prototype phase, tests will be written in cleanup PR"

# Remove a previously set permanent override
/override-gate has_adrs --stage 04-tech-design --remove --reason "Reverting to mode default"

# List all active overrides
/override-gate --list
```

---

## Step-by-Step Behavior

### `--list` mode

Read `state.yaml.gate_config.gate_overrides` and `state.yaml.gates_overridden`. Print two sections:

```
Active gate overrides for project: payments-v2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Permanent overrides (gate_config):
  04-tech-design / has_adrs       soft → hard   "Team policy: ADRs required"   set 2026-05-24
  02-prd-clean   / has_user_stories hard → skip  "Internal tool, no users"      set 2026-05-24

One-time bypasses (audit log):
  04-tech-design / has_2_alternatives  bypassed 2026-05-24  "Trivial color change"

Project strictness: balanced (mode default)
```

If no overrides exist: "No gate overrides set for this project. All gates use mode defaults."

---

### `--severity` mode (permanent override)

**Step 1 — Validate inputs**

- `<gate-id>` must be a known gate in `state.yaml.stages[--stage].gates`.
- `--stage` must be a stage ID in `state.yaml.stage_order`.
- `--severity` must be one of: `hard`, `soft`, `skip`.
- `--reason` is required. If absent: "A reason is required. Re-run with `--reason \"<your reason>\"`."

If the gate is in a stage that is already `complete`, warn:
> ⚠️ Stage `04-tech-design` is already complete. This override will apply to future advances of this project but will not retroactively change any past gate results.

**Step 2 — Check for existing override**

If `gate_config.gate_overrides` already has an entry for this gate + stage combination:
> ⚠️ An override already exists for `has_adrs` in `04-tech-design` (current: soft → hard).
> Replace it? (yes/no)

On "no": abort.
On "yes": remove the existing entry before writing the new one.

**Step 3 — Write to state.yaml**

Append to `gate_config.gate_overrides`:

```yaml
- gate: <gate-id>
  stage: <stage-id>
  severity: <hard|soft|skip>
  reason: "<reason>"
  set_by: user
  set_at: "<ISO 8601 timestamp>"
```

Set or update `gate_config.strictness` only if this is the first override and `gate_config` does not already exist (inherit from `manifest.yaml defaults.reviewer_strictness`; default: `balanced`).

**Step 4 — Write to decisions.log.md**

Append:

```markdown
## <date> — Gate override: <gate-id> in <stage-id>

**Override type:** severity change (`<old>` → `<new>`)
**Reason:** <reason>
**Set by:** user
```

**Step 5 — Confirm to user**

> ✅ Gate `has_adrs` in `04-tech-design` is now **hard** for this project.
>
> This override is permanent for the lifetime of this project. To revert, run:
> `/override-gate has_adrs --stage 04-tech-design --remove --reason "<reason>"`

For `skip` severity:
> ✅ Gate `has_user_stories` in `02-prd-clean` will be **skipped** for this project.
>
> This gate will not appear in gate checks or block `/advance`.

---

### `--bypass` mode (one-time bypass)

Use when you want `/advance` to proceed past a failing gate *this one time*, without permanently changing the gate's severity.

**Step 1 — Validate inputs**

- `<gate-id>`, `--stage`, `--reason` all required (same as `--severity` mode).
- `--bypass` and `--severity` are mutually exclusive; error if both provided.

**Step 2 — Verify gate is actually failing**

Run a lightweight check on the artifact (same logic as `/advance` Step 2). If the gate is currently **passing**, warn:
> ⚠️ Gate `has_adrs` is currently passing. A bypass is unnecessary.
> You can still record it for documentation purposes. Proceed? (yes/no)

**Step 3 — Write to gates_overridden (audit log)**

Append to `state.yaml.gates_overridden`:

```yaml
- at: "<ISO 8601 timestamp>"
  stage: "<stage-id>"
  gate: "<gate-id>"
  original_severity: "<hard|soft>"
  override_type: bypass
  reason: "<reason>"
  by: user
```

**Step 4 — Set a one-time bypass flag for /advance**

Write a transient flag in `state.yaml.stages[stage].gate_bypass_pending`:

```yaml
stages:
  04-tech-design:
    gate_bypass_pending:
      - gate: has_2_alternatives
        reason: "Trivial color change"
        set_at: "<timestamp>"
```

This flag is consumed and cleared by the next `/advance` run for this stage. If `/advance` is not run within the same session, the flag persists in `state.yaml` and will be honoured on the next `/advance`.

**Step 5 — Write to decisions.log.md**

```markdown
## <date> — Gate bypass: <gate-id> in <stage-id>

**Override type:** one-time bypass
**Reason:** <reason>
**Effect:** `/advance` will skip this gate check once, then restore normal enforcement.
```

**Step 6 — Confirm to user**

> ✅ One-time bypass set for gate `has_2_alternatives` in `04-tech-design`.
>
> The next `/advance` will skip this gate and proceed. The gate returns to **hard** enforcement afterward.
>
> Recorded in `gates_overridden` audit log.

---

### `--remove` mode

Remove a permanent override from `gate_config.gate_overrides`. The gate reverts to its mode-declared severity.

**Step 1 — Validate**

- Confirm the override exists. If not: "No permanent override found for `<gate-id>` in `<stage-id>`."
- `--reason` required.

**Step 2 — Update state.yaml**

Remove the matching entry from `gate_config.gate_overrides`.

**Step 3 — Append to decisions.log.md**

```markdown
## <date> — Gate override removed: <gate-id> in <stage-id>

**Reason:** <reason>
**Effect:** Gate reverts to mode default severity.
```

**Step 4 — Confirm**

> ✅ Override removed. Gate `has_adrs` in `04-tech-design` reverts to **soft** (mode default).

---

## Strictness Shorthand

To change project-level strictness (applies to all gates, not a single gate):

```
/override-gate --strictness <strict|balanced|lenient> --reason "<reason>"
```

**`strict`** — all soft gates become hard. Useful for production-critical projects where every check matters.

**`lenient`** — all hard gates become soft. Useful for prototypes, experiments, or when a project operates under a fast_track-like policy without hotfix mode. Not recommended for production features.

**`balanced`** — default. Per-gate severities as declared in the mode YAML.

Per-gate entries in `gate_overrides` take precedence over `strictness`. Example: if `strictness: lenient` but `has_2_alternatives` has `severity: hard` in `gate_overrides`, that gate remains hard.

---

## Interaction with `/advance`

When `/advance` runs its gate check (Step 2), it:

1. Reads `gate_config.strictness` — applies project-level severity mapping.
2. Reads `gate_config.gate_overrides` — applies per-gate severity overrides (takes precedence over strictness).
3. Reads `stages[current_stage].gate_bypass_pending` — for any gate listed here, marks it as bypassed for this run and removes the entry after consuming it.
4. Evaluates each gate with its effective severity.
5. For bypassed gates: logs `"bypassed (one-time, user-confirmed)"` in `gate_results`.

---

## State Changes

| File | What changes |
|---|---|
| `state.yaml` | `gate_config.gate_overrides` appended/modified; `gates_overridden` appended (bypass only); `stages[].gate_bypass_pending` set (bypass only) |
| `decisions.log.md` | Entry appended for every override action |

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Run `/start-project` or switch to an existing project." |
| Unknown gate ID | "Gate `<id>` not found in stage `<stage-id>`. Run `/override-gate --list` to see available gates." |
| Unknown stage ID | "Stage `<stage-id>` not found in this project's pipeline." |
| `--reason` missing | "A reason is required. Re-run with `--reason \"<your reason>\"`." |
| `--severity` and `--bypass` both provided | "Use either `--severity` or `--bypass`, not both." |
| `skip` on a gate in a `complete` stage | Warn but allow — the override is recorded for documentation. |
