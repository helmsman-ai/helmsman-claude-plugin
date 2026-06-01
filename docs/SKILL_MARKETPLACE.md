# Helmsman Skill Marketplace

Helmsman's skill system is open and extensible. You can:

1. **Override** a built-in skill to tailor it to your team's standards.
2. **Create** entirely new skills for modes or stages not covered by the defaults.
3. **Share** skills with your team or the community via a Git repository.

---

## Concepts

| Term | Meaning |
|---|---|
| **Plugin skill** | A skill shipped with Helmsman. Lives in `<plugin>/skills/<name>/`. |
| **Skill override** | A workspace-local file that augments or replaces a plugin skill. Lives at `<workspace>/.claude/skills/<name>/override.md`. |
| **Community skill** | A third-party skill not in the plugin. Lives in `<workspace>/community-skills/<name>/`. |

---

## Part 1 — Skill Overrides

### What overrides do

An override lets you extend or replace what a skill's `INSTRUCTIONS.md` says, without modifying the plugin itself. Overrides survive plugin upgrades — your workspace file is never touched by an update.

### Override file location

```
<workspace>/
└── .claude/
    └── skills/
        └── <skill-name>/
            └── override.md
```

`<skill-name>` must match the skill path in `stages[id].skill` in `state.yaml`.

Examples:
- Override `code-review` → `.claude/skills/code-review/override.md`
- Override `tech-design` → `.claude/skills/tech-design/override.md`
- Override `bugfix/reproduce` → `.claude/skills/bugfix/reproduce/override.md`

### Override file format

```markdown
---
target_skill: code-review
override_mode: augment
---

## Additional Review Requirements

In addition to the standard checklist, also check:

- [ ] All new public API endpoints have a corresponding integration test.
- [ ] Database migrations are reversible (have a matching `down` migration).
- [ ] No hardcoded secrets or environment-specific strings in the diff.
```

### Override modes

| Mode | Behavior |
|---|---|
| `augment` | Override content is appended after the plugin skill's `INSTRUCTIONS.md`. Use this for extra steps, additional gates, or team conventions. |
| `replace` | Override content completely replaces the plugin skill's `INSTRUCTIONS.md`. The plugin's `SKILL.md` metadata (gate list, description) is still used unless you also provide a `SKILL.md`. |
| `patch` | Override contains named sections (H2 headings) that replace matching sections in the original. All other sections from the plugin are kept. |

### How the Orchestrator applies overrides

When loading a skill for a stage, the Orchestrator resolves it in this order:

```
1. Check <workspace>/.claude/skills/<skill-name>/override.md
   → If found:
       augment → read plugin INSTRUCTIONS.md + append override content
       replace → use override content only; use plugin SKILL.md for gates
       patch   → merge: override sections replace matching plugin sections

2. Fall back to <plugin>/skills/<skill-name>/INSTRUCTIONS.md
   (if no override, or if override is malformed)
```

If the override file's `target_skill` does not match the stage's actual skill, the Orchestrator logs a warning and falls back to the plugin skill.

### Override gate list

By default, overrides do **not** change the gate list. To add gates, create a `gates.yaml` alongside the override:

```
.claude/skills/code-review/
  override.md
  gates.yaml        ← optional: adds gates to (or replaces) the stage's gate list
```

`gates.yaml` format:

```yaml
mode: append   # append | replace
gates:
  - id: all_endpoints_have_integration_tests
    severity: hard
  - id: migrations_are_reversible
    severity: soft
```

These gates will appear in `state.yaml.stages[id].gates` when the project is created (for `replace` mode) or appended at runtime (for `append` mode). Gate IDs must be referenced in the override's checklist file to be enforceable.

### Template for new overrides

Copy from `templates/skill-override.template.md`. See that file for a fully annotated example.

---

## Part 2 — Community Skills

### What community skills are

Community skills are **new** skills — not modifications of plugin skills. They define entirely new stages or replace an existing stage's skill binding with a community-written alternative.

### Directory structure

```
<workspace>/
└── community-skills/
    └── <skill-name>/
        ├── SKILL.md              ← metadata (required)
        ├── INSTRUCTIONS.md       ← step-by-step agent instructions (required)
        ├── checklists/
        │   └── <name>-gate-checklist.md
        └── templates/
            └── <artifact>.template.md
```

