# Changelog

All notable changes to Helmsman are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

_No unreleased changes._

---

## [1.4.0] — 2026-05-25

### Added — v1.M4: Hooks, Quality Gates, Final Polish

**Phase 1: Gate Configuration System** ✅

- `templates/state.yaml.example` — added `gate_config` block: `strictness` field (`strict | balanced | lenient`) and `gate_overrides[]` array for per-gate severity overrides; expanded `gates_overridden` from a stub comment into a full append-only audit log schema with `override_type`, `original_severity`, `at`, and `by` fields
- `docs/SCHEMAS.md` — documented `gate_config` object, `gate_config.gate_overrides[]` entry, `gates_overridden[]` audit log entry; extended Gate IDs section with `skip` severity, strictness levels, and precedence rule (per-gate overrides beat project strictness)
- `commands/override-gate.md` — new `/override-gate` command with four modes: `--severity` (permanent per-gate config), `--bypass` (one-time advance bypass), `--remove` (revert to mode default), `--list` (read-only view); `--strictness` shorthand for project-level changes; full audit trail to `decisions.log.md`; `gate_bypass_pending` transient flag consumed by `/advance`
- `commands/advance.md` — gate check refactored into two steps: Step 2 (resolve effective severities: consume bypasses → apply `gate_overrides` → apply `strictness` → apply `fast_track`) and Step 3 (run checklist with effective severities); hard gate failure message now includes `/override-gate --bypass` suggestion; `decisions.log.md` entry now records bypasses, skips, and non-default strictness; Error Cases table updated
- `plugin.json` / `.claude-plugin/plugin.json` — registered `./commands/override-gate.md`

**Phase 2: Hooks Implementation** ✅

- `hooks/lib.sh` — shared library for all hooks: `find_workspace` (env → walk-up from script dir → walk-up from cwd), `active_state_file` (most recently modified `state.yaml`), `yaml_field` / `stage_status` / `stage_label` (pure-bash YAML readers, no external deps)
- `hooks/inject-state.sh` — `UserPromptSubmit` hook: detects session start via `/tmp/helmsman-session-<id>` marker; prints rich welcome banner (project, mode, stage, status, next action) on first prompt; compact one-liner on subsequent prompts; degrades gracefully without `jq`
- `hooks/pre-push-guard.sh` — `PreToolUse(Bash)` hook: intercepts `git push` commands (skips `--dry-run`); checks that the pre-launch stage is `complete` in `state.yaml`; exits 2 with actionable message if not; fails open (exit 0) when `jq` absent; respects `HELMSMAN_SKIP_PUSH_GUARD=1` escape hatch
- `hooks/stop-log.sh` — `Stop` hook: appends session-end marker (stage, status, session ID, transcript path) to `decisions.log.md`; cleans up session marker so next session gets fresh banner
- `docs/HOOKS.md` — complete reference: overview table, quick setup with copy-paste settings.json, per-hook details (events, block behavior, env vars, bypass), shared lib API, workspace discovery order, per-scope settings placement, manual test commands, troubleshooting section
- `commands/helmsman-init.md` — added Step 6 (hook installation wizard): describes each hook, offers global vs. workspace scope, merges into `settings.json` without overwriting existing entries, reports in final summary; updated Idempotency and State Changes tables; step numbers shifted (old 6→8, old 7→9)

**Phase 3: Skill Marketplace Structure** ✅

