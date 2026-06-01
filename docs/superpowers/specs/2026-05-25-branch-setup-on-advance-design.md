# Branch Setup on Advance to Implementation

**Date:** 2026-05-25
**Status:** Approved

---

## Summary

When the developer runs `/advance` and the destination stage is an implementation stage (agent: implementer), the Orchestrator intercepts to ask the developer which branch to work on before transitioning. The chosen branch is recorded in `state.yaml.repo_branches`. No new pipeline stage is added; mode YAMLs and the implementer are unchanged.

---

## Trigger

The branch-setup interception fires when ALL of the following are true:

- `/advance` is called and the **next stage** has `agent: implementer`
- `state.yaml.repo_branches` does **not** already have an entry for the linked repo(s)

If `repo_branches` is already populated (e.g. after a jump-back and re-advance), the interception is skipped entirely — idempotent.

Applies to: all modes that include an implementation stage (feature, bugfix, refactor, hotfix, chore).

---

## Branch Naming Convention Inference

Before presenting the prompt, the Orchestrator determines the branch naming pattern:

1. Check the linked repo's entry in `manifest.yaml` for `branch_naming_pattern`. If present, use it — skip steps 2 and 3.
2. Run `git -C <repo_path> branch -a` and sample up to 20 branch names. Infer the dominant prefix pattern (e.g. `feature/`, `bugfix/`, `PROJ-NNN/`).
3. Write the inferred pattern back to `manifest.yaml` under the repo entry so future projects skip inference.
4. If inference is ambiguous or the repo has no branches, fall back to the mode's `defaults.branch_pattern` (e.g. `helmsman/{project}`).

Generate the suggested branch name by substituting the project slug into the pattern:
- Pattern `feature/{slug}` + project `payments-v2` → `feature/payments-v2`

---

## User Prompt

```
Branch Setup — before implementation begins

Target repo: <repo-name>
Current branch: <current-git-branch>
Suggested branch: <suggested-name>  (inferred from repo convention)

Choose:
  [1] Create new branch: <suggested-name>
  [2] Use current branch: <current-git-branch>
  [3] Enter a custom branch name
```

- **[1]**: record `<suggested-name>` in `state.yaml.repo_branches`. Implementer creates it from the default branch in Step 0.
- **[2]**: record the current branch name. Implementer sees it's already on that branch and proceeds.
- **[3]**: prompt for a name, validate with `git check-ref-format --branch <name>`, re-prompt once on failure. Record the valid name.

For multi-repo projects, the prompt runs sequentially for each linked repo before the stage transition completes.

---

## State Changes

### `state.yaml`
```yaml
repo_branches:
  <repo-name>: "<chosen-branch>"   # written by Orchestrator at advance-to-impl time
```

Written once. The implementer's existing Step 0 reads this field unchanged.

### `manifest.yaml`
```yaml
repos:
  - name: my-api
    path: /path/to/my-api
    branch_naming_pattern: "feature/{slug}"   # added after first git inference, reused on all future projects
```

---

## Edge Cases

| Case | Behavior |
|---|---|
| `repo_branches` already set | Skip interception entirely |
| Repo has no existing branches | Fall back to mode's `defaults.branch_pattern` |
| Invalid custom branch name | Validate with `git check-ref-format --branch`; re-prompt once, then error |
| Multi-repo project | Prompt runs per repo sequentially |
| Hotfix fast_track mode | Interception runs normally — fast_track only affects gate severity |

---

## Files to Change

| File | Change |
|---|---|
| `helmsman/commands/advance.md` | Document the branch-setup interception step in the advance flow |
| `helmsman/agents/orchestrator.md` | Add branch-setup logic to the "advancing into implementation" section |
| `helmsman/docs/SCHEMAS.md` | Document `repo_branches` write timing; add `branch_naming_pattern` to manifest repo schema |

No changes to: mode YAMLs, implementer agent/skill, hooks.

---

## Out of Scope

- Helmsman does not create or push the branch — that remains the implementer's Step 0 responsibility.
- Helmsman does not validate that the chosen branch exists remotely.
- No UI change to `/status` output — the implementation stage still appears as a single stage.
