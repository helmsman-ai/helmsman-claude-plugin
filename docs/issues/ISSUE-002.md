# ISSUE-002: `/helmsman-init` opening message is unnecessarily verbose

**Type:** UX / Observation
**Component:** commands / helmsman-init
**Command / Trigger:** `/helmsman-init` in an empty directory

## Observed

The agent sent this message at the start of init:

> "The current directory /Users/alireza/dev/digikala/superapp-projects is empty — I'll set up the Helmsman workspace here.
>
> Now I'll create the workspace structure. First, let me find the Helmsman plugin directory."

## Notes

Two separate sentences that say roughly the same thing ("I'll set up", "I'll create the structure"). The second sentence also narrates an internal step (finding the plugin dir) that the user doesn't need to see. A single, shorter confirmation line would suffice — e.g.:

> "Setting up Helmsman workspace in /Users/.../superapp-projects…"

## Resolution

**Status:** resolved
**Fixed in:** `helmsman/commands/helmsman-init.md:Step 1`, `helmsman/commands/helmsman-init.md:Step 3`
**Summary:** Added "Print exactly the following block. Do not add any prose before or after it." to Step 1, and a constraint in Step 3 prohibiting narration of internal steps.
