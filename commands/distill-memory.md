---
name: distill-memory
description: >
  After a project is complete (or at any stage), analyze project artifacts and
  propose memory updates across all three tiers: global, repo, and project.
  Each proposal is shown to the user for explicit approval before any file is written.
arguments:
  - name: project-name
    description: Optional. Project to distill from. Defaults to the active project.
    required: false
  - name: --patterns
    description: Mine cross-project patterns from all completed projects. Does not require a specific project. Suggests pattern entries when 2+ projects show the same signal.
    required: false
---

# `/distill-memory` Command

## Purpose

Extract durable learnings from a completed project and propose additions to Helmsman's three-tier memory system. Nothing is written without user approval — every proposal is a checkpoint.

Run this after Stage 09 (Launch) for maximum signal, but it is safe to run at any stage.

## Syntax

```
/distill-memory
/distill-memory <project-name>
/distill-memory --patterns
```

---

## Step-by-Step Behavior

### Step 1 — Identify project and collect source artifacts

- If `<project-name>` given: use that project. Otherwise: use the active project from `state.yaml`.
- Collect the following as source material for analysis:
  - `decisions.log.md` — every decision made and why
  - `dossier.md` (if exists) — compiled project summary
  - `06-implementation/task-notes/` — all `NNN-<slug>.md` files (implementation surprises, deviations, debt noted)
  - `02-prd-clean/clean-prd.md` — original goals and constraints
  - `04-tech-design/design.md` and `adrs/` — architectural choices and rationale

- Read `state.yaml` for: `linked_repos`, `mode`, project name.
- Read `manifest.yaml` for: repo paths.

### Step 2 — Analyze for learnable signals

For each source artifact, look for:

| Signal type | Where to find it | Memory tier |
|---|---|---|
| Developer workflow preferences revealed | PRD comments, `/comment` history in decisions.log | Global |
| Communication style signals | Direct feedback in `/comment` calls and explicit rejection notes in decisions.log (e.g., "too verbose", "skip preamble"); only write if the signal is clear and repeated, not from a single data point | Global |
| Repo-specific architectural patterns used | task-notes deviations, design.md quirks, ADRs | Repo |
| Repo-specific gotchas discovered | task-notes "items noticed but not fixed", BLOCKED reports | Repo |
| Project-specific constraints that resolved | Active constraints from project CLAUDE.md that proved correct or wrong | Project |
| Cross-project patterns (flag for Phase 5) | Patterns that likely recur across projects — note but do not write yet | Patterns (Phase 5) |

**Do not propose:**
- Content already present in the target memory file
- Speculation — only write what was directly demonstrated in this project
- Generic best practices — only things specific to this workspace, repo, or developer
- Full ADR content — memory entries are one-liners, not essays

**Pattern candidates**: cross-project pattern candidates identified in Step 2 are held in memory until Step 6. They are not written to any file in this command — Phase 5 (`/distill-memory --patterns`) handles them.

### Step 3 — Build proposal list

Produce a structured list of proposals, grouped by tier. Each proposal is:

```
Tier: global | repo:<name> | project
Section: <which section in the memory file this belongs in>
Action: add | update | remove
Content: <the exact text to add/update/remove — one bullet or one sentence>
Reason: <one sentence citing the source artifact and what signal it gave>
```

Example proposals:

```
Tier: global
Section: Workflow Preferences
Action: add
Content: - **Task notes**: Developer reads task-notes carefully — always write task-notes even for trivial tasks
Reason: decisions.log shows user approved 3 task-notes entries that were marked "None" in prior convention

Tier: repo:payments-service
Section: Architectural Quirks
Action: add
Content: - Idempotency keys must be stored in a separate `idempotency` table, not on the transaction — confirmed in ADR-002
Reason: ADR-002 + implementer task-notes flagged this as a common misapplication

Tier: project
Section: Key Decisions
Action: add
Content: - **Refunds deferred**: PM confirmed verbally refunds are v2; no refund logic should be added
Reason: decisions.log 2025-01-15 entry "Refunds deferred to v2"
```

If no proposals were identified (all signals are already captured in memory, or the project produced no learnable signal), skip Steps 4 and 5 and report directly to the user:

> No new memory proposals for this project. Memory files are already up to date, or the project did not produce durable learnings.

