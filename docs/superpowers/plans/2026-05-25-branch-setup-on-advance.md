# Branch Setup on Advance to Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When `/advance` transitions into an implementation stage, intercept to ask the developer which branch to work on, infer the repo's naming convention, and record the chosen branch in `state.yaml.repo_branches` before the implementer starts.

**Architecture:** The interception is a new Step 4.5 in `advance.md`, fires only when the next stage has `agent: implementer` and `repo_branches` is not yet set. The Orchestrator handles it directly (no sub-agent). Branch naming convention is inferred from `git branch -a` on first use and cached in `manifest.yaml`.

**Tech Stack:** Markdown, YAML, shell (`git`). No compiled code — all changes are to documentation files that agents read as instructions.

---

## File Map

| File | Change |
|---|---|
| `helmsman/commands/advance.md` | Add Step 4.5 (branch-setup interception) between Step 4 and Step 5; update State Changes table |
| `helmsman/agents/orchestrator.md` | Add "Branch Setup" note in the implementation loop section |
| `helmsman/docs/SCHEMAS.md` | Fix `repo_branches` write-timing description; add `branch_naming_pattern` to `repos[]` table |

---

## Task 1: Add Step 4.5 to `advance.md`

**Files:**
- Modify: `helmsman/commands/advance.md` (around line 110 — between "Step 4" and "Step 5")

The current text at Step 5 starts with `### Step 5 — Determine next stage`. Insert the new step between Step 4's closing content and Step 5's heading.

- [ ] **Step 1: Open the file and locate the insertion point**

  Read `helmsman/commands/advance.md`. Find the line `### Step 5 — Determine next stage`. The new step goes immediately before it.

- [ ] **Step 2: Insert Step 4.5 before "Step 5 — Determine next stage"**

  Insert the following block immediately before `### Step 5 — Determine next stage`:

  ````markdown
  ### Step 4.5 — Branch setup (pre-implementation interception)

  **When to run:** only when both conditions are true:
  - The **next stage** (determined by `stage_order[current_index + 1]`) has `agent: implementer`
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
  - **[2]**: record `<current-branch>` in `state.yaml.repo_branches[<repo>]`. The implementer will find it already checked out and proceed.
  - **[3]**: prompt for a name. Validate with `git -C <repo_path> check-ref-format --branch <name>`. Re-prompt once on failure, then error and halt advance.

  For multi-repo projects: repeat steps 4.5a–4.5c for each linked repo in sequence before proceeding.

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
    stage: <next-stage>
    note: "Branch selected for <repo-name>: <chosen-branch>"
  ```

  ````

- [ ] **Step 3: Update the State Changes table at the bottom of `advance.md`**

  Find the table under `## State Changes`. It currently has:

  ```markdown
  | `state.yaml` | `current_stage` updated; stage statuses updated; `gate_bypass_pending` entries consumed; `gate_results` recorded; history appended |
  ```

  Replace that row with:

  ```markdown
  | `state.yaml` | `current_stage` updated; stage statuses updated; `gate_bypass_pending` entries consumed; `gate_results` recorded; `repo_branches` set (when advancing into implementation for the first time); history appended |
  | `manifest.yaml` | `branch_naming_pattern` added to repo entry (when inferred for the first time, during branch setup) |
  ```

- [ ] **Step 4: Verify the file reads coherently**

  Read the modified file. Confirm:
  - Step 4.5 appears between Step 4 and Step 5
  - The multi-repo note is present
  - The State Changes table now includes both `state.yaml` and `manifest.yaml` rows
  - No `{{placeholder}}` tokens remain

- [ ] **Step 5: Commit**

  ```bash
  git add helmsman/commands/advance.md
  git commit -m "feat(advance): add Step 4.5 branch-setup interception before implementation"
  ```

---

## Task 2: Update `orchestrator.md` — branch setup note in implementation loop section

**Files:**
- Modify: `helmsman/agents/orchestrator.md` (around line 80 — the "Implementation loop" section)

