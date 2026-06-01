# Community Skills

This directory holds third-party or team-authored skills that extend Helmsman beyond the built-in defaults.

Community skills follow the same structure as plugin skills. The Orchestrator loads them from this directory using the `community/` prefix in `stages[id].skill`.

---

## Structure

```
community-skills/
└── <skill-name>/
    ├── SKILL.md              ← metadata and gate declarations (required)
    ├── INSTRUCTIONS.md       ← step-by-step instructions for the agent (required)
    ├── checklists/
    │   └── <name>-gate-checklist.md
    ├── templates/
    │   └── <artifact>.template.md
    └── examples/             ← optional worked examples
        └── example-<name>.md
```

## Adding a skill

1. Create a directory under `community-skills/` with the skill name (lowercase, hyphenated).
2. Add `SKILL.md` and `INSTRUCTIONS.md` at minimum.
3. Reference the skill from `state.yaml`: `skill: community/<skill-name>`

See `docs/SKILL_MARKETPLACE.md` for the full guide including publishing conventions.

---

## Skills in this directory

| Skill | Description | Target stage |
|---|---|---|
| `example-strict-code-review` | Security-hardened code review with threat model requirement | `07-review` |

---

## Contributing a community skill

See `docs/SKILL_MARKETPLACE.md` — "Part 3: Publishing and Sharing Skills" for the publishing checklist and naming conventions.
