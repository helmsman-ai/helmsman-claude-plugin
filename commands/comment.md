---
name: comment
description: >
  Add inline feedback on the current stage's output and re-invoke the responsible
  agent to address it. The agent revises artifacts in response to the comment.
  Does not change stage status.
arguments:
  - name: text
    description: The feedback text. Can reference specific artifacts or be general.
    required: true
  - name: --on
    description: Optional. Specific artifact file to attach the comment to (e.g., "--on 04-tech-design/design.md").
    required: false
---

# `/comment` Command

## Purpose

Give the active agent targeted feedback to revise its output — without rejecting the entire stage or forcing a restart.

This is the primary collaboration mechanism. Use it to:
- Request changes to a specific artifact
- Add a requirement the PRD missed
- Push back on an architectural choice
- Ask the agent to reconsider something

## Syntax

```
/comment "<feedback text>"
/comment --on <artifact-path> "<feedback text>"
```

**Examples**:
```
/comment "The /charge endpoint must also support guest checkout — no auth required for guest orders"
/comment --on 04-tech-design/design.md "Section 6 is missing the error response for invalid idempotency_key format"
/comment --on 02-prd-clean/open-questions.md "Q-01 is answered: idempotency_key is a UUID v4, max 36 chars, caller-generated"
```

---

## Step-by-Step Behavior

### Step 1 — Read current state

Read `state.yaml`:
- `current_stage` — what stage is active?
- `stages[current_stage].status` — must be `in-progress` or `in-review` to accept comments

If status is `complete`: "Stage `<stage>` is already approved. To revise it, you would need to use `/jump-back` (v1 feature). For now, you can make manual edits to the artifact and re-run `/advance`."

If status is `pending`: "Stage `<stage>` hasn't started yet. Run `/advance` to start it."

### Step 2 — Log the comment

Append the comment to `decisions.log.md`:

```markdown
## <date> — Developer comment on Stage <stage>

Stage: <current-stage>
Artifact: <artifact-path or "general">

> <comment text>

Agent will address this in the next revision.
```

If `--on` was provided: also append the comment as a block at the bottom of the specified artifact file:

```markdown
---

<!-- DEVELOPER COMMENT — <date> -->
> <comment text>
<!-- END COMMENT -->
```

This makes the comment visible in the artifact file itself, so the agent sees it inline.

### Step 3 — Determine which agent to re-invoke

Read `stages[current_stage].agent` from `state.yaml`. If `agent` is null, the Orchestrator handles the revision directly.

### Step 4 — Build context and re-invoke agent

Construct context:
- All current stage artifacts (including the comment just appended)
- The stage's `SKILL.md` + `INSTRUCTIONS.md`
- The specific comment, highlighted: "The developer has left the following feedback that you must address: `<comment text>`"
- If `--on` was specified: load that specific artifact as the primary focus
- Relevant memory

Re-invoke the agent with this context. The agent's job is to revise the relevant artifacts to address the comment — not to redo all work from scratch.

### Step 5 — Update state.yaml

If the stage was `complete` (already approved but the developer is adding a minor note):
- Move it back to `in-review`
- Log this in history

```yaml
- at: "<timestamp>"
  action: commented
  stage: "<current-stage>"
  note: "<comment text truncated to 100 chars>"
```

If the stage was `in-review`: no status change needed. Append to history only.

### Step 6 — Confirm to user

> 💬 **Comment received** on Stage `<N> — <Name>`.
>
> Feedback: *"<comment text>"*
>
> The `<agent-name>` agent is revising the output to address your feedback.
> Run `/approve` when the revision looks good, or `/comment` again with further feedback.

---

## Comment Types and How Agents Should Handle Them

The agent receiving the comment must classify and handle it:

| Comment type | Example | How agent handles |
|---|---|---|
| **Clarification** | "Q-01 is answered: UUID v4, max 36 chars" | Resolve the open question; update clean-prd.md AC |
| **Addition** | "Also add guest checkout support" | Add to goals/ACs in clean-prd.md; flag new scope in assumptions |
| **Correction** | "Section 6 is missing the error response" | Fill the missing section; re-check gate compliance |
| **Pushback** | "I prefer Option B over Option A" | Update alternatives.md, write new ADR, update design.md |
| **Out of scope** | "Refunds are definitely NOT in scope" | Add explicit entry to out-of-scope.md; remove from any ACs |

---

## State Changes

| File | What changes |
|---|---|
| `decisions.log.md` | Comment entry appended |
| Artifact file (if `--on`) | Comment block appended at bottom |
| `state.yaml` | History entry appended; status moved to `in-review` if it was `complete` |

No artifact files are deleted. Revisions are made by the agent updating the existing files.

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Use `/switch <name>` or `/start-project`." |
| Stage is `pending` | "Stage `<stage>` hasn't started yet." |
| Empty comment | "Please provide feedback text after `/comment`." |
| `--on` artifact path not found | "File `<path>` not found. Check the path and try again." |
| Stage is `complete` and no agent to re-invoke | "Stage `<stage>` is approved. Your comment has been logged in `decisions.log.md`. To revise the artifact, use `/jump-back` (v1) or edit the file manually." |
