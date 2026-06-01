---
name: start-project
description: >
  Create a new Helmsman project: scaffold the directory structure, save the PRD
  input, initialize state.yaml, and immediately kick off the PRD Reviewer agent.
arguments:
  - name: project-name
    description: Short identifier for the project (lowercase, hyphenated). Becomes the directory name under projects/.
    required: true
  - name: --mode
    description: "Pipeline mode. One of: feature, bugfix, refactor, spike, experiment, hotfix, chore. Default: feature."
    required: false
    default: feature
  - name: --repo
    description: Repo name from manifest.yaml to link. Can be specified multiple times. If omitted, user is prompted.
    required: false
---

# `/start-project` Command

## Purpose

Bootstrap a new project in the Helmsman workspace. This is the entry point for every new piece of work.

## Syntax

```
/start-project <project-name> [--mode feature] [--repo <repo-name>]
```

**Examples**:
```
/start-project payments-v2
/start-project payments-v2 --mode feature --repo payments-service
/start-project bug-sso-login --mode bugfix --repo web-app
/start-project prod-auth-down --mode hotfix --repo auth-service
```

---

## Step-by-Step Behavior

### Step 1 — Validate inputs

1. Check `<project-name>`:
   - Must be lowercase, hyphenated (no spaces, no uppercase, no special chars except `-`)
   - Must not already exist under `projects/`
   - If invalid: tell the user and stop
   - If already exists: ask "Project `<name>` already exists. Did you mean to `/switch` to it?"

2. Check `--mode`:
   - Valid modes: `feature`, `bugfix`, `refactor`, `spike`, `experiment`, `hotfix`, `chore`
   - Default if omitted: `feature`
   - Validate by checking `modes/<mode>.yaml` exists
   - If invalid mode: "Unknown mode `<mode>`. Available modes: feature, bugfix, refactor, spike, experiment, hotfix, chore."
   - If `--mode hotfix`: warn the developer that fast_track is active:
     "⚡ Hotfix mode: pipeline will auto-advance. Use /comment to pause if needed."

3. Check `--repo` value(s) against `manifest.yaml`:
   - If repo name not found in manifest: ask "Repo `<name>` is not in manifest.yaml. Would you like to add it first via `/helmsman-init`, or proceed without linking a repo?"
   - If `--repo` is omitted: after scaffolding, ask "Which repo(s) does this project touch? (Names from manifest.yaml, or 'none')"

### Step 2 — Collect PRD input

Prompt the user with the intake prompt appropriate for the mode:

| Mode | Prompt |
|---|---|
| `feature` | "Please provide the PRD for `<project-name>`. You can paste text, provide a file path, or describe the feature in plain text — the PRD Reviewer will help structure it." |
| `bugfix` | "Please describe the bug for `<project-name>`: steps to reproduce, expected vs. actual behavior, environment details. You can paste text or provide a file path." |
| `refactor` | "Please describe the refactor motivation for `<project-name>`: what is painful about the current code, what area it affects, and why now. You can paste text or provide a file path." |
| `spike` | "Please state the question or uncertainty driving this spike for `<project-name>`. What decision is blocked until this is answered?" |
| `experiment` | "Please describe the hypothesis for `<project-name>`: what you believe, why, and how you will measure whether you are right." |
| `hotfix` | "Please describe the production incident for `<project-name>`: what is broken, what impact it is having, and what you know so far." |
| `chore` | "Please describe the chore for `<project-name>`: what needs to be done and why (e.g., bump dependency X to fix CVE-Y, update CI config for new runner)." |

Wait for input. Accept any non-empty text or a valid file path.

If a file path is given: read the file and use its content as input.

### Step 3 — Scaffold project directory

Create `projects/<project-name>/` with the following structure, derived from `modes/<mode>.yaml`:

- `state.yaml` — initialized with dynamic stage list (see Orchestrator scaffolding section)
- `CLAUDE.md` — from `templates/project-claude.template.md`
- `decisions.log.md` — from `templates/decisions.log.template.md`
- One directory per stage in `modes/<mode>.yaml`, named by stage ID
  - Add `adrs/` subdirectory to any stage whose `skill` contains `design` or `tech-design`
  - Add `task-notes/` subdirectory to any stage with `agent: implementer`
- Within the first stage directory: write `input.md` with the intake input

**Example — `feature` mode:**
```
projects/<project-name>/
├── state.yaml
├── CLAUDE.md
├── decisions.log.md
├── 01-prd/
│   └── input.md
├── 02-prd-clean/
├── 03-discovery/
├── 04-tech-design/
│   └── adrs/
├── 05-tasks/
├── 06-implementation/
│   └── task-notes/
├── 07-review/
├── 08-pre-launch/
└── 09-launch/
```

**Example — `bugfix` mode:**
```
projects/<project-name>/
├── state.yaml
├── CLAUDE.md
├── decisions.log.md
├── 01-bug-intake/
│   └── input.md
├── 02-reproduce/
├── 03-fix-plan/
├── 04-implementation/
│   └── task-notes/
├── 05-review/
└── 06-launch/
```