- `docs/SKILL_MARKETPLACE.md` — full marketplace reference: override pattern (augment/replace/patch modes, `gates.yaml` for gate additions), community skills structure and `community/` prefix, skill resolution order (workspace full-replace → workspace override → community → plugin default), publishing conventions and checklist, single-team and public sharing workflows
- `templates/skill-override.template.md` — annotated override template with frontmatter (`target_skill`, `override_mode`, `description`, `author`, `helmsman_min_version`), all three mode annotations, and inline `gates.yaml` guidance
- `community-skills/README.md` — community skills index and quick-add instructions
- `community-skills/example-strict-code-review/SKILL.md` — metadata with gate declarations (`no_critical_issues` hard, `strict_threat_model_complete` hard, `strict_secrets_scan_pass` hard, `strict_deps_reviewed` soft)
- `community-skills/example-strict-code-review/INSTRUCTIONS.md` — 7-step agent instructions: standard quality review, threat model check (auth/authz/input validation/output encoding/rate-limiting/data exposure), secrets scan (pattern matching for common prefixes), dependency review (CVEs, abandonment, license), verdict logic
- `community-skills/example-strict-code-review/checklists/strict-review-gate-checklist.md` — four gate checks with exact pass conditions and actionable fail messages
- `community-skills/example-strict-code-review/templates/strict-review-report.template.md` — review report template with all required sections (verdict, issues table, threat model, secrets scan, dependency review, test coverage)
- `agents/orchestrator.md` — added "Skill Resolution" section before "Context to Pass Each Sub-Agent": 6-step resolution algorithm with priority order, override mode handling, `gates.yaml` merge, community skill loading, fallback + warning
- `plugin.json` / `.claude-plugin/plugin.json` — added `communitySkillsDir` and `skillOverrideDir` fields

**Phase 4: Status & Dashboard Polish** ✅

- `commands/status.md` — fully rewritten: new bordered layout with header row (project, mode, created, repos, Jira, branch), pipeline table with ▶️/✅/⏳/⏸/🔁 icons and date column, current-stage detail block (agent, skill, started, approved), gate status block with icons (✅/🚫/⚠️/⏭/🔓) and severity column; `--gates` flag for verbose gate output with check description and suggestion; `--history N` flag for timestamped action log; `--overrides` flag for gate_config and audit log view; propagation warning banner; implementation loop task progress block; rich multi-project dashboard with Attention Needed section for blocked projects; full error cases table
- `commands/projects.md` — new `/projects` command: one-line-per-project table (index, project, mode, stage, status icon, suggested next action); default hides completed projects with count; `--all` to show completed; `--blocked` for gate-failed + stale propagation only; `--mode` filter with multi-value OR; summary line (total/active/blocked/complete); Action column with context-aware suggestions; graceful handling of unreadable state files
- `plugin.json` / `.claude-plugin/plugin.json` — registered `./commands/projects.md`

**Phase 5: Performance Audit** ✅

- `docs/PERFORMANCE.md` — context size audit: per-stage baseline token estimates (~9,000–10,000 fixed overhead before artifacts), worst-case cumulative analysis (Stage 07 code review at ~29,500 tokens), six identified bloat sources (B1–B6: decisions.log in full, state.yaml history growth, design artifacts at late stages, orchestrator for lightweight commands, all repo memory regardless of target_repo, impl loop accumulation), three applied mitigations (M1 context budget rules, M2 history trimming, M3 template trimming), before/after benchmarks (46–63% reduction), remaining concerns and future recommendations (prompt caching, per-stage context profiles, artifact excerpting)
- `agents/orchestrator.md` — added "Context Budget" section: per-item rules (always/conditionally pass), per-stage prior-artifact table (which files to pass into each stage), read-only command rule (skip artifact loading for status/projects/dossier), `decisions.log.md` last-5-entries rule, `design.md` H2-headings-only rule for Stage 06+, `state.yaml` trimmed-to-current-stage rule, lazy `history[]` archiving trigger at 25 entries; updated "Context to Pass Each Sub-Agent" table to reference the budget rules

### Changed

