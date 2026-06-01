# ISSUE-006: Implementer tasks that could run in parallel are executed sequentially

**Type:** Observation
**Component:** skills / implementation
**Command / Trigger:** Running the implementation stage with multiple independent tasks

## Observed

During the implementation stage, tasks that had no dependency on each other were
dispatched one at a time sequentially. The implementer waited for each task to
finish before starting the next, even when the tasks were clearly independent
(e.g. separate modules, separate files, no shared state).

## Notes

The task-breakdown stage is supposed to produce a dependency-ordered task list,
which implicitly identifies which tasks can be parallelised (tasks at the same
dependency level). The implementer should dispatch independent tasks concurrently
as parallel sub-agents rather than processing them in a loop.

Likely causes:
- The implementation skill or implementer agent instructions do not explicitly
  instruct parallel dispatch for independent tasks — the agent defaults to a
  sequential loop because that is simpler to reason about.
- The task list produced by task-breakdown does not carry explicit parallelism
  metadata (e.g. a `parallel_group` field), leaving the implementer to infer
  independence — which it may not be doing.
- The Orchestrator may be dispatching a single implementer sub-agent and having
  it loop through tasks rather than spawning one sub-agent per task.

Sequential execution also compounds ISSUE-005 (context window exhaustion), since
all tool output accumulates in one session instead of being isolated per sub-agent.

Relevant files: `helmsman/skills/implementation/SKILL.md`,
`helmsman/skills/implementation/INSTRUCTIONS.md`,
`helmsman/agents/implementer.md`, `helmsman/skills/task-breakdown/SKILL.md`.

## Resolution

**Status:** resolved
**Fixed in:** `helmsman/agents/orchestrator.md:Implementation loop`, `helmsman/commands/advance.md:Advancing through the implementation loop`, `helmsman/skills/implementation/SKILL.md:When This Skill Is Active`
**Summary:** The Orchestrator's implementation loop now reads the "Parallelizable Groups" wave table from `05-tasks/INDEX.md` and dispatches all tasks in each wave as parallel isolated sub-agents, falling back to sequential dispatch if no wave table is present.
