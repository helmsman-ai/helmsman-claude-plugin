# Implementation — Detailed Instructions

> Load this file when doing the work. `SKILL.md` is the summary.

---

## Inputs

- `05-tasks/NNN-<slug>.md` — the task to implement (your primary reference)
- The task's `target_repo` (from `## Target Repo` in the task file) and its path from `manifest.yaml`. If `target_repo` is absent, default to the sole entry in `state.yaml.linked_repos`.
- Repo memory — conventions, test patterns, architectural rules
- `06-implementation/progress.md` — to read current state and update after
- Any `/comment` feedback specific to this task from the developer

---

## Process

### Step 0 — Before writing any code

1. **Read the task file entirely.** Not just the acceptance criteria — read Context, Implementation Notes, Dependencies.
2. **Identify and enter the target repo**: read `target_repo` from the task file's `## Target Repo` section. Find its `path` in `manifest.yaml`. All subsequent `git` commands run inside that repo directory.

   Before checking the branch, run `git status` — if there are uncommitted changes, stop and report `BLOCKED` with the list of dirty files before doing anything else.

   Read `state.yaml.repo_branches[target_repo]` to get the expected branch name for this project in this repo (e.g., `helmsman/feature-payments-v2`). Run `git branch --show-current`:
   - If the current branch matches `state.yaml.repo_branches[target_repo]`: continue.
   - If the branch does not exist yet: determine the default branch with `git remote show origin | grep "HEAD branch" | awk '{print $NF}'` (or `git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null`), then run `git checkout <default-branch> && git checkout -b <branch-from-repo_branches>`.
   - If you are on the wrong branch and it does exist: stop and report `BLOCKED` with the current branch name — do not switch branches without understanding why.
3. **Open every file in "Files to Touch"**. Read each one. Understand the current state. Do not modify anything yet.
4. **Check that dependency tasks are complete**: look at `progress.md` — the tasks this one depends on must be `complete`. If not, report `BLOCKED`.
5. **Surface ambiguity now**: if anything in the task file is unclear, report `NEEDS_CONTEXT` with a specific question. Do not guess and implement.

### Step 1 — Write tests first

For every acceptance criterion that involves logic:
1. Write the test that describes the expected behaviour
2. Run it — it must fail (if it passes, you either misread the criterion or the code already exists)
3. Keep it simple — one assertion per test case is usually best

Follow the repo's test conventions from repo memory:
- File location (colocated `*.test.ts` vs. separate `__tests__/`)
- Test runner syntax (Jest `describe/it`, Vitest, pytest, etc.)
- Mock/stub patterns (how does this codebase mock external services?)
- Naming (test descriptions should read as sentences)

For infrastructure tasks (pure config changes, migrations with no logic): tests may not apply — note this explicitly in `task-notes/`.

### Step 2 — Implement

Write the minimal code to make the failing tests pass.

Convention discipline:
- **Naming**: match existing patterns exactly. If the codebase uses `getUserById`, your new function is `getTransactionById`, not `fetchTransaction` or `getById`.
- **File placement**: follow existing module structure. If services live in `src/services/`, yours does too.
- **Error handling**: match the codebase's pattern (throw + catch? Result type? Error codes?).
- **Imports**: match import style (named vs. default, relative vs. alias paths).
- **Logging**: if the codebase logs at service entry/exit, do the same.

Scope discipline:
- Implement only what the task file specifies
- If you encounter a bug while working: note it in `task-notes/` with the file and line, then leave it. Do not fix it unless it directly blocks task completion.
- If you see an obvious improvement: note it. Do not make it.

### Step 3 — Run all tests

```bash
# Run the full test suite (not just the new tests)
<test command from repo memory>
```

All tests must pass — both new and existing. If existing tests break:
- Did you change the interface of something? Intentional? Note it.
- Did you introduce a regression? Fix it (this is within scope).
- Are the existing tests testing implementation details that you legitimately changed? Update them (note in `task-notes/`).

Do not commit with failing tests.

### Step 4 — Run lint

```bash
<lint command from repo memory>
```

Fix all lint errors. For warnings: fix them if trivial (< 2 min each); note and leave if complex.

### Step 5 — Self-review before committing

Quickly re-read each changed file:
- Does it look like the rest of the codebase?
- Are there any hardcoded values that should be constants?
- Any TODO comments you added — should they be in `task-notes/` instead?
- Any debugging artifacts (`console.log`, `print`, `debugger`)?

### Step 6 — Commit

```
<type>(<scope>): <what was done>

Task: NNN - <task title>
Acceptance criteria: all met
Tests: N added, all passing
```

Where `<type>` follows repo conventions. If no convention: use `feat` for new behaviour, `fix` for corrections, `refactor` for restructuring, `test` for test-only changes, `chore` for infra/config.

**One task = at least one commit.** For larger tasks, it is fine to have multiple commits (e.g., schema change + service logic + tests as separate commits). The final commit message should reference the task.

### Step 7 — Update progress and write task notes

Update `06-implementation/progress.md`:
- Change this task's `status` to `in-review`
- Add the commit SHA(s)

Create `06-implementation/task-notes/NNN-<slug>.md`:
```markdown
# Task NNN Notes — <title>

## What was implemented
[2-3 sentences]

## Decisions made not in the task spec
[list or "none"]

## Deviations from task spec
[list with reason, or "none"]

## Items noticed but not fixed
[list with file:line, or "none"]

## Edge cases handled beyond spec
[list with reasoning, or "none"]
```

---

## Quality Checks Before Reporting DONE

- [ ] All acceptance criteria checked off (mentally — they are not literally checkboxes in most editors)
- [ ] All test requirements met — tests exist and pass
- [ ] Full test suite passes (not just new tests)
- [ ] Lint clean
- [ ] No debugging artifacts in code
- [ ] Committed to `helmsman/<project>` branch in the task's `target_repo`
- [ ] `progress.md` updated with new status and commit SHA
- [ ] `task-notes/` file written

---

## Status Reporting

Report one of four statuses to the Orchestrator after completing your turn:

| Status | When to use |
|---|---|
| `DONE` | All criteria met, tests pass, committed, progress updated |
| `DONE_WITH_CONCERNS` | Done, but you have doubts about approach, edge cases, or scope — list them |
| `NEEDS_CONTEXT` | Something in the task spec is unclear and you cannot safely proceed — state the exact question |
| `BLOCKED` | Cannot complete — broken environment, conflicting existing code, incorrect spec, dependency not done |

For `NEEDS_CONTEXT` and `BLOCKED`: describe specifically what you need. "The task says to modify X but X doesn't exist" is actionable. "I'm not sure what to do" is not.
