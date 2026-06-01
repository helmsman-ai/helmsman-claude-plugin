# ISSUE-004: Orchestrator prompts to resume and burns high tokens on fresh session start

**Type:** Bug
**Component:** agents / orchestrator
**Command / Trigger:** Starting a fresh Claude Code session when an active Helmsman project already exists in `state.yaml`

## Observed

Two problems surface together on fresh session start:

1. **Unnecessary resume prompt** — The Orchestrator asks the user "do you want to resume?" even when the project name already exists in `state.yaml` and the active stage is unambiguous. If a project is in-flight, the session should resume automatically; there is nothing to confirm.

2. **High token usage at startup** — The Orchestrator reads a large amount of context when reconstructing project state at the start of a new session, resulting in a noticeably expensive init even before the user does any work.

## Notes

The `inject-state.sh` hook (`UserPromptSubmit`) is supposed to inject the active project's current stage and status into every prompt, and show a richer banner on session start. If the hook is firing correctly, the Orchestrator already has the active project and stage in context — it should not need to ask the user whether to resume, nor should it need to re-read large swathes of state from disk.

Likely causes:
- The Orchestrator agent instructions do not account for the case where `inject-state.sh` context is already present, so it falls back to a generic "new or resume?" flow.
- On session start, the Orchestrator may be loading the full mode YAML, templates, or other large artifacts to rebuild context instead of reading only `state.yaml`.

Relevant files: `helmsman/agents/orchestrator.md`, `helmsman/hooks/inject-state.sh`.