- [ ] **Step 1: Locate the implementation loop section**

  Read `helmsman/agents/orchestrator.md`. Find `### Implementation loop (stages with agent: implementer)`. The block currently reads:

  ```markdown
  ### Implementation loop (stages with agent: implementer)

  When the current stage has `agent: implementer`:
  - Implementer runs one task at a time (same as feature mode)
  - After each task: invoke `reviewer` for that task
  - After reviewer PASS: check `progress.md` for remaining tasks
    - More tasks pending → invoke `implementer` for next task
    - All tasks complete → advance to next stage in `stage_order`
  ```

- [ ] **Step 2: Add branch-setup note at the top of that section**

  Replace the implementation loop section with:

  ```markdown
  ### Implementation loop (stages with agent: implementer)

  **Before the first task:** When `/advance` transitions into an implementation stage and `state.yaml.repo_branches` is not yet populated, the Orchestrator runs the branch-setup interception (Step 4.5 of `/advance`) to ask the developer which branch to use. The chosen branch is written to `state.yaml.repo_branches` and `manifest.yaml.repos[].branch_naming_pattern` (if newly inferred). Only after this is complete does the implementer start. If `repo_branches` is already set, this step is skipped.

  When the current stage has `agent: implementer`:
  - Implementer runs one task at a time (same as feature mode)
  - After each task: invoke `reviewer` for that task
  - After reviewer PASS: check `progress.md` for remaining tasks
    - More tasks pending → invoke `implementer` for next task
    - All tasks complete → advance to next stage in `stage_order`

  The implementation loop applies to ANY stage with `agent: implementer`,
  regardless of mode. The stage ID does not need to be `06-implementation`.
  ```

- [ ] **Step 3: Verify the file reads coherently**

  Read the modified `orchestrator.md`. Confirm:
  - The branch-setup note appears at the top of the implementation loop section
  - The existing loop logic (per-task, reviewer, progress.md) is unchanged
  - The "applies to ANY stage" note is still present at the end

- [ ] **Step 4: Commit**

  ```bash
  git add helmsman/agents/orchestrator.md
  git commit -m "feat(orchestrator): document branch-setup interception in implementation loop"
  ```

---

## Task 3: Update `SCHEMAS.md` — fix `repo_branches` timing + add `branch_naming_pattern`

**Files:**
- Modify: `helmsman/docs/SCHEMAS.md` (line 57 for `repo_branches`; line ~38 for `repos[]` table)

- [ ] **Step 1: Fix `repo_branches` write-timing description**

  Find line 57 in `helmsman/docs/SCHEMAS.md`:

  ```markdown
  | `repo_branches` | object | Maps each linked repo name to its active branch for this project. Branch name follows `default_branch_pattern` from `manifest.yaml`. Set at `/start-project`; one entry per linked repo. |
  ```

  Replace with:

  ```markdown
  | `repo_branches` | object | Maps each linked repo name to its active branch for this project. Set during `/advance` into the first implementation stage (branch-setup interception — Step 4.5). One entry per linked repo. If not yet set, the field is absent or empty. |
  ```

- [ ] **Step 2: Add `branch_naming_pattern` to the `repos[]` entry table**

  Find the `### repos[] entry` table (around line 30–40). It currently ends with:

  ```markdown
  | `memory_file` | string | yes | Path to the repo memory file, relative to workspace root. Created automatically on first use. |
  ```

  Add a new row after `memory_file`:

  ```markdown
  | `branch_naming_pattern` | string | no | Inferred git branch naming pattern for this repo (e.g. `feature/{slug}`, `bugfix/{slug}`). Written by Helmsman after the first branch-setup interception. Used to generate branch name suggestions on subsequent projects. If absent, Helmsman infers from `git branch -a` and writes it. |
  ```

- [ ] **Step 3: Verify the file reads coherently**

  Read the modified `SCHEMAS.md`. Confirm:
  - `repo_branches` no longer says "Set at `/start-project`"
  - `branch_naming_pattern` appears in the `repos[]` table
  - No other `repo_branches` references elsewhere in the file still say "Set at `/start-project`" (search for it)

- [ ] **Step 4: Commit**

  ```bash
  git add helmsman/docs/SCHEMAS.md
  git commit -m "docs(schemas): update repo_branches timing; add branch_naming_pattern to repos[] schema"
  ```
