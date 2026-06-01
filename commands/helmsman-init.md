---
name: helmsman-init
description: >
  First-run setup wizard. Creates the workspace directory structure, writes
  manifest.yaml, scaffolds memory/ and templates/ directories, registers
  the first repository, and optionally initializes git and recommends the
  GitHub connector. Safe to re-run — will not overwrite existing data.
arguments:
  - name: --workspace
    description: Path to use as the Helmsman workspace root. Defaults to ~/helmsman-workspace.
    required: false
    default: "~/helmsman-workspace"
---

# `/helmsman-init` Command

## Purpose

Bootstrap a brand-new Helmsman workspace in one guided session. Run once after installing the plugin. Safe to re-run — it skips anything that already exists.

## Syntax

```
/helmsman-init
/helmsman-init --workspace ~/my-workspace
```

---

## Step-by-Step Behavior

### Step 1 — Welcome and explain

Print exactly the following block. Do not add any prose before or after it.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HELMSMAN SETUP WIZARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Welcome! This wizard will set up your Helmsman workspace.

Helmsman keeps all project artifacts, memory, and state in a single
workspace directory — separate from your code repositories.

This takes about 2 minutes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2 — Confirm workspace path

Ask:

> Where should Helmsman create your workspace?
> Default: `~/helmsman-workspace`
> (Press Enter to accept, or type a different path)

Accept the user's input. Expand `~` to the full home directory path.

If the directory already exists and contains a `manifest.yaml`:

> Workspace already exists at `<path>`. Helmsman will skip existing files and only add what's missing.
> Continue? (yes/no)

If the user says no: exit gracefully.

### Step 3 — Create workspace directory structure

Do not narrate internal steps (e.g., "finding the plugin directory"). Only report outcomes to the user.

Create the following if they don't already exist:

```
<workspace>/
├── manifest.yaml             (from template — only if not exists)
├── memory/
│   ├── CLAUDE.md             (from global-claude.template.md — only if not exists)
│   ├── repos/                (empty directory — only if not exists)
│   └── patterns/             (empty — populated by /distill-memory --patterns)
├── projects/                 (empty directory — only if not exists)
└── templates/                (copy all templates from plugin — only if not exists)
```

For `templates/`: use a shell copy command so file contents never enter the model's context:
```bash
cp -rn <plugin-dir>/templates/ <workspace>/templates/
```
(`-n` = no-clobber, preserves idempotency.)

For `memory/CLAUDE.md`: write the following content directly (do not read the template file):

```markdown
# Helmsman Global Memory

## Workflow Preferences

[To be filled as you use Helmsman]

## Communication Style

- Be direct. List findings, then recommendation.

## Cross-Project Learnings

[To be filled over time]

## Repos in This Workspace

[To be filled in the next step]
```

Report each directory created:

> ✅ Created `<workspace>/memory/`
> ✅ Created `<workspace>/projects/`
> ✅ Copied templates to `<workspace>/templates/`

### Step 4 — Initialize manifest.yaml

If `manifest.yaml` already exists: skip this step and say so.

If not: write a minimal `manifest.yaml`:

```yaml
version: 1

defaults:
  default_mode: feature
  reviewer_strictness: balanced
  auto_push: false
  require_tests: true
  default_branch_pattern: "helmsman/{project}"

repos: []
```

Report: `✅ Created manifest.yaml`

### Step 5 — Register first repository

Ask:

> Let's register your first repository so Helmsman knows what codebases you work with.
>
> What is the path to your repository? (e.g., ~/code/my-app)

If user provides a path:

1. Expand `~` to full path
2. Check if the directory exists — if not: warn but allow (path might be relative or future)
3. Ask: "What's a short name for this repo? (e.g., `my-app`)"
4. Ask: "What's the primary language? (e.g., typescript, python, go, java)"
5. Ask: "What's in the tech stack? (comma-separated, e.g., react, nextjs, postgres)"
6. Ask: "Is there a conventions file in the repo? (e.g., CONVENTIONS.md, docs/CONVENTIONS.md — or press Enter to skip)"

Then append to `manifest.yaml`:

