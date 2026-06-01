# ISSUE-007: No user-testing / acceptance stage after implementation

**Type:** Behaviour
**Component:** modes
**Command / Trigger:** `/advance` from the implementation stage

## Observed

After the implementation stage completes there is no dedicated stage where the
developer can run and manually test the changes, observe real behaviour, and
record findings. The pipeline moves directly from implementation to code review
(or completion), bypassing any structured acceptance-testing step.

As a result, there is nowhere in the dossier to capture:
- Observations made while exercising the feature end-to-end
- Test data used during manual validation
- Edge-case behaviour noticed at runtime
- A sign-off note from the developer confirming the feature works as intended

This gap means manual-testing evidence is either lost or scattered across chat
history rather than being part of the permanent project record.

## Notes

A new `user-testing` (or `acceptance`) stage should be inserted between
`implementation` and `code-review` (or `review`) in applicable modes (feature,
bugfix, hotfix at minimum). The stage would:

1. Prompt the developer to run the implementation and test it manually.
2. Provide a structured template for recording: test scenarios, inputs/outputs,
   observations, and a pass/fail verdict per scenario.
3. Produce a **Testing Report** artifact stored in the project dossier (e.g.
   `projects/<name>/testing-report.md`).
4. Gate `code-review` on this artifact existing and having at least one
   completed scenario — preventing the reviewer from seeing un-exercised code.

Related files to update if implemented:
- `helmsman/modes/feature.yaml`, `bugfix.yaml`, `hotfix.yaml` — add the new stage
- `helmsman/skills/` — new `user-testing/` skill dir with `SKILL.md`,
  `INSTRUCTIONS.md`, a scenario template, and a real example
- `helmsman/templates/` — `testing-report.md` template
- `helmsman/docs/SCHEMAS.md` — document the new stage ID and gates
- `helmsman/docs/MODE_ARCHITECTURE.md` — update stage lists
