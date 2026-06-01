# Project Dossier — {{project_name}}

> **Compiled by**: Helmsman Orchestrator (`/dossier`)
> **Compiled on**: {{date}}
> **Mode**: {{mode}}
> **Status**: {{status}} (in-flight | complete)
>
> This dossier is the single readable record of this project — what was built, why it was built that way,
> and everything a future maintainer needs to understand the code without reading the full history.

---

## TL;DR

> One paragraph: what this project did, why it existed, and the key architectural choice made.

{{tldr}}

---

## Problem & Goals

> Sourced from: `02-prd-clean/clean-prd.md`

**Problem**: {{problem_statement}}

**Goals achieved**:
- {{goal_1}}
- {{goal_2}}

**Explicitly out of scope**:
- {{out_of_scope_item_1}}

Full clean PRD: [`02-prd-clean/clean-prd.md`](02-prd-clean/clean-prd.md)

---

## Architecture Summary

> Sourced from: `04-tech-design/design.md`

{{architecture_summary_2_to_3_paragraphs}}

Full design: [`04-tech-design/design.md`](04-tech-design/design.md)

---

## Key Decisions (ADRs)

> Sourced from: `04-tech-design/adrs/`

| # | Decision | Status | Rationale (one line) |
|---|---|---|---|
| [ADR-001](04-tech-design/adrs/001-{{slug}}.md) | {{decision_title}} | Accepted | {{one_line_rationale}} |

---

## What Was Built

> Sourced from: `06-implementation/progress.md` and `state.yaml.repo_branches`

| Metric | Value |
|---|---|
| Tasks completed | {{complete}} / {{total}} |
| Tests added | {{tests_added}} |

**Linked PRs / MRs**: {{pr_links_or_none}}

### Code — by Repo
<!-- For single-repo projects: omit this subsection entirely. Instead, add Branch, Commits, and Files changed rows directly to the metrics table above. -->

> One entry per linked repo. Branch name from `state.yaml.repo_branches`.

<!-- Agent instruction: repeat the block between {{#each}} and {{/each}} once per repo in state.yaml.linked_repos.
     Replace {{repo_name}} with the repo name, {{branch_name}} with state.yaml.repo_branches[repo_name],
     and fill {{commit_count}} / {{files_changed}} from progress.md or git stats.
     Omit the {{#each}} and {{/each}} lines from the final dossier output. -->
{{#each linked_repos}}
#### `{{repo_name}}`

| Metric | Value |
|---|---|
| Branch | `{{branch_name}}` |
| Commits | {{commit_count}} |
| Files changed | {{files_changed}} |

{{/each}}

---

## Risks & Mitigations

> Sourced from: `04-tech-design/risks.md`

| Risk | Severity | Mitigation |
|---|---|---|
| {{risk}} | High / Med / Low | {{mitigation}} |

---

## Open Questions at Ship Time

> Items that were tracked but not resolved before launch.

- {{open_question_1}}

Full tracking: [`02-prd-clean/open-questions.md`](02-prd-clean/open-questions.md)

---

## Decision Timeline

> Sourced from: `decisions.log.md` (abbreviated)

| Date | Event |
|---|---|
| {{date}} | Project started |
| {{date}} | {{key_decision}} |
| {{date}} | Implementation complete |

Full log: [`decisions.log.md`](decisions.log.md)

---

## Future Work

> Items explicitly deferred. Good starting point for follow-up projects.

- {{deferred_item_1}} — see `02-prd-clean/out-of-scope.md`
- {{deferred_item_2}}

---

## Artifacts Index

| Artifact | Path | Description |
|---|---|---|
| Raw PRD | [`01-prd/input.md`](01-prd/input.md) | Original input, immutable |
| Clean PRD | [`02-prd-clean/clean-prd.md`](02-prd-clean/clean-prd.md) | Reviewed, implementable PRD |
| Codebase findings | [`03-discovery/codebase-findings.md`](03-discovery/codebase-findings.md) | Discovery output |
| Tech design | [`04-tech-design/design.md`](04-tech-design/design.md) | Architecture document |
| Task index | [`05-tasks/INDEX.md`](05-tasks/INDEX.md) | All tasks with status |
| Progress | [`06-implementation/progress.md`](06-implementation/progress.md) | Implementation log |
| Review reports | [`07-review/`](07-review/) | Per-task self-reviews |
| Decision log | [`decisions.log.md`](decisions.log.md) | Full decision history |
