# Helmsman Performance Audit

This document records the findings of the v1.M4 context size audit and the mitigations applied.

---

## Methodology

Context size is measured in approximate tokens. 1 word ≈ 1.3 tokens; 1 line ≈ 8–12 words.
Token estimates are conservative (round up). Measurements are taken on plugin files as shipped; live project artifacts will grow beyond these baselines.

---

## Stage-by-Stage Baseline (Feature Mode, Empty Project)

The "fixed overhead" is what every sub-agent call loads before any project artifacts are included.

### Fixed overhead per agent call

| Component | Lines | Est. tokens | Notes |
|---|---|---|---|
| Orchestrator agent instructions | 422 | ~4,000 | Loaded for every Orchestrator call |
| Specialist agent instructions | 168–191 | ~1,600–1,800 | Only the invoked specialist |
| Skill INSTRUCTIONS.md | 50–181 | ~500–1,700 | Varies by stage |
| Skill SKILL.md | ~30 | ~300 | Metadata, gate list |
| `state.yaml` (empty project) | ~157 | ~1,000 | Grows with history[] |
| Global memory (`memory/CLAUDE.md`) | ~235 words | ~300 | Stable |
| Repo memory (`memory/repos/<name>.md`) | ~319 words | ~415 | Per linked repo |
| Project memory (`projects/<name>/CLAUDE.md`) | ~285 words | ~370 | Stable |
| **Total fixed overhead** | | **~9,000–10,000** | Before any artifacts |

### Per-stage artifact growth (feature mode, realistic project)

| Stage | Artifacts passed forward | Est. tokens added |
|---|---|---|
| 01 PRD Intake | Raw PRD text | 500–2,000 |
| 02 PRD Review | Clean PRD (~379 words template + content) | 1,500–4,000 |
| 03 Discovery | Research findings doc | 1,000–3,000 |
| 04 Tech Design | design.md + alternatives.md + risks.md + ADRs | 3,000–10,000 |
| 05 Task Breakdown | task-index.md + N task files | 2,000–8,000 (scales with task count) |
| 06 Implementation (per task) | Single task file + progress.md | 500–2,000 |
| 07 Code Review | diff + self-review + task file | 2,000–15,000 (scales with diff size) |
| 08 Pre-Launch | pre-mortem + rollback plan | 500–2,000 |

### Cumulative context at late stages (realistic worst case)

At Stage 07 (Code Review), if the orchestrator passes all prior artifacts:

| Item | Est. tokens |
|---|---|
| Fixed overhead | ~9,500 |
| PRD (clean) | 2,000 |
| Discovery doc | 2,000 |
| Tech design artifacts (3 files) | 6,000 |
| Task index + current task | 1,500 |
| Diff (medium PR, ~200 lines changed) | 3,000 |
| Self-review | 1,500 |
| `decisions.log.md` (full, 20+ entries) | 4,000 |
| **Total** | **~29,500** |

This is well within the 200K context window, but several items are **wasted tokens** — the reviewer agent has no use for the full PRD or all prior decisions.

---

## Identified Bloat Sources

### B1 — `decisions.log.md` passed in full

**Impact:** High. The log grows throughout the project. By Stage 07, it may contain 30+ entries (≈4,000 tokens), of which the sub-agent needs at most the last 3–5.

**Fix:** Pass only the last 5 entries as a "recent decisions" snippet. The full log remains in the file but is not included in the agent context.

### B2 — `state.yaml` history[] unbounded growth

**Impact:** Medium. Each stage transition and approval appends an entry. A 9-stage feature project generates 20–30 history entries. Most agents only need `current_stage` and `stages[current_stage]`.

**Fix:** When passing `state.yaml` to a sub-agent, pass a trimmed version: top-level fields + `stages[current_stage]` only. The full `state.yaml` is only needed for the Orchestrator itself.

### B3 — Tech Design artifacts passed to Stage 06 and beyond

