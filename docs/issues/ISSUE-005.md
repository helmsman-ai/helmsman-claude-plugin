# ISSUE-005: Main chat context window reaches 100% during implementation stage

**Type:** Observation
**Component:** skills / implementation
**Command / Trigger:** Running the implementation stage of a Helmsman project (feature mode)

## Observed

The main chat context window fills to 100% of the 200k token limit during the
implementation stage. The session becomes unusable or requires compaction before
the stage can complete.

## Notes

The implementation stage is the most context-heavy stage by nature — it involves
reading source files, writing code, running tests, and accumulating tool output.
However, exhausting the full 200k window suggests the implementation skill or the
Orchestrator is loading more context than necessary into the main chat rather than
delegating work to sub-agents with their own context windows.

Likely causes:
- The implementation skill instructs the agent to do work inline (read, edit,
  run) in the main chat rather than dispatching an implementer sub-agent per task.
- Large artifacts from earlier stages (PRD, tech design, CIR, dossier) remain
  in the main chat context and accumulate alongside implementation tool output.
- The implementer sub-agent, if dispatched, may be returning overly verbose
  results back to the orchestrator rather than writing artifacts to disk and
  returning a short summary.

Relevant files: `helmsman/skills/implementation/SKILL.md`,
`helmsman/skills/implementation/INSTRUCTIONS.md`,
`helmsman/agents/implementer.md`, `helmsman/agents/orchestrator.md`.

A structural fix would be ensuring each implementation task is dispatched to an
isolated sub-agent that writes output to disk and returns only a pass/fail
summary to the main chat.

## Resolution

**Status:** resolved
**Fixed in:** `helmsman/agents/orchestrator.md:Implementation loop`, `helmsman/agents/implementer.md:Status Reporting`
**Summary:** The Orchestrator's implementation loop now explicitly requires dispatching each task as an isolated sub-agent via the Agent tool (never inline), and reading task status from `progress.md` on disk rather than the sub-agent's response text; the Implementer's status report is now capped at 3 lines with all detail required to go to `task-notes/`.