- `state.yaml` schema: `gate_config` object added (top-level); `gates_overridden` formalised as an append-only audit log with `override_type`, `original_severity`, `at`, `by` fields; `stages[].gate_bypass_pending` transient flag added (consumed by `/advance`)
- `agents/orchestrator.md`: Skill Resolution section added (4-tier priority chain); Context Budget section added with per-stage artifact rules, decisions.log last-5 rule, trimmed state.yaml rule, lazy history archiving; Context to Pass table updated to reference budget
- `commands/advance.md`: gate check split into Step 2 (severity resolution: bypass → gate_overrides → strictness → fast_track) and Step 3 (checklist execution); step numbers renumbered; failure messages include `/override-gate --bypass` hint
- `commands/status.md`: fully rewritten with bordered layout, ▶️/✅/⏳/⏸/🔁 pipeline icons, gate icons (✅/🚫/⚠️/⏭/🔓), `--gates`/`--history`/`--overrides` flags, propagation banner, implementation loop task block, rich multi-project dashboard with Attention Needed section
- `commands/helmsman-init.md`: added Step 6 (hook installation), steps renumbered; updated Idempotency and State Changes tables; final summary banner updated
- `README.md`: rewritten as v1.4.0 complete vision; added Quality Gates, Lifecycle Hooks, Skill Marketplace, Performance sections; full commands table; documentation index
- `plugin.json` / `.claude-plugin/plugin.json`: version bumped to `1.4.0`; registered `override-gate` and `projects` commands; added `communitySkillsDir` and `skillOverrideDir` fields

---

## [1.3.0] — 2026-05-24

### Added — v1.M3: Multi-Repo Projects & Memory Learning Loop

**Feature A: Multi-Repo Project Support**

- `templates/state.yaml.example` — added `repo_branches` mapping (repo name → branch); one entry per linked repo, populated at `/start-project`, never empty
- `templates/manifest.yaml.example` — clarified `default_branch_pattern` applies per-repo for multi-repo projects
- `templates/task.template.md` — added `## Target Repo` section; required for multi-repo projects, optional with single-repo fallback
- `docs/SCHEMAS.md` — documented `repo_branches` field and `target_repo` task field with type, required status, and lifecycle notes
- `agents/implementer.md` — multi-repo awareness: reads `target_repo`, navigates to correct repo path, checks `state.yaml.repo_branches` for expected branch, creates branch from default if absent, reports BLOCKED if on wrong branch; two new `❌` guard rules
- `skills/implementation/INSTRUCTIONS.md` — updated Inputs and Step 0 for `target_repo` resolution, `git status` dirty check, `repo_branches` lookup, three-condition branch logic
- `skills/task-breakdown/INSTRUCTIONS.md` — updated Inputs (added `manifest.yaml`), Step 3 (cross-repo dependency + wave ordering), Step 5 (`target_repo` paragraph), and quality checklist (3 new checks)
- `templates/dossier.template.md` — "What Was Built" section now groups code metrics by repo; per-repo subsection with branch, commits, files-changed; single-repo collapse guidance
- `commands/dossier.md` — Step 2 references `repo_branches`; Step 3 has per-repo `git -C` instructions, fallback for pre-multi-repo projects, and `linked_repos`/`repo_branches` cross-reference

**Feature B: Memory Distillation Loop**

- `commands/distill-memory.md` — new `/distill-memory` command: 6-step single-project distillation (collect artifacts → analyze signals → build proposals → one-at-a-time approval with edit loop → write approved with tier routing and section-creation fallback → suggest pattern mining); `--patterns` mode adds cross-project pattern mining: scans all completed projects, detects signals with 2-project minimum, one-at-a-time approval, writes to `memory/patterns/`, updates `memory/CLAUDE.md` Cross-Project Learnings
- `templates/pattern.template.md` — new pattern file template with metadata block, Observed In table, What to Do, Counter-indicators, Notes
- `agents/orchestrator.md` — Post-Launch Routing section added: `/distill-memory` routing + proactive suggestion on Stage 09 approval and `/dossier` on complete projects; `/distill-memory` added to Step 3 command routing
- `commands/helmsman-init.md` — scaffolds `memory/patterns/` directory; updated Step 3 tree, idempotency rules, State Changes table, and Step 7 summary
- `plugin.json` — registered `./commands/distill-memory.md`
- `.claude-plugin/plugin.json` — registered `./commands/distill-memory.md`; removed duplicate `snapshots.md` entry
- `README.md` — added "Updating" section with git pull + `/reload-plugins` instructions

