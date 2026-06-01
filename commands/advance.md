---
name: advance
description: >
  Run the gate checklist for the current stage, then invoke the next stage's
  specialist agent. Requires the current stage to be in-review or complete.
  Blocks on hard gate failures.
arguments: []
---

# `/advance` Command

## Purpose

Move the active project forward: verify the current stage passes its quality gates, transition state, and invoke the next stage's agent.

`/advance` is the engine of the pipeline. It is distinct from `/approve`:
- `/approve` marks artifacts as accepted by the developer
- `/advance` runs the gates and triggers the next agent

Typical flow: developer reviews artifacts → `/approve` (marks complete) → `/advance` (gates + next stage).
In practice, `/advance` checks whether `/approve` was already run and is idempotent about it.

## Syntax

```
/advance
```

No arguments. Operates on the currently active project (from `state.yaml`).

---

## Step-by-Step Behavior

### Step 1 — Identify current stage

Read `state.yaml`:
- `current_stage` — what stage are we on?
- `stages[current_stage].status` — is it `in-review` or `complete`?

If status is `pending` or `in-progress`: respond with current status and tell user what's needed. Example: "The PRD Reviewer is still working on Stage 2. Wait for it to complete, then run `/approve` before advancing."

If status is `in-review`: the agent has finished but the developer hasn't approved yet. Check if there are unanswered `/comment` threads. If yes: remind user. Proceed only if user explicitly confirms or runs `/approve` first.

If status is `complete`: the developer has already approved. Proceed to gate check.

### Step 2 — Resolve effective gate severities

Before running any gate checks, determine each gate's **effective severity** for this advance. Apply in priority order (highest priority first):

**2a. Consume pending one-time bypasses**

Check `stages[current_stage].gate_bypass_pending` (set by `/override-gate --bypass`). For each gate listed:
- Mark it as `bypassed` for this run.
- Remove the entry from `gate_bypass_pending` in `state.yaml`.
- Record in `gate_results[gate.id]: "bypassed"`.

**2b. Apply per-gate permanent overrides**

Read `gate_config.gate_overrides`. For each gate in `stages[current_stage].gates`:
- If a matching entry exists (`gate` + `stage` match): use `gate_override.severity` as the effective severity.
- If `severity: skip`: remove this gate from the checklist for this run entirely.

**2c. Apply project-level strictness**

Read `gate_config.strictness` (default: `balanced` if absent; inherit from `manifest.yaml defaults.reviewer_strictness` if `gate_config` is not present at all).

- `strict`: any remaining `soft` gates → treat as `hard`.
- `balanced`: no change.
- `lenient`: any remaining `hard` gates → treat as `soft`.

Per-gate overrides from Step 2b take precedence and are not affected by `strictness`.

**2d. fast_track override**

If `state.yaml.fast_track: true`: all effective `hard` gates become `soft` (warn, do not block). This is the highest-precedence rule after one-time bypasses.

---

### Step 3 — Run gate checklist

Load the gate checklist for the current stage:
1. Read `stages[current_stage].skill` from state.yaml
2. If skill is null: no checklist — all gates pass automatically
3. If skill is non-null: load `skills/<skill>/checklists/<last-segment-of-skill>-gate-checklist.md`
   - Example: skill `bugfix/reproduce` → load `skills/bugfix/checklists/reproduce-gate-checklist.md`
   - Example: skill `implementation` → load `skills/implementation/checklists/implementation-gate-checklist.md`
4. If checklist file not found: warn and proceed (do not block)

For each gate in `stages[current_stage].gates` (after Step 2 severity resolution):
- Skip gates with effective severity `skip` or status `bypassed`.
- Run the corresponding check from the checklist.
- Record result in `state.yaml.stages[current_stage].gate_results[gate.id]`.

Work through each gate using its **effective severity** from Step 2:

**Hard gates (effective)**: check the artifact. If the check fails:
- Stop.
- Tell the user exactly which gate failed and what is missing.
- Offer the override path: "To bypass once, run `/override-gate <gate-id> --stage <stage-id> --bypass --reason \"<reason>\"`"
- Do not advance until the gate passes or is bypassed.
- Example: "🚫 Cannot advance: `04-tech-design/alternatives.md` has only 1 alternative. Gate requires ≥ 2. Add another option and run `/advance` again, or bypass with `/override-gate has_2_alternatives --stage 04-tech-design --bypass --reason \"...\"`"