### Step 4 — Present proposals for approval (one at a time)

For each proposal, present it to the user in this format:

```
## Memory Proposal N/M

**Tier**: Global memory (`memory/CLAUDE.md`)
**Section**: Workflow Preferences
**Action**: Add

**Proposed addition**:
- **Task notes**: Developer reads task-notes carefully — always write them even for trivial tasks

**Why**: decisions.log entry 2025-01-15 shows user flagged three "None" task-notes as insufficient.

Approve? [yes / no / edit]
```

Wait for the user's response before moving to the next proposal:
- `yes` — queue for writing
- `no` — discard; log skipped
- `edit` — the agent responds: "Please provide the revised text as a single bullet or sentence." The user's next message is the replacement content. The agent then re-presents the proposal with the revised text (same format as above, labeled "Revised:") and waits for `yes` or `no`. Only `yes` queues it for writing.

Do not present more than one proposal at a time. Do not write anything until Step 5.

### Step 5 — Write approved proposals

After the user has responded to all proposals (or user said "stop"):

For each approved proposal:
1. Read the current memory file
2. Find the target section
3. Append the new bullet (for `add`) or replace the matching line (for `update`) or remove it (for `remove`)
4. Write the file

For `repo:<name>` tier: the target file is `memory/repos/<name>.md`. If the file does not exist, create it using `templates/repo-claude.template.md` with the `{{repo_name}}` placeholder filled.

**If the target section does not exist in the memory file**: create it at the end of the file. Use the section heading from the proposal's `Section` field as a level-2 heading (`##`). Then append the content under it.

**Where to append**: insert new content immediately after the last line of the named section — before the next `##` heading or end of file, whichever comes first. Never append to the end of the file if a matching section exists.

**Tier-to-file mapping**:
- `global` → `memory/CLAUDE.md`
- `repo:<name>` → `memory/repos/<name>.md`
- `project` → `projects/<name>/CLAUDE.md`

**Idempotency**: before writing any proposal, check if the exact content already exists in that section. If it does, skip silently.

Report to user:
```
Memory updated:
- memory/CLAUDE.md — 2 additions
- memory/repos/payments-service.md — 1 addition
- projects/payments-v2/CLAUDE.md — 1 addition

Skipped: 3 proposals (user declined)
```

### Step 6 — Suggest running `/distill-memory` for patterns (Phase 5)

If any cross-project pattern candidates were flagged in Step 2, tell the user:

> N cross-project pattern candidates identified. Run `/distill-memory --patterns` to review them.

---

## Design Notes

**Approval-first**: nothing is written to memory until the user approves it. Memory files are durable — a bad entry persists until manually removed. The cost of a false write is higher than the cost of an extra checkpoint.

**One proposal at a time**: batching proposals leads to rubber-stamp approvals. Each proposal deserves a moment of consideration.

**Source citations in proposals**: every proposal includes a `Reason` citing where the signal came from. This lets the user verify before approving.

**Idempotency**: if a bullet already exists verbatim in the target section, skip it silently.

---

## State Changes

| File | What changes |
|---|---|
| `memory/CLAUDE.md` | Approved global proposals appended to relevant sections |
| `memory/repos/<name>.md` | Approved repo proposals appended; created if absent |
| `projects/<name>/CLAUDE.md` | Approved project proposals appended |
| `state.yaml` | No changes |
| `decisions.log.md` | No changes |

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Run `/distill-memory <project-name>`." |
| Source artifacts missing (no dossier, no task-notes) | Proceed with what's available; note which sources were absent in the proposal header |
| Memory file for repo does not exist | Create it from `templates/repo-claude.template.md` before writing |
| User says "stop" mid-review | Write all proposals approved so far; report what was skipped |

---

## `--patterns` Mode

Running `/distill-memory --patterns` scans all completed projects to identify recurring patterns worthy of adding to `memory/patterns/`.

### When to Run

Run after completing 2 or more projects, or whenever the Orchestrator suggests it at the end of a project.

### Step-by-Step Behavior

#### Step 1 — Collect all completed projects

