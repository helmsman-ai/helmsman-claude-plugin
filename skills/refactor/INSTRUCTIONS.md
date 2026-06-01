# Refactor Skill — Detailed Instructions

## Stage 02: Current State

### Input
- `01-intake/motivation.md` — why this refactor is happening
- `01-intake/scope.md` — what is in and out of scope
- Linked repo(s)

### Process

**Step 1 — Understand the scope**
Read `motivation.md` and `scope.md`. What area of the codebase is being
refactored? What problem is it solving?

**Step 2 — Map the current state**
Investigate the area thoroughly:
- What does it do? (responsibilities)
- How is it structured? (files, classes, modules, their relationships)
- What are the coupling points? (what depends on this, what does it depend on)
- What is painful about it? (why the refactor is needed — be specific)

Write `02-current-state/current-state.md` — include:
- Architecture diagram or description of current structure
- List of responsibilities (what this code does)
- List of pain points (specific, traceable — file + line where applicable)
- Known test coverage gaps

Write `02-current-state/impacted-files.md`:
- Every file that will likely change
- Every file that depends on the area being refactored (consumers)

**Step 3 — Quality check**
- [ ] Pain points are specific (not "the code is messy" but "AuthService has 8 unrelated responsibilities and 400 lines — see lines 120–280 for the unrelated billing logic")
- [ ] Impacted files list includes consumers, not just the files being changed
- [ ] No `{{placeholder}}` tokens

## Stage 03: Target Design

### Input
- `02-current-state/current-state.md`
- `02-current-state/impacted-files.md`
- `01-intake/motivation.md`
- Repo memory (conventions, patterns)

### Process

**Step 1 — Design the target structure**
What should the code look like when the refactor is complete?
- New file/module structure
- Responsibility boundaries (what does each unit do?)
- Interface definitions (how do modules communicate?)
- What gets deleted, what gets moved, what gets renamed

Write `03-target-design/target-design.md`.

**Step 2 — Record decisions as ADRs**
For each significant structural decision (splitting a class, introducing a new abstraction, changing an interface), write an ADR in `03-target-design/adrs/`.

**Step 3 — Verify atomicity**
The target design must be achievable in small, independently-mergeable steps.
If any step requires touching more than 5 files simultaneously, that is a
signal the migration plan (Stage 04) will need to be more granular.

**Step 4 — Quality check**
- [ ] Target design specifies new file structure explicitly
- [ ] Each module in the target has a clearly stated single responsibility
- [ ] Consumer impact is addressed (what changes for callers?)
- [ ] At least one ADR for significant structural decisions
