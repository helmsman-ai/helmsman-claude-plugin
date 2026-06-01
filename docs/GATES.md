# Helmsman Gate Catalog

Gates are quality checks that run when you call `/advance`. Each gate inspects
the current stage's artifacts and either blocks (`hard`) or warns (`soft`).

**When `/advance` is blocked:** Read the gate ID in the error message, find it
in the table below to understand what's missing, then fix it or override it with
`/override-gate <id> --bypass --reason "<reason>"`.

---

## Gate Severities

| Severity | Behavior |
|---|---|
| `hard` | Blocks `/advance` until the gate passes or is bypassed with a reason |
| `soft` | Warns but allows `/advance` to proceed |
| `skip` | Gate is omitted (set via `/override-gate <id> --severity skip`) |

Project-level strictness in `manifest.yaml` (`strict` / `balanced` / `lenient`) can
promote all soft gates to hard or demote all hard gates to soft. See
[CONCEPTS.md](CONCEPTS.md) for details.

---

## Feature Mode Gates

**Mode:** `feature` | **Default strictness:** balanced

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 02-prd-clean | `has_goals` | Clean PRD has a Goals section with at least one stated goal | hard |
| 02-prd-clean | `has_acceptance_criteria` | Clean PRD has explicit, testable acceptance criteria | hard |
| 02-prd-clean | `has_user_stories` | Clean PRD has at least one user story | soft |
| 02-prd-clean | `has_constraints` | Clean PRD documents known constraints | soft |
| 03-discovery | `has_decision_makers` | Discovery identifies at least one stakeholder or decision-maker | soft |
| 04-tech-design | `has_2_alternatives` | Design doc presents at least two evaluated alternatives | hard |
| 04-tech-design | `has_risks_section` | Design doc has a Risks section | hard |
| 04-tech-design | `has_adrs` | At least one ADR is recorded in `adrs/` | soft |
| 05-tasks | `each_task_has_acceptance_criteria` | Every task file has explicit acceptance criteria | hard |
| 05-tasks | `dependency_graph_valid` | No circular dependencies in task ordering | hard |
| 06-implementation | `tests_pass` | All tests pass in the target repo | hard |
| 06-implementation | `lint_clean` | Linter reports no errors | soft |
| 07-review | `no_critical_issues` | Review report has no severity-critical issues | hard |
| 08-pre-launch | `pre_mortem_complete` | Pre-mortem has been documented and signed off | hard |
| 08-pre-launch | `rollback_plan_exists` | A rollback procedure is documented | hard |

---

## Bugfix Mode Gates

**Mode:** `bugfix` | **Default strictness:** balanced

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 01-bug-intake | `has_reproduction_steps` | Bug report includes step-by-step reproduction instructions | hard |
| 01-bug-intake | `has_expected_vs_actual` | Bug report documents expected vs actual behavior | hard |
| 01-bug-intake | `has_affected_version` | Bug report identifies the affected version/environment | soft |
| 02-reproduce | `has_root_cause` | Root cause analysis names the specific file/function/line | hard |
| 02-reproduce | `has_impacted_code_paths` | Research identifies all code paths affected by the bug | soft |
| 03-fix-plan | `has_fix_approach` | Fix plan describes the specific code change to be made | hard |
| 03-fix-plan | `has_regression_risk` | Fix plan documents regression risk | soft |
| 04-implementation | `tests_pass` | All tests pass | hard |
| 04-implementation | `lint_clean` | Linter reports no errors | soft |
| 05-review | `no_critical_issues` | Review report has no severity-critical issues | hard |
| 06-launch | `rollback_plan_exists` | A rollback procedure is documented | hard |

---

## Refactor Mode Gates

**Mode:** `refactor` | **Default strictness:** balanced

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 01-intake | `has_motivation` | Intake documents why this refactor is needed | hard |
| 01-intake | `has_scope` | Intake defines the scope of what will and won't change | hard |
| 02-current-state | `has_pain_points` | Current state analysis identifies specific pain points | hard |
| 02-current-state | `has_impacted_files` | Research lists files that will be touched | soft |
| 03-target-design | `has_target_design` | Target design describes the desired end state | hard |
| 03-target-design | `has_adrs` | At least one ADR documents the design approach | soft |
| 04-migration-plan | `each_task_has_acceptance_criteria` | Every migration task has acceptance criteria | hard |
| 04-migration-plan | `dependency_graph_valid` | No circular dependencies in migration task ordering | hard |
| 05-implementation | `tests_pass` | All tests pass | hard |
| 05-implementation | `lint_clean` | Linter reports no errors | soft |
| 06-review | `no_critical_issues` | Review report has no severity-critical issues | hard |
| 07-launch | `rollback_plan_exists` | A rollback procedure is documented | hard |

---

## Spike Mode Gates

**Mode:** `spike` | **Default strictness:** balanced | **Tests required:** no

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 01-question | `has_question` | A specific, answerable question is stated | hard |
| 01-question | `has_success_criteria` | Criteria for knowing when the question is answered | hard |
| 01-question | `has_time_box` | A time limit is set for the investigation | soft |
| 02-investigation | `has_codebase_findings` | Investigation documents what was found in the codebase | soft |
| 02-investigation | `has_external_research` | Investigation documents relevant external findings | soft |
| 03-findings | `has_findings` | Findings document summarizes what was learned | hard |
| 03-findings | `has_options` | Findings present at least one option or approach | soft |
| 04-recommendation | `has_decision` | A clear recommendation or decision is stated | hard |

---

## Experiment Mode Gates

**Mode:** `experiment` | **Default strictness:** balanced

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 01-hypothesis | `has_hypothesis` | A testable hypothesis is stated | hard |
| 01-hypothesis | `has_success_metrics` | Measurable success/failure criteria are defined | hard |
| 01-hypothesis | `has_time_box` | A time limit is set for the experiment | hard |
| 02-design | `has_experiment_design` | Experiment design describes what will be built and measured | hard |
| 03-implementation | `tests_pass` | All tests pass | hard |
| 03-implementation | `lint_clean` | Linter reports no errors | soft |
| 04-results | `has_results` | Results document records actual measurements | hard |
| 04-results | `has_metrics_comparison` | Results compare actual metrics to success criteria | soft |
| 05-decision | `has_ship_decision` | A clear ship / discard / pivot decision is recorded | hard |

---

## Hotfix Mode Gates

**Mode:** `hotfix` | **Default strictness:** lenient | **Fast-track:** yes (auto-advances; hard gates downgraded to warnings)

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 01-intake | `has_incident_description` | Incident is described with symptoms and impact | hard* |
| 02-fix | `tests_pass` | All tests pass | hard* |
| 03-review | `no_critical_issues` | Review report has no severity-critical issues | hard* |

*In fast-track mode, hard gates are automatically downgraded to warnings — they will not block the pipeline.

---

## Chore Mode Gates

**Mode:** `chore` | **Default strictness:** lenient | **Tests required:** no

| Stage | Gate ID | What it checks | Default severity |
|---|---|---|---|
| 01-intake | `has_chore_description` | Chore description explains what is being changed and why | hard |
| 02-implementation | `lint_clean` | Linter reports no errors | soft |
| 03-review | `no_critical_issues` | Review report has no severity-critical issues | hard |

---

## Overriding Gates

```
# Change severity for this project
/override-gate has_adrs --stage 04-tech-design --severity soft --reason "team policy: ADRs optional for small features"

# Bypass a gate once (doesn't change severity)
/override-gate has_2_alternatives --stage 04-tech-design --bypass --reason "trivial config change, only one approach makes sense"

# Review all current overrides
/override-gate --list
```
