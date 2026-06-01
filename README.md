# Helmsman

> *Guiding developers from idea to launch — one structured stage at a time.*

Helmsman is a **Claude Code-native plugin** that turns your workflow into a structured, agent-driven SDLC. You bring a PRD (or a bug report, or a vague idea). Helmsman guides you — through discovery, design, implementation, and review — producing not just code, but a complete **dossier** of artifacts that any developer can read to understand the why, what, and how.

Feature-complete. All seven pipeline modes, quality gates, lifecycle hooks, skill marketplace, and performance-tuned context loading.

---

## What It Does

```
You:         /start-project payments-v2 --mode feature
Helmsman:    Launches PRD Reviewer → produces clean PRD, assumptions, risks
You:         Review, comment, /approve
Helmsman:    Launches Researcher → codebase findings, stakeholder map, prior art
You:         /approve
Helmsman:    Launches Architect → tech design, alternatives, ADRs
You:         "I prefer approach B" → /approve
Helmsman:    Breaks work into atomic tasks
You:         /approve
Helmsman:    Implements task by task, each with a self-review pass
You:         Review each task, /approve
Helmsman:    Compiles dossier → projects/payments-v2/dossier.md
```

Each stage is gated: nothing advances until you approve. Every decision is logged. The final dossier is readable by future maintainers.

---

## Install

### Prerequisites

- Claude Code ≥ 1.0.0
- A directory to use as your Helmsman workspace (sibling to your repos)
- bash ≥ 3.2 (for lifecycle hooks — optional but recommended)

### Install from Marketplace

```bash
/plugin marketplace add helmsman-ai/helmsman-claude-plugin
/plugin install helmsman
```

### First-Run Setup

```
/helmsman-init
```

The wizard:
1. Creates your workspace directory with `manifest.yaml`, `memory/`, `projects/`, `templates/`
2. Registers your first repository
3. Optionally installs lifecycle hooks (`inject-state`, `pre-push-guard`, `stop-log`)
4. Optionally imports existing `CLAUDE.md` content as initial memory

> **Tip:** If commands don't appear after install, run `/reload-plugins`.

---

## Quickstart

```
# Start a project in any mode
/start-project my-feature --mode feature
/start-project login-crash --mode bugfix
/start-project redis-oom  --mode hotfix
/start-project ws-spike   --mode spike

# Core workflow
/status          # where you are — rich pipeline view
/approve         # accept current stage artifacts
/advance         # run gates, start next stage's agent
/comment "..."   # request changes without advancing

# Navigation
/projects        # dashboard of all projects (one line each)
/projects --blocked   # only projects needing attention

# Gate control
/override-gate has_adrs --stage 04-tech-design --severity hard --reason "team policy"
/override-gate has_2_alternatives --stage 04-tech-design --bypass --reason "trivial change"
/override-gate --list

# Recovery
/jump-back 02-prd-clean --reason "changed auth approach"
/propagate       # re-run stale downstream stages
/snapshots       # view/restore snapshots

# Completion
/dossier         # compile final artifact record
/distill-memory  # extract learnings to team memory
```

---

## Key Concepts

| Concept | Description |
|---|---|
| **Stage** | One phase of the SDLC (PRD Review, Discovery, Tech Design, etc.) |
| **Agent** | Specialist sub-agent that does the work for a stage |
| **Skill** | Instructions + templates the agent loads for a stage |
| **Gate** | Quality check that must pass before advancing (hard = block, soft = warn) |
| **Dossier** | Final compiled artifact: the complete readable record of a project |
| **state.yaml** | Source of truth for a project's current stage, gates, and history |
| **manifest.yaml** | Workspace registry of repos and global defaults |
| **gate_config** | Per-project gate severity overrides (strict / balanced / lenient) |
| **Skill override** | Workspace-local file that augments or replaces a plugin skill |
| **Community skill** | Third-party skill extending Helmsman without modifying the plugin |

---

## Project Structure (after init)

```
~/helmsman-workspace/
├── manifest.yaml               # repo registry + global defaults
├── memory/
│   ├── CLAUDE.md               # global workflow preferences
│   ├── repos/                  # per-repo conventions
│   └── patterns/               # cross-project learnings (from /distill-memory)
├── projects/
│   └── my-feature/
│       ├── state.yaml          # current stage, gate results, history
│       ├── CLAUDE.md           # project-scoped memory
│       ├── decisions.log.md    # append-only decision trail
│       ├── 01-prd/ … 09-launch/
│       └── dossier.md
├── community-skills/           # third-party / team skills
│   └── my-strict-review/
│       ├── SKILL.md
│       └── INSTRUCTIONS.md
├── .claude/
│   └── skills/                 # per-skill overrides (augment/replace/patch)
│       └── code-review/
│           └── override.md
└── templates/                  # artifact templates
```