This is the same structure as plugin skills. The Orchestrator loads community skills from `<workspace>/community-skills/` using the same rules as plugin skills.

### Referencing a community skill from a mode

In your project's `state.yaml`, the `stages[id].skill` field can reference a community skill using the `community/` prefix:

```yaml
stages:
  "07-review":
    skill: community/strict-code-review   # ← loads from community-skills/strict-code-review/
```

You can set this prefix at project creation by customising the mode YAML, or by editing `state.yaml` directly before the stage starts.

### `SKILL.md` required fields

```markdown
---
name: strict-code-review
version: 1.0.0
author: your-team
description: Security-focused code review with mandatory threat model check
target_stage: "07-review"
helmsman_min_version: "1.3.0"
---
```

### Example: `community-skills/example-strict-code-review/`

See the `community-skills/` directory for a fully worked example demonstrating:
- A `SKILL.md` with correct metadata
- An `INSTRUCTIONS.md` with extra security gates
- A gate checklist with hard and soft checks
- A review report template

---

## Part 3 — Publishing and Sharing Skills

### Single-team sharing (monorepo or shared repo)

Put your overrides and community skills in a shared Git repo or a folder committed alongside your Helmsman workspace:

```
my-org-helmsman/
├── manifest.yaml
├── .claude/
│   └── skills/
│       └── code-review/
│           └── override.md     ← team override, committed to Git
└── community-skills/
    └── strict-code-review/     ← team skill, committed to Git
```

Team members clone this repo and set `HELMSMAN_WORKSPACE` to its path.

### Public community skills (Git repository)

A community skill pack is a Git repository with this layout:

```
helmsman-skills-<name>/
├── README.md                   ← what the pack provides
├── install.sh                  ← copies skills to workspace (optional)
└── skills/
    ├── strict-code-review/
    │   ├── SKILL.md
    │   └── INSTRUCTIONS.md
    └── security-audit/
        ├── SKILL.md
        └── INSTRUCTIONS.md
```

**To install a skill pack:**

```bash
# Option A: copy into your workspace
cp -r helmsman-skills-security/skills/* ~/helmsman-workspace/community-skills/

# Option B: symlink (stays in sync with the source repo)
ln -s /path/to/helmsman-skills-security/skills/strict-code-review \
      ~/helmsman-workspace/community-skills/strict-code-review
```

### Skill pack conventions

| Convention | Details |
|---|---|
| Naming | Repository name: `helmsman-skills-<theme>`. Skill names: lowercase, hyphenated. |
| Versioning | Semver in `SKILL.md` frontmatter. Breaking changes bump major. |
| Compatibility | Declare `helmsman_min_version` in `SKILL.md`. |
| Gates | Gate IDs must be globally unique. Prefix with your org: `myorg_has_threat_model`. |
| Templates | Keep templates self-contained — no references to plugin-internal paths. |

### Checklist before publishing

- [ ] `SKILL.md` has `name`, `version`, `author`, `description`, `target_stage`, `helmsman_min_version`
- [ ] `INSTRUCTIONS.md` is self-contained (does not assume other skills' artifacts beyond standard prior-stage outputs)
- [ ] Gate IDs are prefixed to avoid collisions with built-in gates
- [ ] At least one worked example in `examples/` or inline in `INSTRUCTIONS.md`
- [ ] `README.md` explains what the skill does and when to use it
- [ ] Tested against at least one mode (note which mode(s) it was tested with)

---

## Skill Resolution Order (Reference)

When the Orchestrator needs to load a skill for a stage, it checks these locations in order and uses the first match:

```
1. <workspace>/.claude/skills/<skill>/INSTRUCTIONS.md   (full workspace override)
2. <workspace>/.claude/skills/<skill>/override.md       (augment/replace/patch)
3. <workspace>/community-skills/<skill>/INSTRUCTIONS.md (community skill)
4. <plugin>/skills/<skill>/INSTRUCTIONS.md              (plugin default)
```

If none is found: the stage runs without skill guidance (the agent uses its general training).

Gate lists always come from `state.yaml.stages[id].gates` (set at project creation). Overrides and community skills can request gate additions via `gates.yaml` as described above.
