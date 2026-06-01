# Helmsman Concepts

This page explains the mental model behind Helmsman. Read this before diving
into specific modes or commands.

---

## Projects vs Repos

A **project** in Helmsman is an SDLC unit of work — a feature, a bug fix, an
experiment. It lives in `projects/<name>/` inside your Helmsman workspace.

A **repo** is a git repository registered in `manifest.yaml`. One project can
touch multiple repos. One repo can have many Helmsman projects over time.

They are separate: Helmsman's project state lives in the workspace, not in
your repo. Your repo gets the code commits. Helmsman tracks everything else.

---

## Stage Lifecycle

Every project moves through an ordered list of stages defined by its mode.
Each stage has exactly one status at any time:

```
pending → in-progress → in-review → complete
                                         ↓ (after /jump-back)
                                       stale
```

- **pending** — not yet started
- **in-progress** — the active agent is working
- **in-review** — artifacts are ready; waiting for your `/approve`
- **complete** — approved; stage is locked
- **stale** — a prior stage was changed via `/jump-back`; this stage's artifacts
  may no longer be accurate and need to be re-run via `/propagate`

Only one stage is active at a time. `/advance` moves to the next stage after
gates pass. `/approve` signals your acceptance of the current stage's output.

---

## Agents vs Skills

An **agent** is a specialist who does the work: the PRD Reviewer, the Researcher,
the Architect, the Implementer, the Reviewer. Each agent has a clear role and
produces specific artifacts.

A **skill** is the instruction set the agent loads for a given stage: the templates,
checklists, and behavioral guidelines relevant to that stage's task. Skills are
what makes each agent's output consistent.

The distinction matters because **skills are customizable**. You can override or
augment a skill for your workspace without changing the agent. See
[SKILL_MARKETPLACE.md](SKILL_MARKETPLACE.md).

---

## Gates

Gates are quality checks that run when you call `/advance`. They inspect the
current stage's artifacts and either block or warn.

**Severity levels:**

| Severity | Effect |
|---|---|
| `hard` | Blocks `/advance` until the gate passes or is explicitly overridden with a reason |
| `soft` | Warns you but allows `/advance` to proceed |
| `skip` | Gate is omitted entirely (set via `/override-gate`) |

**Project-level strictness** changes how all gates behave:

| Strictness | Effect |
|---|---|
| `strict` | All soft gates promoted to hard |
| `balanced` | Default — gates behave as defined in the mode |
| `lenient` | All hard gates demoted to soft |

Set strictness in `manifest.yaml` under `defaults.reviewer_strictness`, or
per-project via `/override-gate`.

**Hotfix exception:** In `fast_track` mode (hotfix only), hard gates automatically
downgrade to warnings so the pipeline never blocks an emergency fix.

---

## The Dossier

The **dossier** (`projects/<name>/dossier.md`) is the final compiled artifact of a
completed project. It is a single readable document containing:

- The clean PRD and acceptance criteria
- Key discovery findings
- The architecture decision and alternatives considered
- The task list and implementation notes
- The review report summary
- The decisions log

The dossier is for future maintainers. Six months from now, when someone asks
"why was this built this way?", the dossier has the answer.

Run `/dossier` at any point after Stage 06 to compile it.

---

## The Decisions Log

`projects/<name>/decisions.log.md` is an **append-only** record of every
significant action in the project:

- Stage advances and approvals
- Architecture choices made
- Gates bypassed (with reasons)
- User comments that changed direction
- Jump-backs and their reasons

The Orchestrator writes to it automatically. You never edit it manually. It is
the audit trail that makes the dossier trustworthy.
