# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Helmsman is a **Claude Code plugin** — there is no compiled code, build step, or test runner. Every artifact is a Markdown file, a YAML schema, or a bash hook. "Developing" here means editing agent personas, skill instructions, command definitions, mode pipelines, and templates so they read clearly to the Claude instances that execute them at runtime.

The plugin is consumed by end users who run it against a separate **Helmsman workspace** directory (containing `manifest.yaml`, `projects/`, `memory/`). That workspace is created at runtime by `/helmsman-init` and does **not** live in this repo — do not look for or create `projects/` or `state.yaml` here; they are runtime artifacts described by the `templates/*.example` files.

## How the Plugin Fits Together

`.claude-plugin/plugin.json` is the manifest that wires everything: it lists the agents, commands, skills, modes, hooks, and the community-skill / skill-override directories. **Any new agent, command, skill, or mode must be registered here or Claude Code won't load it.**

The runtime flow is an agent-driven SDLC pipeline:

1. **Modes** (`modes/*.yaml`) define an ordered list of `stages`. Each stage names an `agent`, a `skill`, and a list of `gates` with severities. `feature` is the full 9-stage pipeline; `bugfix`, `refactor`, `spike`, `experiment`, `hotfix`, `chore` are shorter variants. `fast_track: true` (hotfix) makes the pipeline auto-advance and downgrades hard gates to warnings.
2. **Orchestrator** (`agents/orchestrator.md`) is the only coordinator. It reads `state.yaml`, routes each stage to its specialist sub-agent, enforces gates, and is the **sole writer of `state.yaml` and `decisions.log.md`**. It never does domain work itself.
3. **Specialist agents** (`agents/prd-reviewer.md`, `researcher.md`, `architect.md`, `implementer.md`, `reviewer.md`) each own specific stages and load the matching skill.
4. **Skills** (`skills/<name>/`) carry the actual stage instructions. Routing is dynamic — driven entirely by the fields in `state.yaml`, never hardcoded in the orchestrator.

When tracing "what happens at stage X", read: the mode YAML (which agent/skill/gates) → that agent's `.md` → that skill's `SKILL.md` + `INSTRUCTIONS.md`.

## Skill Anatomy

Each `skills/<name>/` directory follows a fixed structure:

- `SKILL.md` — entry point with YAML frontmatter (`name`, `stage`, `agent`, `description`); a short "Quick Reference for the Agent" and a table of artifacts → output paths → gates.
- `INSTRUCTIONS.md` — the full step-by-step process the agent follows.
- `templates/` — artifact templates the agent fills in.
- `checklists/` — gate checklists (e.g. `*-gate-checklist.md`) used to evaluate whether a stage passes its gates.
- `examples/` — sample outputs.

**Skill variants** extend a base skill via frontmatter `extends: <base-skill>` and are named `<base-skill>-<variant>` (e.g. `tech-design-microservices`). End users can also drop a runtime `override.md` into a workspace skill directory to replace `SKILL.md` for one project — that override mechanism is workspace-side, not in this repo.

## Gates

Gates are quality checks evaluated at `/advance`. A gate has an `id` and a `severity`: `hard` (blocks advance), `soft` (warns), or `skip` (omitted). Gate IDs are referenced in three places that must stay in sync:

- the `gates:` list in the relevant `modes/*.yaml`
- the checklist file in the owning skill's `checklists/`
- the catalog table in `docs/GATES.md`

When you add or rename a gate, update all three. The full gate ID catalog and per-mode gate tables live in `docs/GATES.md`; the `state.yaml` / `manifest.yaml` schemas are in `docs/SCHEMAS.md`.

## Hooks

`hooks/*.sh` are pure bash (≥ 3.2) wired via `plugin.json`. `hooks/lib.sh` is the shared library — every hook sources it for workspace/state discovery. Conventions to preserve when editing:

- Hooks **fail open**: if `jq` is missing or no workspace is found, `exit 0` silently rather than break the user's session.
- `find_workspace` locates the workspace by walking up for `manifest.yaml` (or honoring `$HELMSMAN_WORKSPACE`).
- `inject-state.sh` (UserPromptSubmit) injects active-project context; `pre-push-guard.sh` (PreToolUse/Bash) blocks `git push` before the pre-launch stage and uses exit code `2` to block; `stop-log.sh` (Stop) logs.

## Commands

`commands/*.md` define the slash commands (`/start-project`, `/advance`, `/approve`, `/comment`, `/status`, `/override-gate`, `/jump-back`, `/propagate`, `/snapshots`, `/dossier`, `/distill-memory`, etc.). Each is a prompt the orchestrator follows. Approval is explicit: `/approve` accepts a stage but does **not** advance — the user then runs `/advance` to trigger the next stage's agent.

## Editing Conventions

- This is a documentation/specification codebase — clarity for the executing Claude is the product. Match the existing voice: imperative instructions, tables for structured data, explicit "What You Do NOT Do" sections in agents.
- Keep cross-references intact. The same concept (a gate ID, a stage ID, an artifact path) is often named in a mode YAML, a skill, a checklist, and a doc. Changing one means changing all.
- Stage IDs are zero-padded and ordered (`01-prd`, `02-prd-clean`, …, `09-launch`); artifact output paths embed the stage ID directory.
- `docs/` is the reference layer: `CONCEPTS.md`, `MODE_ARCHITECTURE.md`, `GATES.md`, `SCHEMAS.md`, `PROPAGATION.md`, `HOOKS.md`, `SKILL_MARKETPLACE.md`, `TROUBLESHOOTING.md`, plus per-mode docs in `docs/modes/`. Update the relevant doc when behavior changes.
- See `CONTRIBUTING.md` for the skill-variant authoring process.
