---
# Required: must match the `skill` field in state.yaml stages[id].skill
target_skill: code-review

# Override mode:
#   augment  → append this content after plugin INSTRUCTIONS.md (most common)
#   replace  → this content fully replaces plugin INSTRUCTIONS.md
#   patch    → H2 sections here replace matching H2 sections in the plugin
override_mode: augment

# Optional: human-readable description of why this override exists
description: "Adds team-specific security and migration checks to the standard code review"

# Optional: who maintains this override
author: platform-team

# Optional: minimum Helmsman version required
helmsman_min_version: "1.3.0"
---

<!--
  This file is loaded by the Orchestrator when a stage uses skill: <target_skill>.
  Place it at: <workspace>/.claude/skills/<target_skill>/override.md

  AUGMENT MODE (default):
    The content below is appended to the plugin's INSTRUCTIONS.md.
    Use it to add extra steps, team conventions, or additional checks.

  REPLACE MODE:
    The content below completely replaces the plugin's INSTRUCTIONS.md.
    The plugin's SKILL.md gate list is still used (unless you provide your own gates.yaml).

  PATCH MODE:
    H2 sections (## Section Name) replace the matching section in the plugin.
    All other sections from the plugin are kept unchanged.
    Section names must match exactly (case-sensitive).
-->

## Team-Specific Requirements

_Replace this section with your team's additional review requirements._

In addition to the standard checklist, verify the following before approving:

### API and Integration

- [ ] New public endpoints have an integration test covering the happy path.
- [ ] New endpoints are documented in the OpenAPI spec (or equivalent).
- [ ] Pagination is implemented for list endpoints returning > 100 items.

### Data and Migrations

- [ ] Database migrations are reversible (a `down` migration exists and was tested).
- [ ] Migrations do not perform table-locking operations on tables > 1M rows without a migration strategy note.
- [ ] No schema changes that break the currently deployed version (backwards-compatible).

### Security

- [ ] No secrets, API keys, or credentials in the diff (hardcoded or in comments).
- [ ] User input is validated at the boundary (not just in business logic).
- [ ] New dependencies have been reviewed for known CVEs (`npm audit` / `pip-audit` / etc.).

### Observability

- [ ] New failure paths emit a log entry at `warn` or `error` level.
- [ ] New background jobs or async operations have a timeout and failure handler.

---

<!--
  GATES (optional)
  If this override introduces new gate checks, list them in a gates.yaml alongside this file:

    .claude/skills/code-review/
      override.md      ← this file
      gates.yaml       ← add gates here

  gates.yaml format:
    mode: append        # append | replace
    gates:
      - id: myorg_all_endpoints_have_tests
        severity: hard
      - id: myorg_migrations_reversible
        severity: soft

  Gate IDs should be prefixed with your org/team name to avoid collisions.
-->