Scan `projects/` for all subdirectories containing a `state.yaml` where at least one stage has `status: complete`. For each qualifying project, collect:
- `dossier.md` (if exists)
- `decisions.log.md`
- `04-tech-design/adrs/`
- `06-implementation/task-notes/` (all files)
- Re-scan the same artifacts that `/distill-memory` would scan for each completed project — `--patterns` mode derives candidates fresh from project artifacts rather than relying on ephemeral in-session flags from prior runs.

#### Step 2 — Detect recurring signals

A pattern candidate requires **evidence from at least 2 different projects**. Look for:

| Signal type | Example | Minimum evidence |
|---|---|---|
| Architectural pattern | "Auth changes always require audit log updates" | 2+ projects touched both auth and audit |
| Dev workflow preference | "User always splits DB schema and service logic tasks" | 2+ projects with same task structure |
| Repo-specific recurring issue | "payments-service tests are slow without connection pooling" | 2+ task-notes mention the same issue |
| Tech stack constraint | "Redis eviction policy must be `allkeys-lru` for all caching features" | 2+ ADRs reached same conclusion |

For each candidate: note the projects it appeared in, where exactly (artifact + line/section), and a one-line summary of the pattern.

#### Step 3 — Filter noise

Discard candidates that are:
- Already documented in a `memory/patterns/*.md` file (check existing files)
- Already present as a bullet in `memory/CLAUDE.md` or any `memory/repos/*.md`
- Only observed in a single project (2-project minimum is strict)
- Generic best practices not specific to this workspace

#### Step 4 — Present pattern proposals (one at a time)

For each surviving candidate, present:

```
## Pattern Proposal N/M

**Title**: <proposed pattern title>
**Category**: architectural | workflow | repo-specific | tech-stack
**Confidence**: low (2 projects) | medium (3–4 projects) | high (5+ projects)
**Observed in**: <project-1>, <project-2> [, ...]

**Summary**: <one sentence>

**Evidence**:
- <project-1>: <artifact path> — <what was observed>
- <project-2>: <artifact path> — <what was observed>

**Proposed guidance**: <what agents should do when encountering this>

Add to memory/patterns/? [yes / no / edit]
```

Wait for user response before moving to the next proposal:
- `yes` — create the pattern file
- `no` — discard
- `edit` — prompt "Please provide your revised summary or guidance." Re-present revised proposal labeled "Revised:" and wait for `yes`/`no`.

#### Step 5 — Write approved patterns

For each approved pattern:

1. Generate a `pattern_id` as a short slug from the title (e.g., `auth-audit-logging`)
2. Determine the file path: `memory/patterns/<pattern_id>.md`
3. If `memory/patterns/` does not exist: create the directory
4. If the file already exists: append the new project observations to the "Observed In" table; do not overwrite existing entries
5. If the file does not exist: create it from `templates/pattern.template.md`, filling all placeholders. Placeholder mapping from the proposal: `{{pattern_title}}` ← proposal Title; `{{pattern_id}}` ← generated slug; `{{category}}` ← proposal Category; `{{confidence}}` ← proposal Confidence; `{{first_project}}` and `{{project_list}}` ← proposal "Observed in" projects; `{{last_updated}}` ← today's date; `{{summary}}` ← proposal Summary; `{{guidance}}` ← proposal Proposed guidance. For `{{counter_indicator}}` and `{{freeform_notes}}`: derive counter-indicators from context if evident, otherwise leave as a stub (`TBD`). For the "Observed In" table: add one row per project in the proposal's evidence list.
6. Write the file

Report to user:
```
Patterns written:
- memory/patterns/auth-audit-logging.md (new)
- memory/patterns/redis-eviction-policy.md (updated — 1 new project added)

Skipped: 2 proposals (user declined)
```

#### Step 6 — Update `memory/CLAUDE.md` cross-project learnings

For each newly written pattern, add a one-liner reference to `memory/CLAUDE.md` under `## Cross-Project Learnings`:

```
- **<pattern_title>**: see [`memory/patterns/<pattern_id>.md`](memory/patterns/<pattern_id>.md)
```

If the `## Cross-Project Learnings` section does not exist in `memory/CLAUDE.md`, create it at the end of the file before appending. Insert the reference immediately before the next `##` heading or at end of file.

Insert the reference immediately after the last existing line in the section, before the next `##` heading or end of file.

Only add if not already present (idempotency).
