# Contributing to Helmsman

Helmsman is a Claude Code plugin — all contributions are markdown files, YAML schemas, and agent/skill/command definitions. No compiled code. Anyone who can write a clear specification can contribute.

---

## What You Can Contribute

| Area | Examples |
|---|---|
| **Skill variants** | `tech-design-microservices`, `prd-review-mobile`, `task-breakdown-data-pipeline` |
| **Agent improvements** | Sharper personas, better behavior rules, more precise output discipline |
| **New commands** | `/jump-back`, `/skip-stage`, `/decisions` (v1 features) |
| **Templates** | Better artifact templates for specific domains |
| **Bug fixes** | Incorrect gate logic, broken cross-references, missing sections |
| **Documentation** | Better examples, clarified instructions, domain-specific walkthroughs |

---

## Repository Structure

```
helmsman/
├── agents/          — one .md file per agent
├── commands/        — one .md file per slash command
├── skills/          — one directory per stage skill
│   └── <skill>/
│       ├── SKILL.md
│       ├── INSTRUCTIONS.md
│       ├── templates/
│       ├── checklists/
│       └── examples/
├── templates/       — workspace-level artifact templates
└── docs/            — SCHEMAS.md, WALKTHROUGH.md, this file
```

---

## How to Add a Skill Variant

Skill variants are the primary extension point. They let teams customize Helmsman for their specific domain without forking the core.

### Option A — Project-scoped override (no PR needed)

Drop an `override.md` inside the skill directory of your project:

```
projects/<your-project>/.claude/skills/tech-design/override.md
```

This file is loaded instead of the default `SKILL.md` for that project only. Use it when your domain requires significantly different behavior (e.g., mobile-first design constraints, microservices-specific component templates).

### Option B — Workspace-scoped variant (contribute back)

1. Create a new skill directory alongside the existing ones:
   ```
   helmsman/skills/tech-design-microservices/
   ├── SKILL.md
   ├── INSTRUCTIONS.md
   ├── templates/
   ├── checklists/
   └── examples/
   ```

2. Name it `<base-skill>-<variant>` (e.g., `prd-review-mobile`, `task-breakdown-ml`).

3. Your `SKILL.md` must start with:
   ```yaml
   ---
   name: tech-design-microservices
   extends: tech-design           # base skill this variant overrides
   description: >
     Tech design skill for microservices architectures. Adds: service
     boundary analysis, API gateway patterns, distributed transaction guidance.
   ---
   ```

4. Copy the base skill's files as your starting point. Only include sections you are changing — document what you changed and why.

5. Add an example showing what different output this variant produces vs. the base.

---

## How to Improve an Agent

Agent files live in `agents/`. Each has a standard structure:

```markdown
---
name: <agent-name>
description: ...
tools: [Read, Write, ...]
---

# <Agent Name>

## When You Are Invoked
## What You Produce
## Your Process
## Behavior Rules (Do / Do Not)
## Output Discipline
## Example Interaction
## After You Finish
```

**Guidelines for agent changes:**

- **Persona**: should be vivid and specific enough that the agent "acts in character" without needing constant reminders. Avoid generic descriptions like "helpful assistant."
- **Behavior rules**: "Do not" rules are as important as "Do" rules. Think about the common failure modes you want to prevent.
- **Process**: numbered steps in the right order. The agent follows this exactly.
- **Example interaction**: show a real output excerpt, not a description of what output looks like.
- **Do not** add tools to agents that don't need them (principle of least privilege).

---

## How to Add a Slash Command

1. Create `helmsman/commands/<command-name>.md`

2. Required frontmatter:
   ```yaml
   ---
   name: <command-name>
   description: >
     One or two sentences. What this command does for the developer.
   arguments:
     - name: <arg>
       description: ...
       required: true/false
   ---
   ```

3. Required sections:
   - **Purpose** — why this command exists (one paragraph)
   - **Syntax** — usage with examples
   - **Step-by-Step Behavior** — numbered steps; each step says what to read, what to decide, what to write
   - **State Changes** — table of every file that gets created or modified
   - **Error Cases** — table of every failure mode with the exact response

4. Register the new command in `plugin.json` under `"commands"`.

---

## How to Improve a Template

Templates live in `helmsman/templates/` (workspace level) and `helmsman/skills/<skill>/templates/` (skill level). The skill-level template is leaner (agent-facing); the workspace-level template is the full reference.

Rules for templates:
- Every `{{placeholder}}` must have an adjacent comment explaining what goes there
- Do not add sections that are not referenced by any agent instruction or gate checklist
- If you add a section to a template, update the corresponding gate checklist to check for it

---

## Quality Bar for Contributions

Every contribution must:

1. **Be complete** — no `{{placeholder}}` tokens in submitted files; no "TODO: fill this in"
2. **Have an example** — skills must include an `examples/` file showing real output
3. **Cross-reference correctly** — if you add a gate, add it to the checklist; if you add a template section, reference it in INSTRUCTIONS.md
4. **Use consistent terminology** — match the design doc vocabulary (stage, gate, artifact, dossier, decision log)
5. **Be self-contained** — a developer reading your contribution cold should understand it without context from this conversation

---

## Testing Your Contribution

Before submitting, verify your change works by running through the relevant part of `docs/WALKTHROUGH.md`. If your change affects a skill or agent, check that:

- The gate checklist still passes on valid output
- The gate checklist correctly fails on invalid output
- The example in `examples/` passes the gate checklist

---

## Submitting

1. Fork the repository
2. Create a branch: `skill/tech-design-microservices` or `fix/prd-reviewer-missing-constraints`
3. Make your changes — one logical change per PR
4. Update `CHANGELOG.md` with a brief entry under `[Unreleased]`
5. Open a PR with:
   - What you changed and why
   - Which part of the WALKTHROUGH you tested
   - Any design doc sections this relates to

---

## Design Doc

The authoritative design reference is `design-doc.md` in the workspace root. When in doubt about intent, the design doc wins. If you think the design doc is wrong, flag it in your PR.