**Impact:** Medium. The full `design.md` (can be 2,000–5,000 words) is passed to the Implementer for every task, even though the task file already contains the relevant acceptance criteria.

**Fix:** Pass `design.md` heading-only summary (H2 headings only, no body) to Stage 06+ agents. The task file is the primary input; the design doc is background.

### B4 — Orchestrator.md loaded for lightweight commands

**Impact:** Medium. `/status`, `/projects`, and `/dossier` trigger the Orchestrator agent, which loads the full 422-line orchestrator.md. These commands only need the routing section and state-reading logic.

**Fix:** Document a "lightweight read" flag in the orchestrator: for read-only commands, skip loading specialist agent files and prior-stage artifacts.

### B5 — All repo memory files loaded for single-repo stages

**Impact:** Low–Medium. In multi-repo projects, all repo memory files are loaded by default, even when the current task targets only one repo.

**Fix:** For stages with a specific `target_repo`, load only that repo's memory file.

### B6 — Implementation loop context accumulation

**Impact:** High (at scale). When the implementer processes task N, the Orchestrator may pass context from tasks 1 through N-1. For a 10-task project, this snowballs.

**Fix (already documented in implementer.md):** Pass the single task file + `progress.md` status summary only. No prior task artifacts. The progress.md file provides the required "what's done" context without re-passing artifacts.

---

## Mitigations Applied (v1.M4)

### M1 — Context budget rules in `agents/orchestrator.md`

Added a "Context Budget" section to `orchestrator.md` with explicit per-stage rules:

- `decisions.log.md`: pass last 5 entries only
- `state.yaml`: pass trimmed version to sub-agents (current stage only)
- `design.md`: pass heading summary only for Stages 06+
- `target_repo` awareness: load only relevant repo memory
- Read-only commands: skip artifact loading entirely

### M2 — `state.yaml` history trimming guidance

Added to `docs/SCHEMAS.md`: after 25 history entries, the Orchestrator should:
1. Archive entries 1–20 to `projects/<name>/history-archive.md`
2. Replace them in `state.yaml` with a single summary entry:
   ```yaml
   - at: "<timestamp>"
     action: history_archived
     note: "20 entries archived to history-archive.md"
   ```

This keeps `state.yaml` scannable without losing the audit trail.

### M3 — Template trimming

Removed placeholder comments from `templates/decisions.log.template.md` and `templates/dossier.template.md` that were inflating word count without adding value at runtime.

---

## Benchmarks: Before vs After

| Scenario | Before (est. tokens) | After (est. tokens) | Reduction |
|---|---|---|---|
| Stage 07 Code Review call | 29,500 | 16,000 | ~46% |
| Stage 06 Implementation (task 8 of 10) | 22,000 | 11,500 | ~48% |
| `/status` command | 9,500 | 3,500 | ~63% |

These are estimates based on the rule changes in M1. Actual savings will vary by project size.

---

## Remaining Concerns

| Issue | Severity | Status |
|---|---|---|
| Dossier compilation loads all artifacts | Low | Acceptable — `/dossier` is a one-off; context size is a non-issue |
| Large diffs at Stage 07 | Low | Cannot be trimmed without losing information; use `/comment` to split large PRs |
| Community skill INSTRUCTIONS.md can be any size | Low | Documented as author responsibility in `docs/SKILL_MARKETPLACE.md` |
| `memory/CLAUDE.md` grows unbounded | Low | Addressed by `/distill-memory` in v1.M3 |

---

## Recommendations for Future Releases

1. **Prompt caching** — Pass the orchestrator agent instructions and memory files as cached prefix blocks. They are stable across calls within a session and are prime cache candidates.
2. **Per-stage context profiles** — Define a `context_profile` in each mode YAML stage entry specifying exactly which prior-stage files to load.
3. **Artifact excerpting** — For very large artifacts (design docs > 3,000 words), the Orchestrator could generate a structured excerpt (key decisions, relevant sections) rather than the full file.
