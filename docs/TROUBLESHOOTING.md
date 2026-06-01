# Helmsman Troubleshooting

---

## Commands not appearing after install

**Symptoms:** `/start-project`, `/status`, etc. are not recognized by Claude Code.

**Fix:**
1. Confirm the plugin is installed: run `/plugin list` and look for `helmsman`.
2. If installed, run `/reload-plugins` — plugin changes require a reload.
3. If not installed: `/plugin marketplace add /path/to/helmsman-plugin` then `/plugin install helmsman`.
4. If commands still don't appear, restart your Claude Code session.

---

## `/advance` is blocked by a hard gate

**Symptoms:** Running `/advance` outputs a message like `Gate 'has_2_alternatives' failed (hard) at stage 04-tech-design`.

**Fix:**
1. Look up the gate ID in [GATES.md](GATES.md) to understand what's missing.
2. Use `/comment "..."` to instruct the agent to add the missing artifact. The agent will revise.
3. Re-run `/advance` after the agent has updated the artifacts.
4. If the gate doesn't apply to your situation (e.g., team policy), bypass it with a reason:
   ```
   /override-gate has_adrs --stage 04-tech-design --bypass --reason "small team, ADRs optional here"
   ```

---

## Agent produced wrong output / misunderstood the PRD

**Symptoms:** The agent's artifacts don't reflect what you wanted, or it made incorrect assumptions.

**Fix:**
1. Use `/comment "<specific correction>"` — be precise about what is wrong and what you want instead. The agent will revise.
2. If the misunderstanding is deep (e.g., the agent built on a wrong assumption from Stage 02), use `/jump-back <stage-id>` to return to the stage where the problem originated, fix it there, then `/propagate` forward.
3. Do not use `/approve` on output you are not satisfied with — approval is permanent.

---

## Hooks not firing

**Symptoms:** `inject-state.sh` does not inject context; `pre-push-guard.sh` does not block pushes.

**Fix:**
1. Check that hooks are configured in `.claude/settings.json`:
   ```json
   "hooks": {
     "UserPromptSubmit": [{"type": "command", "command": "/path/to/hooks/inject-state.sh"}]
   }
   ```
2. Confirm the script is executable: `ls -la /path/to/hooks/inject-state.sh` — it should show `-rwxr-xr-x`.
   If not: `chmod +x /path/to/hooks/inject-state.sh`
3. Confirm the path in `settings.json` is absolute, not relative.
4. See [HOOKS.md](HOOKS.md) for the full configuration reference.

---

## `state.yaml` looks wrong / project appears stuck

**Symptoms:** `/status` shows an unexpected stage, a stage that should be complete shows as pending, or the Orchestrator references the wrong project.

**What NOT to do:** Do not manually edit `state.yaml` — the Orchestrator is the only writer. Manual edits can corrupt the state machine.

**Fix:**
1. Run `/status` to see the full pipeline view including gate results and history.
2. If the current stage is wrong, use `/jump-back <correct-stage-id> --reason "state recovery"` to rewind to the correct point.
3. If the Orchestrator is confused about which project is active, check that `manifest.yaml` lists the correct workspace and that your session is open in the workspace directory.
4. If `state.yaml` is corrupted beyond recovery, restore from the last snapshot: `/snapshots` to list, then `/snapshots restore <snapshot-id>`.

---

## How to reset a project without losing history

**Situation:** You want to start a stage over, but keep the decisions log and prior artifacts as a record.

**Option A — Jump back and re-run (recommended):**
```
/jump-back <stage-id> --reason "starting over because..."
/propagate
```
This keeps all history in `decisions.log.md` and creates a snapshot before overwriting artifacts.

**Option B — Restore from snapshot:**
```
/snapshots                         # list available snapshots
/snapshots restore <snapshot-id>   # restore state to that point
```
Snapshots are taken automatically before each `/propagate` run.

**Option C — Start a new project:**
If the work has fundamentally changed scope, it may be cleaner to start a new project:
```
/start-project <new-name> --mode feature
```
The old project's artifacts remain under `projects/<old-name>/` for reference.

---

## Plugin not found after `git pull`

**Symptoms:** After updating the plugin, commands stop working or behave unexpectedly.

**Fix:**
```
/reload-plugins
```
This is required after any change to plugin files — including a `git pull` update.

---

## How to push your branch after the pipeline completes

**Situation:** The Helmsman pipeline has finished (Stage 09 Launch reached) but your code is still only on the local branch `helmsman/<project-name>`.

**Why no agent pushes:** Git push is intentionally a manual step. No Helmsman agent pushes to a remote — the Implementer only commits locally. This keeps the launch decision in your hands. The `pre-push-guard.sh` hook can warn or block an early push, but it never initiates one.

**To push:**
```bash
git push -u origin helmsman/<project-name>
```

Then open a pull request from `helmsman/<project-name>` into your main branch as you normally would.

**If `pre-push-guard.sh` blocks your push:** it means the project hasn't reached the required stage. Run `/status` to see where you are, complete the remaining stages, then push again.