```yaml
repos:
  - name: <short-name>
    path: <expanded-path>
    primary_language: <language>
    tech_stack: [<items>]
    conventions_file: <path-or-null>
    memory_file: memory/repos/<short-name>.md
```

Copy the repo memory template via shell (do not read the file):
```bash
cp -n <plugin-dir>/templates/repo-claude.template.md <workspace>/memory/repos/<short-name>.md
```

Ask: "Register another repo? (yes/no)"
Repeat until user says no.

If user skips repo registration entirely (presses Enter or says "skip"):

> No repos registered. You can add them later by editing `manifest.yaml` directly, or by running `/helmsman-init` again.

### Step 6 — Optional: initialize git and recommend the GitHub connector

This step only runs if at least one repo was registered in Step 5. Skip it entirely otherwise.

**6a — Offer `git init` for non-git repos.**

For each registered repo whose path exists on disk, check whether it is already a git repository:

```bash
git -C <repo-path> rev-parse --is-inside-work-tree 2>/dev/null
```

- If the command succeeds (prints `true`): the repo is already under git — skip it silently.
- If the path does not exist on disk: skip it silently (it was registered as a future/placeholder path).
- If the command fails (not a git repo): offer to initialize one.

For each repo that is **not** yet a git repository, ask:

> `<repo-name>` (`<repo-path>`) is not a git repository yet.
> Helmsman's pre-push guard and structured commits work best with git.
> Initialize a git repository here now? (yes/no)

If **yes**:

```bash
git -C <repo-path> init
```

Report: `✅ Initialized git repository in <repo-path>`

Do **not** create commits, add files, or change branches — only `git init`. Leave staging and the first commit to the user.

If **no**: skip that repo and continue.

**6b — Recommend the GitHub connector.**

After handling git for all repos, print the following recommendation once (regardless of how many repos were initialized):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  RECOMMENDED: GitHub connector
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Helmsman's later stages (pre-launch, launch) work best when Claude
can open pull requests, read issues, and check CI status directly.

The GitHub connector gives Claude Code that access. To add it:

  • Run /mcp inside Claude Code and follow the GitHub connector setup, or
  • See https://docs.claude.com/en/docs/claude-code/mcp for connector setup.

This is optional — Helmsman works without it, falling back to the
`gh` CLI and local git when the connector is absent.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

This is informational only — do not attempt to install or configure the connector automatically.

### Step 7 — Optional: install lifecycle hooks

Ask:

> Helmsman includes three Claude Code hooks that keep your session in sync with your project:
>
> - **inject-state** — injects active project status before every prompt
> - **pre-push-guard** — blocks `git push` until pre-launch is approved
> - **stop-log** — logs session end to `decisions.log.md` automatically
>
> Would you like to install these hooks? (yes/no/describe)
> ("describe" shows what each hook does before you decide)

If the user says **describe**: print the following, then ask again.

| Hook script | Event | What it does |
|---|---|---|
| `hooks/inject-state.sh` | `UserPromptSubmit` | Injects active project stage + status as context before every prompt. Shows a welcome banner at session start. |
| `hooks/pre-push-guard.sh` | `PreToolUse` (Bash) | Blocks `git push` if the active project's pre-launch stage is not yet approved. |
| `hooks/stop-log.sh` | `Stop` | Appends a session-end marker to the project's `decisions.log.md`. |

If the user says **yes**:

1. Determine the plugin directory (the directory containing this `helmsman-init.md` file, going up two levels from `commands/`).
2. Make hook scripts executable:
   ```bash
   chmod +x <plugin-dir>/hooks/inject-state.sh
   chmod +x <plugin-dir>/hooks/pre-push-guard.sh
   chmod +x <plugin-dir>/hooks/stop-log.sh
   ```
3. Determine the settings file to write. Ask:
   > Install hooks globally (`~/.claude/settings.json`) or for this workspace only (`<workspace>/.claude/settings.json`)?
   > Global is recommended for most setups. (global/workspace)