**Soft gates (effective)**: check the artifact. If the check fails:
- Log a warning.
- Continue — soft gates do not block.
- Example: "⚠️ Warning: `04-tech-design/adrs/` is empty. Consider recording a decision as an ADR before continuing."

**Bypassed gates**: log `"bypassed (one-time, user-confirmed)"` in gate results. Do not run the check.

If ALL effective hard gates pass (or are bypassed): proceed to Step 4.

### Step 4 — Update state.yaml: current stage complete

```yaml
stages:
  <current-stage>:
    status: complete
    approved_at: <ISO 8601 timestamp>   # set if not already set by /approve
    approved_by: user
```

Append to `history`:
```yaml
- at: "<timestamp>"
  action: advanced
  from_stage: "<current>"
  to_stage: "<next>"
  note: "All gates passed. Advancing."
```

Append to `decisions.log.md`:
```markdown
## <date> — Stage <current> complete, advancing to <next>

Gates: all hard gates passed.
[List any soft gate warnings]
[List any bypassed gates with reasons]
[List any gates skipped via gate_config]
[Note project strictness if non-default (e.g., "strictness: strict")]
```

### Step 4.5 — Branch setup (pre-implementation interception)

**When to run:** only when both conditions are true:
- The **next stage** (determined by `stage_order[stage_order.index(current_stage) + 1]`) has `agent: implementer`
- `state.yaml.repo_branches` does NOT already have an entry for every linked repo

If `repo_branches` is already fully populated: skip this step entirely.

**4.5a — Determine branch naming convention (per linked repo)**

For each linked repo not yet in `repo_branches`:

1. Read the repo's entry in `manifest.yaml`. Check for `branch_naming_pattern`. If present, use it — skip to 4.5b.
2. Run `git -C <repo_path> branch -a` and sample up to 20 branch names. Identify the dominant prefix pattern (e.g. `feature/`, `bugfix/`, `PROJ-NNN/`).
3. If a clear pattern is found: write it to `manifest.yaml` under the repo's `branch_naming_pattern` field.
4. If inference is ambiguous or the repo has no branches: fall back to the mode's `defaults.branch_pattern` from `manifest.yaml` (e.g. `helmsman/{project}`).

**4.5b — Generate branch name suggestion**

Substitute the project slug into the inferred pattern:
- Pattern `feature/{slug}` + project `payments-v2` → `feature/payments-v2`
- Pattern `helmsman/{project}` + project `payments-v2` → `helmsman/payments-v2`
- Pattern `PROJ-NNN/description` (ticket-prefixed) → fall back to `helmsman/{project}` since the ticket number is unknown

**4.5c — Prompt the developer**

```
Branch Setup — before implementation begins

Target repo: <repo-name>
Current branch: <output of `git -C <repo_path> branch --show-current`>
Suggested branch: <generated-suggestion>  (inferred from repo convention)

Choose:
  [1] Create new branch: <suggested-name>
  [2] Use current branch: <current-branch>
  [3] Enter a custom branch name
```

- **[1]**: record `<suggested-name>` in `state.yaml.repo_branches[<repo>]`. The implementer will create this branch from the default branch in its Step 0.
- **[2]**: record `<current-branch>` in `state.yaml.repo_branches[<repo>]`. The implementer will commit directly to this branch — use this only if you are already on an appropriate feature branch, not on `main` or a protected branch.
- **[3]**: prompt for a name. Validate with `git -C <repo_path> check-ref-format --branch <name>`. Re-prompt once on failure, then error and halt advance.

For multi-repo projects: repeat steps 4.5a–4.5c for each linked repo in sequence before proceeding.

If `state.yaml.fast_track: true`: skip the interactive prompt in 4.5c entirely. Auto-select option [1] with the suggested branch name for each linked repo. Log the auto-selection to history (Step 4.5d) as normal.

**4.5d — Write `repo_branches` to `state.yaml`**

After all repos are resolved:
```yaml
repo_branches:
  <repo-name>: "<chosen-branch>"
```

Append to `history`:
```yaml
- at: "<timestamp>"
  action: branch_setup
  from_stage: "<current-stage>"
  to_stage: "<next-stage>"
  note: "Branch selected for <repo-name>: <chosen-branch>"
```

