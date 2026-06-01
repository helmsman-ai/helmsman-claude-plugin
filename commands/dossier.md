---
name: dossier
description: >
  Compile a fresh project dossier from all approved artifacts. Produces
  projects/<name>/dossier.md — the single readable record of the project for
  future maintainers. Can be run at any stage; sections not yet completed are
  marked as in-progress.
arguments:
  - name: project-name
    description: Optional. Project to compile dossier for. Defaults to the active project.
    required: false
---

# `/dossier` Command

## Purpose

Produce `dossier.md` — the handoff artifact that any developer can read six months later to understand what was built, why, and how.

The dossier is always compiled fresh from the source artifacts. Running `/dossier` multiple times is safe and idempotent — it overwrites the previous version with the current state of all artifacts.

## Syntax

```
/dossier
/dossier <project-name>
```

**Examples**:
```
/dossier
/dossier payments-v2
```

---

## Step-by-Step Behavior

### Step 1 — Identify project

- If `<project-name>` given: use that project
- If omitted: use the active project from `state.yaml`
- If no active project: "No active project. Run `/dossier <project-name>` or use `/switch`."

Read `state.yaml` to understand which stages are complete.

### Step 2 — Collect artifacts by stage

For each stage, check if the artifacts exist and are approved:

| Stage | Artifacts to pull | Required for dossier? |
|---|---|---|
| 01 PRD Intake | `01-prd/input.md` | Link only (immutable) |
| 02 PRD Clean | `02-prd-clean/clean-prd.md` | Yes — embed summary |
| 03 Discovery | `03-discovery/codebase-findings.md` | Link only |
| 04 Tech Design | `04-tech-design/design.md`, `adrs/` | Yes — embed summary + ADR table |
| 05 Tasks | `05-tasks/INDEX.md` | Link only |
| 06 Implementation | `06-implementation/progress.md`, `state.yaml.repo_branches` | Yes — task count, per-repo commits and branches |
| 07 Review | `07-review/` | Link only |
| 08 Pre-Launch | (stub in MVP) | Link only |
| 09 Launch | (stub in MVP) | Link only |
| All | `decisions.log.md` | Yes — abbreviated timeline |

### Step 3 — Compile each dossier section

Use `templates/dossier.template.md` as the structure. Fill each section from the source files:

**TL;DR** — write a 2–3 sentence summary based on:
- The problem from `clean-prd.md` §1
- The key architectural decision from `design.md` §1 or the first ADR

**Problem & Goals** — pull directly from `clean-prd.md`:
- Problem statement (§1)
- Goals list (§2)
- Top non-goals (§3, first 3)

**Architecture Summary** — synthesize from `design.md`:
- Overview paragraph (§1)
- Key components (§4, brief)
- API contracts (§6, endpoint list only — no full schema)

**Key Decisions (ADRs)** — table from `04-tech-design/adrs/`:
- One row per ADR: number, decision title, status, one-line rationale

**What Was Built** — from `progress.md` and `state.yaml.repo_branches`:
- Tasks complete / total (overall)
- Test count (from task notes if available)
- Source of repo list: iterate over `state.yaml.linked_repos` (the authoritative list of repos for this project); for each repo name look up its branch in `state.yaml.repo_branches[repo_name]`.
- Per-repo subsection for each entry in `state.yaml.linked_repos`:
  - Branch name: read from `state.yaml.repo_branches[repo_name]`
  - Commit count: count commits on that branch in that repo directory (`git -C <repo_path> rev-list --count helmsman/<project>...<default_branch>` or summarize from `progress.md` notes)
  - Files changed: count from `progress.md` task notes or `git -C <repo_path> diff --stat <default_branch>...helmsman/<project>`
- If only one repo is linked: collapse to a single table (no per-repo subsections needed)
- If `state.yaml.repo_branches` is absent (project predates multi-repo support) or per-repo commit data is unavailable: emit `—` for `Commits` and `Files changed` in each repo row. Do not block or omit the repo row.

**Risks & Mitigations** — from `04-tech-design/risks.md`:
- Top 3 risks with severity and mitigation (one line each)

**Open Questions at Ship Time** — from `02-prd-clean/open-questions.md`:
- Any questions still in "Blocking" or "Non-blocking" sections (not yet resolved)

**Decision Timeline** — from `decisions.log.md`:
- Pull every `## <date> —` heading and its first line
- Maximum 10 entries; if more, show first 3 and last 3 with "..." in between

**Future Work** — from `02-prd-clean/out-of-scope.md`:
- "Deferred Items" section (first 5 items)

**Artifacts Index** — generate from directory listing:
- One row per artifact file that exists, with relative path link

### Step 4 — Handle incomplete stages

For each section where the source stage is not yet `complete`:

```markdown
## Architecture Summary

> ⏳ **In progress** — Stage 04 (Tech Design) not yet complete.
> This section will be populated when Stage 04 is approved.
```

Do not leave blank sections. Either fill from available data or mark as in-progress.

### Step 5 — Write dossier.md

Write the compiled document to `projects/<name>/dossier.md`.

Overwrite any previous version.

Add a header with compilation metadata:
```markdown
# Project Dossier — <project-name>

> Compiled by Helmsman on <date>
> Stage at time of compilation: <current-stage>
> Status: <in-flight | complete>
>
> This document is auto-compiled from project artifacts.
> Source of truth is always the individual artifact files.
```

### Step 6 — Confirm to user

> 📋 **Dossier compiled**: `projects/<name>/dossier.md`
>
> Sections populated:
> - ✅ TL;DR
> - ✅ Problem & Goals (from Stage 02)
> - ✅ Architecture Summary (from Stage 04)
> - ✅ Key Decisions — 2 ADRs
> - ✅ What Was Built — 6/6 tasks complete, 2 repos (payments-service: 8 commits, web-app: 3 commits)
> - ⏳ Future Work (Stage 09 not yet complete)
>
> The dossier is a snapshot. Re-run `/dossier` after each stage to keep it current.

---

## Design Notes

**Fresh compile every time**: the dossier does not cache or track which artifacts have changed. It always re-reads all source files. This ensures it is never stale.

**Links vs. embeds**: the dossier uses relative links for large artifacts (full PRD, full design, task files) and inline summaries for key content (TL;DR, ADR table, decision timeline). This keeps the dossier readable without duplicating everything.

**In-flight vs. complete**: the dossier is useful at any stage — not just at project end. A developer handing off mid-project can share `dossier.md` to give context to the next person.

---

## State Changes

| File | What changes |
|---|---|
| `projects/<name>/dossier.md` | Created or overwritten with fresh compilation |

No `state.yaml` changes. No `decisions.log.md` entry (dossier compilation is not a decision).

---

## Error Cases

| Situation | Response |
|---|---|
| No active project | "No active project. Run `/dossier <project-name>`." |
| Project exists but has no completed stages | Compile with all sections marked ⏳ in-progress |
| Source artifact file is missing | Skip that section; note "(source file not found)" in the dossier section |
| `dossier.md` already exists | Overwrite silently — this is expected and safe |