4. Read the target `settings.json`. If it does not exist, start with `{}`.
5. Merge the following hook entries (do not overwrite other existing hooks):
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {"hooks": [{"type": "command", "command": "<plugin-dir>/hooks/inject-state.sh"}]}
       ],
       "PreToolUse": [
         {"matcher": "Bash", "hooks": [{"type": "command", "command": "<plugin-dir>/hooks/pre-push-guard.sh"}]}
       ],
       "Stop": [
         {"hooks": [{"type": "command", "command": "<plugin-dir>/hooks/stop-log.sh"}]}
       ]
     }
   }
   ```
6. Write the merged result back to `settings.json`.
7. Report:
   > ✅ Hooks installed in `<settings-file>`
   > Set `HELMSMAN_WORKSPACE=<workspace>` in your shell profile for reliable workspace discovery.
   > See `docs/HOOKS.md` for troubleshooting.

If the user says **no**: skip. Mention they can install hooks later by re-running `/helmsman-init`.

### Step 8 — Optional: import existing CLAUDE.md

Ask:

> Do you have an existing CLAUDE.md (global or project) with workflow preferences you'd like to import into Helmsman's global memory? (yes/no)

If yes: ask for the file path. Read the file. Append its content to `memory/CLAUDE.md` under a new section:

```markdown
## Imported from existing CLAUDE.md (<date>)

<content>
```

If no: skip.

### Step 9 — Final summary and next steps

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HELMSMAN SETUP COMPLETE ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Workspace:  <workspace-path>
Repos:      <repo-names or "none registered">
Git:        <"initialized: <repo-names>" | "already tracked" | "skipped">
Hooks:      <"installed (global)" | "installed (workspace)" | "skipped">
GitHub:     <"connector recommended — see /mcp" | "n/a">



What's ready:
  ✅ manifest.yaml
  ✅ memory/CLAUDE.md (global memory)
  ✅ memory/repos/ (per-repo memory files)
  ✅ memory/patterns/ (cross-project pattern library — populated by /distill-memory --patterns)
  ✅ projects/ (empty — ready for your first project)
  ✅ templates/ (all artifact templates)
  <✅ or ⏭>  hooks/ (inject-state, pre-push-guard, stop-log)

Next steps:
  1. Start your first project:
       /start-project <project-name>

  2. Check workspace status anytime:
       /status

  3. Add more repos to manifest.yaml or re-run /helmsman-init

  4. If hooks were skipped, install them later with:
       /helmsman-init  (re-run — existing files are preserved)

See docs/HOOKS.md for hook configuration details.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Idempotency Rules

`/helmsman-init` is safe to re-run. For each step:

| Item                     | If already exists                                   |
| ------------------------ | --------------------------------------------------- |
| Workspace directory      | Skip creation, continue                             |
| `manifest.yaml`          | Skip — never overwrite                              |
| `memory/CLAUDE.md`       | Skip — never overwrite                              |
| `memory/repos/<name>.md` | Skip for existing repos; create for new ones        |
| `memory/patterns/`       | Skip if exists; never delete existing pattern files |
| `templates/` files       | Skip individual files that exist; copy missing ones |
| `projects/`              | Skip — never touch existing projects                |
| Git repo (`.git/`)       | Skip if already a git repo; offer `git init` only for untracked repos |
| Hooks in `settings.json` | Append only — never remove existing hook entries    |

---

## State Changes

| File                                 | What changes                               |
| ------------------------------------ | ------------------------------------------ |
| `<workspace>/manifest.yaml`          | Created if not exists                      |
| `<workspace>/memory/CLAUDE.md`       | Created if not exists                      |
| `<workspace>/memory/repos/<name>.md` | Created per repo registered                |
| `<workspace>/memory/patterns/`       | Created as empty directory                 |
| `<workspace>/templates/*`            | Copied from plugin templates if not exists |
| `<repo-path>/.git/`                  | Created via `git init` per repo if user accepts in Step 6a (never auto-commits) |
| `~/.claude/settings.json` or `<workspace>/.claude/settings.json` | Hook entries appended if user accepts Step 7 |

---

## Error Cases

| Situation               | Response                                                                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Path is not writable    | "Cannot create directory at `<path>`. Check permissions."                                                           |
| Repo path doesn't exist | Warn: "Directory `<path>` not found. Registering anyway — update the path in manifest.yaml before using this repo." |
| User aborts mid-wizard  | "Setup incomplete. Re-run `/helmsman-init` to continue — existing files will be preserved."                         |
