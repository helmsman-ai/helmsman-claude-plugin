# Hotfix Skill — Detailed Instructions

## Stage 02: Fix

### Input
- `01-intake/incident.md` — symptom, impact, any known cause
- Linked repo

### Process

**Step 1 — Understand the incident**
Read `incident.md`. What is broken? What is the impact? Is there a known
cause, or do you need to find it?

**Step 2 — Find the cause (if not known)**
This is a compressed version of bugfix mode's Stage 02. You do not write
a formal root-cause doc — but you must know the cause before writing the fix.
Spend no more than 15–20 minutes on this. If you cannot find the cause,
report `BLOCKED` with what you tried.

**Step 3 — Write the minimal fix**
- Change only what is necessary to stop the incident
- Do not refactor, rename, or improve adjacent code
- Add a comment referencing the incident ID if it helps future readers

**Step 4 — Write a test**
At minimum, one test that:
- Fails without the fix
- Passes with the fix
This is non-negotiable even in fast_track mode.

**Step 5 — Commit**
```
fix(<scope>): <what was fixed>

Incident: <incident ID from incident.md>
Root cause: <one sentence>
Tests: <N> added, all passing
```

**Step 6 — Write `02-fix/notes.md`**
- Root cause (even if informal)
- What was changed and why
- Any follow-up work needed (e.g., "this is a band-aid — proper fix is X")

### Output to Orchestrator

```
DONE

Fix summary: [one sentence]
Commit: [SHA]
Tests: [N] added, all passing

Follow-up needed: [yes/no + description if yes]
```