### Changed

- `state.yaml` schema: `repo_branches` object added (top-level, alongside `linked_repos`)
- Task file format: `## Target Repo` section added; agents default to sole linked repo when absent
- Dossier "What Was Built" restructured: overall metrics table + per-repo code subsections
- `memory/CLAUDE.md` template: `## Cross-Project Learnings` section populated by pattern mining
- `plugin.json` version bumped to `1.3.0`

### Fixed

- `.claude-plugin/plugin.json` had a duplicate `./commands/snapshots.md` entry — removed

### Out of Scope (deferred)

- Hooks (automated gate enforcement) → v1.M4
- MCP integrations (Jira, Slack, GitHub) → v1.M4
- Jump-back propagation auto-merge → v1.M4

---

## [1.1.0] — 2026-05-23

### Added — v1.M1: Multi-Mode Support

**Mode definitions** (`modes/`)
- `modes/feature.yaml` — formalizes existing 9-stage pipeline as structured config
- `modes/bugfix.yaml` — 6-stage pipeline: intake → reproduce → fix-plan → implement → review → launch
- `modes/refactor.yaml` — 7-stage pipeline: intake → current-state → target-design → migration-plan → implement → review → launch
- `modes/spike.yaml` — 5-stage pipeline: question → investigation → findings → recommendation → close (no code)
- `modes/experiment.yaml` — 6-stage pipeline: hypothesis → design → implement → results → decision → close
- `modes/hotfix.yaml` — 4-stage pipeline with `fast_track: true`: intake → fix → review → deploy
- `modes/chore.yaml` — 4-stage pipeline with lenient gates: intake → implement → review → close

**New skills** (`skills/`)
- `skills/bugfix/` — reproduce & diagnose + fix-plan skills with checklists and templates
- `skills/refactor/` — current-state + target-design skills with checklists and templates
- `skills/spike/` — investigation + findings + recommendation skills
- `skills/experiment/` — design + results skills with decision gates
- `skills/hotfix/` — emergency fix skill with fast_track-aware checklist
- `skills/chore/` — reduced review checklist skill

**New templates** (14 new files in `templates/`)
- bugfix: `bug-report`, `root-cause`, `fix-plan`
- refactor: `motivation`, `current-state`, `target-design`
- spike: `question`, `recommendation`
- experiment: `hypothesis`, `experiment-design`, `results`, `decision`
- hotfix: `incident`
- chore: `chore-description`

**Updated components**
- `agents/orchestrator.md` — dynamic mode-based routing (replaces hardcoded feature-mode table); `fast_track` auto-advance logic
- `commands/start-project.md` — accepts all 7 modes; dynamic directory scaffolding from mode YAML; fast_track warning
- `commands/advance.md` — dynamic gate checklist loading; `fast_track` gate downgrade behavior
- `commands/status.md` — shows mode name and fast_track indicator; stage labels from `state.yaml`
- `docs/SCHEMAS.md` — documents new `fast_track`, `stage_order` fields and per-stage `agent`/`skill`/`gates` fields
- `plugin.json` / `.claude-plugin/plugin.json` — registers `modes/` directory; version bumped to 1.1.0

**New documentation**
- `docs/MODE_ARCHITECTURE.md` — full architecture design for multi-mode support
- `docs/CHOOSING_A_MODE.md` — decision guide: which mode for which situation
- `docs/modes/bugfix.md` through `docs/modes/chore.md` — per-mode reference docs

### Changed

- `state.yaml` schema: `stages` dict is now dynamic (keyed by mode-defined IDs); `stage_order` array added; per-stage `label`, `agent`, `skill`, `gates` fields added; `fast_track` top-level field added
- Existing `feature` mode projects remain fully compatible (no migration required)