**Example — `hotfix` mode:**
```
projects/<project-name>/
├── state.yaml
├── CLAUDE.md
├── decisions.log.md
├── 01-intake/
│   └── input.md
├── 02-fix/
│   └── task-notes/
├── 03-review/
└── 04-deploy/
```

**`<stage_order[0]>/input.md`**: Write the intake input verbatim. Prepend a header:
```markdown
# <Mode> Intake — <project-name>
> Saved verbatim on <date>. This file is immutable — do not edit.

---

<user's intake text>
```

**`state.yaml`**: Initialize using the Orchestrator's project scaffolding logic (see `agents/orchestrator.md`). Key fields:
- `project: <project-name>`
- `mode: <mode>`
- `fast_track: <from modes/<mode>.yaml>`
- `stage_order: [<stage IDs in order from modes/<mode>.yaml>]`
- `created_at: <current ISO 8601 timestamp>`
- `linked_repos: [<repo-names>]`
- `current_stage: <stage_order[0]>` (first stage — intake)
- `stages` dict: one entry per stage, each with `agent`, `skill`, `gates`, `status`, `started_at`, `approved_at`, `gate_results` populated from mode YAML
- `stages[stage_order[0]].status: complete` (intake handled inline)
- All other stages: `status: pending`

**`CLAUDE.md`**: Initialize from `templates/project-claude.template.md`. Fill:
- Project name, mode, linked repos, created date
- Scope summary: leave as `[To be filled after PRD Review]`
- Current stage: `<stage_order[1]>`

**`decisions.log.md`**: Initialize from `templates/decisions.log.template.md`. Write first entry:
```markdown
## <date> — Project started

Mode: <mode>{{if fast_track: " (⚡ fast-track)"}} | Linked repos: <repos> | Created by: user

Intake input saved to <stage_order[0]>/input.md.
```

### Step 4 — Update state.yaml to stage 02

Update `state.yaml`:
- `current_stage: <stage_order[1]>` (the second stage — first is intake)
- `stages[stage_order[0]].status: complete` (intake handled inline)
- `stages[stage_order[0]].approved_at: <current timestamp>`
- `stages[stage_order[1]].status: in-progress`
- `stages[stage_order[1]].started_at: <current timestamp>`
- Append to `history`:
  ```yaml
  - at: "<timestamp>"
    action: advanced
    from_stage: "<stage_order[0]>"
    to_stage: "<stage_order[1]>"
    note: "Intake input saved; advancing to <stages[stage_order[1]].label>"
  ```

### Step 5 — Invoke first agent

Read `stages[stage_order[1]].agent` and `stages[stage_order[1]].skill` from `state.yaml`.

**If `agent` is null:** The Orchestrator handles this stage directly — prompt the user for any required information.

**If `agent` is a name:** Construct context and invoke that sub-agent:
- `<stage_order[0]>/input.md` (intake artifact)
- If `skill` is non-null: `skills/<skill>/SKILL.md` and `skills/<skill>/INSTRUCTIONS.md`
- `memory/CLAUDE.md` (global memory)
- `memory/repos/<repo>.md` for each linked repo (if exists)
- `projects/<project-name>/CLAUDE.md`

### Step 6 — Confirm to user

After invocation, report:

> **Project `<project-name>` created** (`<mode>` mode[if fast_track: ", ⚡ fast-track"], linked to: `<repos>`).
>
> **Stage 1 (<stages[stage_order[0]].label>)**: ✅ Complete — intake saved to `<stage_order[0]>/input.md`
> **Stage 2 (<stages[stage_order[1]].label>)**: 🔄 In progress — <agent name or "Orchestrator"> running
>
> The <agent> will produce artifacts in `<stage_order[1]>/`.
>
> Review the output and run `/approve` to advance, or `/comment "<feedback>"` to request changes.
[if fast_track:]
> ⚡ **Fast-track active**: stages will auto-advance after agent completion. Use `/comment` to pause.

---

## State Changes

| File | What changes |
|---|---|
| `projects/<name>/state.yaml` | Created with dynamic stage list from mode YAML; stage 1 complete, stage 2 in-progress |
| `projects/<name>/CLAUDE.md` | Created from template |
| `projects/<name>/decisions.log.md` | Created; first entry written |
| `projects/<name>/<stage_order[0]>/input.md` | Created with intake input |
| `projects/<name>/<stage_order[1]>/*.md` | Created by first agent (or Orchestrator if agent is null) |

---

## Error Cases

| Situation | Response |
|---|---|
| Project name already exists | Ask if user meant `/switch` |
| No manifest.yaml found | "Run `/helmsman-init` first to set up the workspace." |
| Repo not in manifest | Prompt to add or proceed without linking |
| No PRD provided (empty input) | "Please provide PRD content — paste text or give a file path." |
| Unknown mode | "Unknown mode `<mode>`. Available modes: feature, bugfix, refactor, spike, experiment, hotfix, chore." |
| `modes/<mode>.yaml` missing | "Mode `<mode>` is registered but its configuration file is missing. Please check `modes/<mode>.yaml` exists." |
