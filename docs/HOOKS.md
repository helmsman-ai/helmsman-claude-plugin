# Helmsman Hooks

Helmsman ships three Claude Code lifecycle hooks that wire the pipeline into your session automatically — no manual state-checking required.

---

## Overview

| Hook script | Event | What it does |
|---|---|---|
| `hooks/inject-state.sh` | `UserPromptSubmit` | Injects active project stage + status as context before every prompt. Shows a welcome banner at session start. |
| `hooks/pre-push-guard.sh` | `PreToolUse` (Bash) | Blocks `git push` if the active project's pre-launch stage is not yet approved. |
| `hooks/stop-log.sh` | `Stop` | Appends a session-end marker to the project's `decisions.log.md`. |

Hooks are **opt-in**. They are standard Claude Code hooks — bash scripts wired through `.claude/settings.json`. No hooks run unless you configure them.

---

## Quick Setup

Run `/helmsman-init` — it offers to install hooks automatically (Step 7). For manual setup, see the per-hook instructions below.

### One-shot installation (copy-paste)

Edit or create `<your-workspace>/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<HELMSMAN_PLUGIN_DIR>/hooks/inject-state.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "<HELMSMAN_PLUGIN_DIR>/hooks/pre-push-guard.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<HELMSMAN_PLUGIN_DIR>/hooks/stop-log.sh"
          }
        ]
      }
    ]
  }
}
```

Replace `<HELMSMAN_PLUGIN_DIR>` with the absolute path to the installed Helmsman plugin directory (e.g., `~/.claude/plugins/helmsman`).

Make all scripts executable:

```bash
chmod +x <HELMSMAN_PLUGIN_DIR>/hooks/*.sh
```

---

## Hook Details

### `inject-state.sh` — Context Injection

**Event:** `UserPromptSubmit`  
**Blocks:** Never (always exits 0)  
**Requires:** bash ≥ 3.2. `jq` optional (used for session-ID detection).

**What it does:**

1. Finds the Helmsman workspace (via `$HELMSMAN_WORKSPACE` env var or walking up the directory tree).
2. Finds the most recently modified `state.yaml` in `projects/`.
3. Reads `project`, `mode`, `current_stage`, stage `status` and `label`.
4. On the **first prompt of a session**: prints a rich welcome banner showing the active stage and the next action to take.
5. On **subsequent prompts**: prints a compact one-liner so Claude always knows where the project stands.

**Session start banner (example):**

```
[Helmsman] Session started — workspace: ~/helmsman-workspace
Active project : payments-v2 (feature mode)
Current stage  : 04-tech-design — Tech Design 👁 in-review
Next action    : Run /approve to accept, or /comment "<feedback>" to request changes.
Run /status for the full pipeline view.
```

**Subsequent prompt context (example):**

```
[Helmsman] payments-v2 | 04-tech-design (Tech Design) 👁 in-review
```

**Session detection:** Uses a marker file at `/tmp/helmsman-session-<session_id>`. The `stop-log.sh` hook removes this file at session end, so the next session always gets the welcome banner.

**Environment variables:**

| Variable | Effect |
|---|---|
| `HELMSMAN_WORKSPACE` | Override workspace discovery. Set to the absolute path of your workspace root. |

---

### `pre-push-guard.sh` — Push Gate

**Event:** `PreToolUse` (matcher: `Bash`)  
**Blocks:** Yes — exits 2 with a message when the push is blocked.  
**Requires:** bash ≥ 3.2, `jq` (required for JSON parsing; if absent, the hook fails open and allows the push).

**What it does:**

1. Reads the `Bash` tool's `command` from stdin JSON.
2. If the command matches `git push` (and is not `--dry-run`), proceeds with the check.
3. Finds the active project's pre-launch stage (looks for a stage ID containing `pre-launch`; falls back to `08-pre-launch`).
4. Checks that stage's status in `state.yaml`.
5. If status is not `complete`: blocks the push with a detailed error message.

**Block message (example):**

```
🚫 Helmsman: git push blocked for project "payments-v2"

The pre-launch stage (08-pre-launch) has not been approved.
Current status: pending

Complete the pre-launch checklist and run /approve before pushing:
  1. Run /advance to reach the pre-launch stage (if not there yet)
  2. Review the pre-mortem and rollback plan in 08-pre-launch/
  3. Run /approve to mark pre-launch complete
  4. Then retry your git push

To bypass this check (not recommended):
  Set HELMSMAN_SKIP_PUSH_GUARD=1 in your environment and retry.
```

**Bypass:** Set `HELMSMAN_SKIP_PUSH_GUARD=1` in the environment to disable the guard for a single push. Use with care — bypassing leaves no audit trail in Helmsman.

**Commands matched:**