### Out of Scope (deferred)

- Jump-back / propagation → v1.M2
- Multi-repo → v1.M3
- Hooks → v1.M4

---

## [0.1.0] — 2026-05-22

### Added — MVP Release

**Plugin scaffolding**
- `plugin.json` — Claude Code plugin manifest declaring agents, commands, skills, workspace paths
- `README.md` — installation guide, quickstart, stage table, MVP limitations section
- `.gitignore` — excludes live project data (`projects/`, `memory/repos/`) from version control

**Workspace schemas**
- `templates/manifest.yaml.example` — annotated workspace registry with 3 sample repos
- `templates/state.yaml.example` — mid-flight project example showing all stage states and gate results
- `docs/SCHEMAS.md` — full field documentation for both files including gate ID catalog and status flow

**Artifact templates** (17 files in `templates/`)
- PRD stage: `prd-clean`, `assumptions`, `open-questions`, `out-of-scope`, `risks`
- Tech design stage: `tech-design`, `alternatives`, `adr`
- Task stage: `task-index`, `task`
- Implementation stage: `progress`
- Review stage: `self-review`
- Project artifacts: `dossier`, `decisions.log`
- Memory: `global-claude`, `repo-claude`, `project-claude`

**Sub-agents** (6 files in `agents/`)
- `orchestrator.md` — central coordinator with routing table, context discipline, gate enforcement
- `prd-reviewer.md` — skeptical senior engineer, 3-pass process, 6 failure modes
- `researcher.md` — investigative engineer, codebase-first then external, traceable findings
- `architect.md` — dual-hat: tech designer (Stage 04) + task planner (Stage 05)
- `implementer.md` — disciplined coder, TDD-first, 4-status reporting protocol
- `reviewer.md` — picky senior reviewer, 5-step process, 4-level severity model

**Skills** (5 skills × 5 files = 25 files in `skills/`)
- `prd-review/` — 7-step instructions, 7 hard + 4 soft gates, payments example
- `tech-design/` — 8-step instructions, 14-section requirement, excerpt example
- `task-breakdown/` — decomposition guide, sizing rules, full task example
- `implementation/` — pre-flight checks, TDD process, status reporting
- `code-review/` — 5-step review, security checklist, verdict consistency rules

**Slash commands** (7 files in `commands/`)
- `/helmsman-init` — idempotent setup wizard, repo registration, memory import
- `/start-project` — project bootstrap with inline PRD collection, directory scaffolding
- `/status` — read-only pipeline view, task progress, compact multi-project table
- `/advance` — gate check + next-stage agent invocation, impl loop handling
- `/approve` — stage and per-artifact approval, inline note capture
- `/comment` — targeted feedback with `--on` artifact flag, agent re-invocation
- `/dossier` — fresh compilation from source artifacts, in-flight and complete modes

**Documentation**
- `docs/WALKTHROUGH.md` — 8-part end-to-end tutorial covering all workflows, 15-item verification checklist
- `docs/SCHEMAS.md` — schema reference for manifest.yaml and state.yaml
- `CONTRIBUTING.md` — guide for skill variants, agent improvements, new commands
- `CHANGELOG.md` — this file

### MVP Scope

This release supports one developer running a `feature`-mode project end-to-end.

### Known Limitations (deferred to v1)

- **Single mode**: only `feature` mode; `bugfix`, `refactor`, `spike`, `experiment`, `hotfix`, `chore` are v1
- **No jump-back propagation**: `/jump-back` and `/propagate` are v1
- **No hooks**: automated gate enforcement hooks (`session-start.sh`, `pre-advance.sh`) are v1
- **No MCP integrations**: Jira, Slack, GitHub sync are v1
- **Single-repo projects**: multi-repo support is v1
- **No memory distillation**: automatic post-project learning loop is v1
- **Stages 03, 08, 09**: minimal skill guidance in MVP; detailed skills are v1
