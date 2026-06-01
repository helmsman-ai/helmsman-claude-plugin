# Helmsman Documentation

> New here? Start with **[Getting Started](#getting-started)**.
> Blocked by a gate? Go to **[Gate Catalog](GATES.md)**.
> Something broken? Check **[Troubleshooting](TROUBLESHOOTING.md)**.

---

## Getting Started

| Doc | What it covers |
|---|---|
| [../README.md](../README.md) | Plugin overview, install, quickstart, command reference |
| [walkthroughs/WALKTHROUGH.md](walkthroughs/WALKTHROUGH.md) | End-to-end feature project tutorial (~30 min) |
| [CHOOSING_A_MODE.md](CHOOSING_A_MODE.md) | Decision tree: which mode fits your situation |

---

## Concepts

Understand how Helmsman works before diving into modes or commands.

| Doc | What it covers |
|---|---|
| [CONCEPTS.md](CONCEPTS.md) | Projects vs repos, stage lifecycle, agents vs skills, gates, dossier, decisions log |
| [PROPAGATION.md](PROPAGATION.md) | Jump-back, snapshots, forward propagation, Change Impact Reports |

---

## Modes

Each mode is a different pipeline for a different type of work.

| Mode | Doc | When to use |
|---|---|---|
| `feature` | [modes/feature.md](modes/feature.md) | New feature or significant new behavior |
| `bugfix` | [modes/bugfix.md](modes/bugfix.md) | Confirmed bug, non-urgent |
| `refactor` | [modes/refactor.md](modes/refactor.md) | Restructure code, behavior unchanged |
| `spike` | [modes/spike.md](modes/spike.md) | Answer a technical question |
| `experiment` | [modes/experiment.md](modes/experiment.md) | Test a hypothesis, then ship/discard |
| `hotfix` | [modes/hotfix.md](modes/hotfix.md) | Production emergency ⚡ auto-advances |
| `chore` | [modes/chore.md](modes/chore.md) | Dependency bump, config, tooling |

Not sure which mode to pick? → [CHOOSING_A_MODE.md](CHOOSING_A_MODE.md)

---

## Commands & Agents

| Doc | What it covers |
|---|---|
| [AGENTS.md](AGENTS.md) | All 6 agents — role, artifacts, how to interact |
| [../commands/start-project.md](../commands/start-project.md) | `/start-project` — create a new project |
| [../commands/status.md](../commands/status.md) | `/status` — full pipeline view |
| [../commands/projects.md](../commands/projects.md) | `/projects` — dashboard of all projects |
| [../commands/advance.md](../commands/advance.md) | `/advance` — run gates, invoke next agent |
| [../commands/approve.md](../commands/approve.md) | `/approve` — accept current stage artifacts |
| [../commands/comment.md](../commands/comment.md) | `/comment` — request changes from active agent |
| [../commands/override-gate.md](../commands/override-gate.md) | `/override-gate` — change gate severity or bypass |
| [../commands/jump-back.md](../commands/jump-back.md) | `/jump-back` — revert to an earlier stage |
| [../commands/propagate.md](../commands/propagate.md) | `/propagate` — re-run stale downstream stages |
| [../commands/snapshots.md](../commands/snapshots.md) | `/snapshots` — view and restore snapshots |
| [../commands/dossier.md](../commands/dossier.md) | `/dossier` — compile final artifact record |
| [../commands/distill-memory.md](../commands/distill-memory.md) | `/distill-memory` — extract learnings to team memory |
| [../commands/helmsman-init.md](../commands/helmsman-init.md) | `/helmsman-init` — first-run workspace setup |

---

## Configuration & Reference

| Doc | What it covers |
|---|---|
| [SCHEMAS.md](SCHEMAS.md) | `manifest.yaml` and `state.yaml` field reference |
| [GATES.md](GATES.md) | Gate catalog — every gate ID, what it checks, severity per mode |
| [SKILL_MARKETPLACE.md](SKILL_MARKETPLACE.md) | Skill overrides, community skills, publishing guide |
| [HOOKS.md](HOOKS.md) | Lifecycle hooks — install, configure, troubleshoot |
| [PERFORMANCE.md](PERFORMANCE.md) | Context size audit and optimization rules |

---

## Troubleshooting & Walkthroughs

| Doc | What it covers |
|---|---|
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Common failure modes grouped by symptom, with fixes |
| [walkthroughs/WALKTHROUGH.md](walkthroughs/WALKTHROUGH.md) | End-to-end feature project walkthrough |
| [walkthroughs/PROPAGATION_WALKTHROUGH.md](walkthroughs/PROPAGATION_WALKTHROUGH.md) | Jump-back and propagation walkthrough |
