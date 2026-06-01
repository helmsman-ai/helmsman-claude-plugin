---
name: approve
description: >
  Mark the current stage (or a specific artifact) as accepted by the developer.
  Updates state.yaml and appends to the decision log. Does not automatically
  advance — run /advance after /approve to trigger the next stage.
arguments:
  - name: artifact
    description: Optional. Path to a specific artifact to approve (e.g., "04-tech-design/design.md"). If omitted, approves the entire current stage.
    required: false
---

# `/approve` Command

## Purpose

Record the developer's explicit acceptance of a stage's output. This is the human-in-the-loop gate — nothing advances without it.

`/approve` marks acceptance. `/advance` checks gates and triggers the next agent. They are separate so the developer can approve without immediately triggering forward motion (e.g., approve at end of day, advance the next morning).

## Syntax

```
/approve
/approve <artifact-path>
```

**Examples**:
```
/approve
/approve 04-tech-design/design.md
/approve 05-tasks/003-add-idempotency-check.md
```

---

## Step-by-Step Behavior

### Step 1 — Read current state

Read `state.yaml`:
- `current_stage` — what stage are we approving?
- `stages[current_stage].status` — is it `in-review`?

If status is `pending` or `in-progress`: "Stage `<stage>` is not ready for approval yet — the agent is still working. Wait for the work to complete."

If status is already `complete`: "Stage `<stage>` is already approved (approved at `<timestamp>`). Did you mean to run `/advance`?"

### Step 2 — Determine scope

**Full stage approval** (no argument):
- Approves the entire current stage
- All artifacts in the stage directory are considered accepted
- Updates `state.yaml.stages[current-stage].status` to `complete`

**Single artifact approval** (with argument):
- Only that artifact is marked accepted
- Stage status remains `in-review` until all required artifacts are approved or the full stage is approved
- Use this when iterating on one document while others are already accepted

### Step 3 — Update state.yaml

**Full stage approval**:
```yaml
stages:
  <current-stage>:
    status: complete
    approved_at: "<ISO 8601 timestamp>"
    approved_by: user
```

Append to `history`:
```yaml
- at: "<timestamp>"
  action: approved
  stage: "<current-stage>"
  note: "Full stage approved by developer"
```

**Single artifact approval**:
```yaml
stages:
  <current-stage>:
    status: in-review   # stays in-review
    artifact_approvals:
      "<artifact-path>": "<ISO 8601 timestamp>"
```

Append to `history`:
```yaml
- at: "<timestamp>"
  action: approved
  stage: "<current-stage>"
  note: "Artifact approved: <artifact-path>"
```

### Step 4 — Append to decisions.log.md

```markdown
## <date> — Stage <stage> approved

Stage: <stage>
Action: approved

<Any notable comments or context the developer mentioned>
```

If the developer typed anything alongside the `/approve` command (e.g., `/approve — the design looks good but watch the idempotency race condition`), include that text in the log entry.

### Step 5 — Confirm to user

**Full stage approval**:
> ✅ **Stage `<N> — <Name>` approved.**
>
> Artifacts accepted:
> - `<artifact-path-1>`
> - `<artifact-path-2>`
>
> Run `/advance` to start Stage `<N+1>` — `<Next Stage Name>`.

**Single artifact approval**:
> ✅ **`<artifact-path>` approved.**
>
> Stage `<N> — <Name>` is still `in-review`. Approve remaining artifacts or run `/approve` to accept the full stage.

---

## Special Cases

### Approving with inline feedback

The developer can approve and leave a note in the same command:

```
/approve The architecture looks good. The race condition in the idempotency check should be addressed in the implementation task — I've noted it.
```

Everything after `/approve` (that isn't a file path) is treated as a note. It is:
- Appended to `decisions.log.md`
- Appended to `projects/<name>/CLAUDE.md` project memory under "Notes for Agents"

### Approving a task in the implementation loop

When in Stage 06/07 and approving a specific task after reviewer PASS:

```
/approve 07-review/self-review-003-idempotency-check.md
```

This marks task 003's review as accepted. The Orchestrator then:
1. Updates task 003 status to `complete` in `progress.md`
2. Checks if more tasks remain in `INDEX.md`
3. If yes: automatically invokes `implementer` for the next task (no separate `/advance` needed in the implementation loop)
4. If no: marks Stage 06+07 complete and waits for `/advance` to Stage 08

---

## State Changes

| File | What changes |
|---|---|
| `state.yaml` | Stage status updated to `complete`; `approved_at` set; history appended |
| `decisions.log.md` | Approval entry appended |
| `projects/<name>/CLAUDE.md` | Any inline notes added to "Notes for Agents" section |

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Use `/switch <name>` or `/start-project`." |
| Stage not yet in-review | "Stage `<stage>` is not ready for approval. Status: `<status>`." |
| Stage already approved | "Already approved on `<date>`. Run `/advance` to continue." |
| Artifact path not found | "File `<path>` not found in `projects/<name>/`. Check the path and try again." |