### Step 5 — Determine next stage

Determine next stage dynamically from `state.yaml`:

```
current_index = stage_order.index(current_stage)
if current_index + 1 >= len(stage_order):
    → project is complete; tell user to run /dossier
else:
    next_stage = stage_order[current_index + 1]
    next_agent = stages[next_stage].agent
    next_skill = stages[next_stage].skill
```

For any stage with `agent: implementer`, the implementation loop logic applies —
see `agents/orchestrator.md` for the per-task loop details.

### Step 6 — Update state.yaml: next stage in-progress

```yaml
current_stage: "<next-stage>"
stages:
  <next-stage>:
    status: in-progress
    started_at: <ISO 8601 timestamp>
```

### Step 7 — Build context and invoke next agent

Curate the context for the next agent precisely. See `agents/orchestrator.md` for context discipline rules.

Do not pass full conversation history. Pass only:
- Next stage's `SKILL.md` + `INSTRUCTIONS.md`
- Prior stage artifacts (specific files, not entire directories)
- Relevant memory (global + repo + project)

### Step 8 — Confirm to user

> **Stage `<current>` complete** ✅
>
> [List any soft gate warnings]
>
> **Stage `<next>` started** 🔄
> Agent: `<agent-name>`
> Will produce: [list artifacts]
>
> I'll let you know when it's ready for your review.

---

## Special Behaviors

### Advancing through the implementation loop

The implementation stage uses wave-based parallel dispatch (see `agents/orchestrator.md` for the full algorithm). The key points for `/advance`:

When in Stage 06 and a task is `in-review`:
- Run the per-task implementation gate checklist
- On pass: invoke `reviewer` for that task as an isolated sub-agent
- Report: "Task 003 implementation complete. Code Review (Stage 07) running for this task."

When reviewer reports PASS for a task:
- Check whether other tasks in the **same wave** are still in flight — if so, wait for them.
- When the wave is fully reviewed: read `05-tasks/INDEX.md` for the next wave.
  - Next wave exists → dispatch all tasks in that wave as parallel implementer sub-agents
  - No more waves (all tasks complete) → advance to Stage 08

### fast_track auto-advance (hotfix mode only)

When `state.yaml.fast_track: true` and the agent reports done:
1. Run gate check (hard gate failures become warnings — they do not block)
2. Update current stage to `complete`
3. Update next stage to `in-progress`
4. Automatically invoke next stage's agent — do not wait for `/approve`
5. Tell developer: "⚡ Auto-advancing to <next stage label>..."

The developer can pause at any time by running `/comment "<text>"`.

### Dry-run mode (for user clarity)

If the user runs `/advance` and the stage has not been approved yet, offer a preview:

> Stage `04-tech-design` is `in-review` (not yet approved).
>
> When you run `/approve` then `/advance`, here's what will happen:
> - Gate check will run for Stage 04
> - If passed, Stage 05 (Task Breakdown) will start
> - Architect agent will produce task files in `05-tasks/`
>
> Run `/approve` first, then `/advance`.

---

## State Changes

| File | What changes |
|---|---|
| `state.yaml` | `current_stage` updated; stage statuses updated; `gate_bypass_pending` entries consumed; `gate_results` recorded; `repo_branches` set (when advancing into implementation for the first time); history appended |
| `manifest.yaml` | `branch_naming_pattern` added to repo entry (when inferred for the first time, during branch setup) |
| `decisions.log.md` | Entry appended including gate results, bypasses, and any non-default strictness |

No artifact files are written by `/advance` itself — that is the agent's job.

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Use `/start-project` or `/switch <name>`." |
| Current stage is `pending` or `in-progress` | Show current status; explain what needs to happen first |
| Hard gate fails (no bypass pending) | Show exactly which gate failed and what's missing; suggest `/override-gate --bypass`; do not advance |
| Already at final stage | "Project is at the final stage. Use `/dossier` to compile the final artifact." |
| Stage was skipped | Proceed to the stage after the skipped one |
| `gate_config.strictness` is unrecognised value | Warn and fall back to `balanced` |
| `git` command fails during branch setup (bad repo path, not a git repo) | Halt advance. Report: "Branch setup failed: could not read branches from `<repo-name>` at `<repo_path>`. Verify the path in `manifest.yaml` and that the directory is a git repository." |
