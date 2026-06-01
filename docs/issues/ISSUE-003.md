# ISSUE-003: PRD Reviewer agent does not start as a background task in `/start-project`

**Type:** Bug
**Component:** commands / start-project
**Command / Trigger:** `/start-project <name>` after PRD intake stage completes

## Observed

After running `/start-project`, the PRD Reviewer agent was not launched as a background task. The stage either stalled or the agent was never dispatched.

## Notes

The expected behaviour is that once the PRD intake stage is complete, the Orchestrator hands off to the `prd-reviewer` agent automatically (likely as a background sub-agent task). This did not happen — the reviewer was never invoked.

Could be caused by:
- Missing or incorrect agent dispatch instruction in `commands/start-project.md`
- The Orchestrator not recognising the stage transition that should trigger the reviewer
- Background task spawning not being wired up in the command or orchestrator agent instructions

## Resolution

**Status:** resolved
**Fixed in:** `commands/comment.md:Step 3`
**Summary:** Replaced hardcoded feature-mode stage→agent routing table with dynamic lookup: `stages[current_stage].agent` from `state.yaml`, consistent with the plugin's dynamic routing principle. (Background dispatch wiring for `/start-project` and other commands is tracked separately as Fix A.)