```bash
git push                          # ✅ checked
git push origin main              # ✅ checked
git push --force origin feature   # ✅ checked
git push --dry-run                # ✅ not checked (read-only)
```

---

### `stop-log.sh` — Session End Logging

**Event:** `Stop`  
**Blocks:** Never (always exits 0)  
**Requires:** bash ≥ 3.2. `jq` optional (used for session ID and transcript path extraction).

**What it does:**

1. Finds the active project's `decisions.log.md`.
2. Appends a session-end entry with the current stage, status, session ID, and transcript path.
3. Removes the session marker file used by `inject-state.sh` so the next session gets a fresh welcome banner.

**Entry written to `decisions.log.md` (example):**

```markdown
---

## 2026-05-24 — Session ended

- **Stage at close:** 04-tech-design — Tech Design (in-review)
- **Session ID:** abc123def456
- **Transcript:** /tmp/claude-transcripts/abc123def456.jsonl
```

This creates a lightweight activity trail in `decisions.log.md` without requiring any manual action.

---

## Shared Library

All hooks source `hooks/lib.sh`, which provides:

| Function | Description |
|---|---|
| `find_workspace` | Discovers the Helmsman workspace root. |
| `active_state_file <workspace>` | Returns path to most-recently-modified `state.yaml`. |
| `yaml_field <key> <file>` | Reads a top-level scalar from a YAML file (pure bash). |
| `stage_status <stage-id> <file>` | Reads a stage's `status` value from `state.yaml`. |
| `stage_label <stage-id> <file>` | Reads a stage's `label` value from `state.yaml`. |

The library uses pure bash — no `yq`, `python`, or `ruby` required. It degrades gracefully: if a value cannot be read, the calling hook exits 0 (allows) rather than erroring.

---

## Workspace Discovery

All hooks locate the workspace in this priority order:

1. `$HELMSMAN_WORKSPACE` environment variable (if set and `manifest.yaml` exists there).
2. Walk up from the hooks script's own directory (works when called by absolute path).
3. Walk up from the current working directory.

**Tip:** Set `HELMSMAN_WORKSPACE` in your shell profile for reliable discovery across different working directories:

```bash
# ~/.zshrc or ~/.bashrc
export HELMSMAN_WORKSPACE=~/helmsman-workspace
```

---

## Per-Hook Settings Placement

Hooks can be configured at three scopes in Claude Code:

| Scope | File | When to use |
|---|---|---|
| Global | `~/.claude/settings.json` | Apply to all projects on this machine |
| Project | `<repo>/.claude/settings.json` | Apply only when working in a specific repo |
| Workspace | `<helmsman-workspace>/.claude/settings.json` | Apply when Claude Code is opened from the workspace root |

For most users, **global** is the right choice — Helmsman projects span multiple repos.

---

## Testing Hooks Individually

```bash
# Test inject-state.sh (simulate UserPromptSubmit payload)
echo '{"session_id":"test-123","prompt":"hello"}' \
  | bash hooks/inject-state.sh

# Test pre-push-guard.sh (simulate a git push tool call — should block)
echo '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' \
  | bash hooks/pre-push-guard.sh
echo "Exit code: $?"

# Test pre-push-guard.sh (non-push command — should allow)
echo '{"tool_name":"Bash","tool_input":{"command":"git status"}}' \
  | bash hooks/pre-push-guard.sh
echo "Exit code: $?"

# Test stop-log.sh (simulate Stop payload)
echo '{"session_id":"test-123","transcript_path":"/tmp/test.jsonl","stop_hook_active":false}' \
  | bash hooks/stop-log.sh
```

---

## Troubleshooting

**Hook output not appearing in Claude's context**

- Confirm the script is executable: `chmod +x hooks/inject-state.sh`
- Confirm the path in `settings.json` is absolute, not relative.
- Check the hook exits 0: run it manually from your terminal.

**pre-push-guard blocks even after /approve**

- The hook reads `state.yaml` directly. If the stage shows `in-review` instead of `complete`, run `/approve` again.
- Check which state.yaml is being read: `HELMSMAN_WORKSPACE=/your/path bash hooks/pre-push-guard.sh <<< '{"tool_name":"Bash","tool_input":{"command":"git push"}}'`

**stop-log.sh not writing to decisions.log.md**

- The hook only appends to the file if it already exists. Make sure the project has been started and the log was created by `/start-project`.

**Session start banner not showing**

- The banner appears only on the first prompt of a session. If `/tmp/helmsman-session-<id>` exists from a previous run, delete it: `rm /tmp/helmsman-session-*`

**jq not found**

- Install jq: `brew install jq` (macOS) or `apt install jq` (Ubuntu).
- Without jq, `inject-state.sh` still works (no session detection) and `pre-push-guard.sh` fails open (allows all pushes). `stop-log.sh` still works but records `session_id: unknown`.