---

## Modes

| Mode | When to use | Stages |
|---|---|---|
| `feature` | New feature or behavior | 9 |
| `bugfix` | Confirmed bug, non-urgent | 6 |
| `refactor` | Restructure code, behavior unchanged | 7 |
| `spike` | Answer a technical question | 5 |
| `experiment` | Test a hypothesis | 6 |
| `hotfix` | Emergency production fix ⚡ auto-advances | 4 |
| `chore` | Dependency / config / tooling | 4 |

See [docs/CHOOSING_A_MODE.md](docs/CHOOSING_A_MODE.md) for a decision guide.

---

## Commands

| Command | Description |
|---|---|
| `/helmsman-init` | First-run workspace setup wizard |
| `/start-project <name>` | Start a new project (prompts for PRD) |
| `/status [project]` | Full pipeline view; `--gates`, `--history`, `--overrides` flags |
| `/projects` | One-line dashboard of all projects; `--blocked`, `--mode` filters |
| `/advance` | Run gate check and invoke next stage's agent |
| `/approve` | Accept current stage artifacts |
| `/comment "<text>"` | Request changes from the active agent |
| `/override-gate` | Change gate severity or bypass once; `--list` to review |
| `/jump-back <stage>` | Revert to an earlier stage after a decision change |
| `/propagate` | Re-run stale downstream stages after a jump-back |
| `/snapshots` | View and restore stage snapshots |
| `/dossier` | Compile final artifact dossier |
| `/distill-memory` | Extract project learnings to team memory |

---

## Quality Gates

Gates enforce quality before advancing. Each gate has a severity:

- **hard** — blocks `/advance` until resolved (or bypassed with reason)
- **soft** — warns but allows advance
- **skip** — omitted entirely (set via `/override-gate`)

Project-level strictness can be changed: `strict` (all soft→hard), `balanced` (default), `lenient` (all hard→soft).

See [docs/SCHEMAS.md](docs/SCHEMAS.md) for the full gate ID catalog.

---

## Lifecycle Hooks

Three hooks wire Helmsman into Claude Code's session lifecycle:

| Hook | Event | What it does |
|---|---|---|
| `inject-state` | UserPromptSubmit | Injects active project status as context; shows welcome banner at session start |
| `pre-push-guard` | PreToolUse (Bash) | Blocks `git push` until pre-launch stage is approved |
| `stop-log` | Stop | Appends session-end marker to `decisions.log.md` |

Install during `/helmsman-init` or see [docs/HOOKS.md](docs/HOOKS.md).

---

## Skill Marketplace

Customize or extend any skill without touching the plugin:

- **Override** — put `.claude/skills/<skill>/override.md` in your workspace to augment, replace, or patch a built-in skill
- **Community skills** — drop a full skill in `community-skills/<name>/` and reference it with `skill: community/<name>` in your project
- **Publish** — share skills as a git repo (naming: `helmsman-skills-<theme>`)

See [docs/SKILL_MARKETPLACE.md](docs/SKILL_MARKETPLACE.md).

---

## Performance

Helmsman's context loading is tuned to minimize token usage:

- Sub-agents receive trimmed `state.yaml` (current stage only, not full history)
- `decisions.log.md` is passed as last-5-entries only
- `design.md` is passed as headings-only to Stage 06+
- Read-only commands skip artifact loading entirely
- `history[]` is lazily archived after 25 entries

See [docs/PERFORMANCE.md](docs/PERFORMANCE.md) for the full audit.

---

## Documentation

| Doc | Contents |
|---|---|
| [docs/SCHEMAS.md](docs/SCHEMAS.md) | `manifest.yaml` and `state.yaml` field reference |
| [docs/HOOKS.md](docs/HOOKS.md) | Hook installation, configuration, troubleshooting |
| [docs/SKILL_MARKETPLACE.md](docs/SKILL_MARKETPLACE.md) | Skill overrides, community skills, publishing guide |
| [docs/PERFORMANCE.md](docs/PERFORMANCE.md) | Context size audit and optimization rules |
| [docs/WALKTHROUGH.md](docs/WALKTHROUGH.md) | End-to-end tutorial |
| [docs/CHOOSING_A_MODE.md](docs/CHOOSING_A_MODE.md) | Mode selection guide |
| [docs/MODE_ARCHITECTURE.md](docs/MODE_ARCHITECTURE.md) | Mode system design |
| [docs/PROPAGATION.md](docs/PROPAGATION.md) | Jump-back and propagation system |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute skills, agents, commands |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Community skill packs, mode variants, and agent prompt improvements are all welcome.
