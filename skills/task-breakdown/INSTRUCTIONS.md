# Task Breakdown — Detailed Instructions

> Load this file when doing the work. `SKILL.md` is the summary.

---

## Inputs

- `04-tech-design/design.md` — component design, data model, API contracts
- `04-tech-design/adrs/` — decisions that constrain implementation order
- `02-prd-clean/clean-prd.md` — acceptance criteria to distribute across tasks
- Repo memory — test patterns, file layout conventions
- `manifest.yaml` (workspace root) — repo registry; use this to enumerate available repo names when assigning `target_repo` to each task. Only assign repos that are listed in `state.yaml.linked_repos` for this project.

---

## Process

### Step 1 — Identify natural decomposition seams

Good tasks follow natural system boundaries. Typical decomposition order for a backend feature:

1. **Schema / migration** — database changes first (everything else depends on them)
2. **Model / entity** — update the data model object to reflect schema
3. **Repository** — new DB query methods
4. **Service logic** — business rules, orchestration
5. **Controller / handler** — HTTP/event boundary
6. **Tests** — integration tests for the full flow (if not colocated with above)
7. **Wiring / config** — dependency injection, route registration, feature flags

Each seam is a candidate task boundary. If a seam is small (< 30 min), merge it with adjacent work. If a seam is large (> 4 hours), split it.

### Step 2 — Size each task honestly

**Target: 1–4 hours per task for a focused engineer who knows the codebase.**

Signs a task is too large:
- "Files to touch" has more than 5–6 files
- The goal requires more than two sentences to describe
- The acceptance criteria list has more than 6 items
- You can't name a single "done" state

Signs a task is too small:
- It has only one acceptance criterion and zero test requirements
- It could be a commit message, not a task file
- It will take under 20 minutes

When in doubt: **split**. A task that's too small costs only a bit of overhead. A task that's too large causes the Implementer to lose scope discipline.

### Step 3 — Map dependencies before writing files

Draw the dependency graph on paper (or in working memory) before writing task files.

Rules:
- A task that creates a schema must precede any task that reads from it
- A task that defines an interface must precede any task that implements against it
- Test tasks can usually run in parallel with wiring tasks if they test the same component
- No circular dependencies — if you find one, you have a design problem, not a task problem
- Cross-repo dependencies are valid (task A in `web-app` can depend on task B in `payments-service`), but flag them explicitly in both task files under `## Dependencies` so the Implementer knows to check across repos. Cross-repo dependencies also affect wave ordering in `INDEX.md` — ensure the blocking task's repo wave is listed before the dependent task's wave.

Verify: can each task be started with only prior tasks' outputs? If yes, the graph is valid.

### Step 4 — Write INDEX.md first

Use `templates/task-index.template.md`. Include:
- Complete task list with numbers, titles, and direct dependencies
- Dependency graph (ASCII or Mermaid)
- Parallelizable groups (Wave 1, Wave 2, etc.)
- Total effort estimate

Do not write individual task files until INDEX.md is complete and the dependency graph is valid.

### Step 5 — Write each task file

Use `templates/task.template.md` for every task. Fill every section — no placeholders.

**Goal**: One sentence. If you need two, the task might be two tasks.

**Context**: What does the Implementer need to know to start immediately?
- Relevant design decisions (which ADR applies here)
- Which prior task's output this task depends on
- Architectural constraints that apply to this specific task
- Any known pitfalls (from codebase findings in Stage 03)

**Files to touch**: Be specific. Include the path relative to the repo root. Mark action: create / modify / delete.
- If uncertain about the exact path, give the directory and describe the file
- Never list entire directories — list specific files

**Acceptance criteria**: Copy relevant ACs from the clean PRD and scope them to this task. Add implementation-specific ACs not in the PRD (e.g., "migration is reversible").
Each must be checkable by reading code or running tests. No adjectives.

**Test requirements**: Name the specific tests:
- "Unit test: `PaymentService.charge()` returns existing transaction when idempotency_key matches"
- Not: "Write tests for the payment service"

**Dependencies**: List task numbers. List what this task blocks.

**Target Repo**: For multi-repo projects, every task file must have its `target_repo` set to exactly one repo name from `manifest.yaml`. Group tasks by repo when possible — a task that touches both `web-app` and `payments-service` is two tasks, not one. For single-repo projects, set `target_repo` to the one linked repo name (do not leave it blank — this field is always populated).

### Step 6 — Distribute acceptance criteria from the PRD

After writing all task files, do a coverage check:
- Every AC from `clean-prd.md` must appear in at least one task file
- No AC should be duplicated across tasks (if it spans tasks, assign to the last task that completes it)
- ACs about the full flow (end-to-end behavior) belong in an integration test task

---

## Quality Checks Before Finishing

- [ ] Every task has: goal, context, files to touch, acceptance criteria (≥1), test requirements (≥1), dependencies
- [ ] `INDEX.md` dependency graph is present and has no cycles
- [ ] Every AC from `clean-prd.md` appears in at least one task
- [ ] No task has > 6 acceptance criteria (likely too large)
- [ ] No task has 0 test requirements (every task must produce at least one test)
- [ ] Effort estimates are present on all tasks
- [ ] No `{{placeholder}}` tokens remain
- [ ] Every task has `target_repo` set to a repo name that appears in both `manifest.yaml` and `state.yaml.linked_repos` for this project
- [ ] No task touches files in two different repos (cross-repo tasks must be split)
- [ ] `INDEX.md` wave ordering respects cross-repo dependencies (blocking repo's wave comes first)

---

## Output Summary to Orchestrator

```
Task breakdown complete.

Tasks created: N
Total estimated effort: Xh
Critical path: task 001 → 003 → 005 → 006 (Xh)
Parallelizable: tasks 002 and 004 can run in parallel after 001

Artifacts:
- 05-tasks/INDEX.md
- 05-tasks/001-<slug>.md through 05-tasks/NNN-<slug>.md

PRD acceptance criteria coverage: all N criteria assigned
Gate status: PASS / FAIL
```
