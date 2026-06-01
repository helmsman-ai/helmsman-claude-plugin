# Repo Memory — {{repo_name}}

> **Scope**: All projects that touch this repository
> **Updated by**: User or Orchestrator (after memory-distillation, user-approved)
> **Location**: `memory/repos/{{repo_name}}.md`
>
> Loaded by agents working on projects linked to `{{repo_name}}`.

---

## Tech Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Language | {{language}} | {{version}} | |
| Framework | {{framework}} | {{version}} | |
| Database | {{database}} | {{version}} | |
| Test runner | {{test_runner}} | {{version}} | |
| Linter / Formatter | {{linter}} | {{version}} | |

---

## Conventions

> Source: {{conventions_file_path_or_"derived from observation"}}

### Naming

- Files: {{e.g., "kebab-case for modules, PascalCase for classes"}}
- Functions: {{e.g., "camelCase; verbs first (getUserById, not userGetById)"}}
- Tests: {{e.g., "*.test.ts colocated with source; describe/it style"}}
- Database: {{e.g., "snake_case table and column names; plural table names"}}

### File Layout

```
{{repo_name}}/
├── {{describe_key_directories}}
```

### Commit Messages

- Format: {{e.g., "Conventional Commits: feat/fix/chore/docs/refactor + optional scope"}}
- Example: `{{e.g., "feat(payments): add partial refund endpoint"}}`

### PR / Branch Conventions

- Branch pattern: {{e.g., "feature/TICKET-description"}}
- PR template: {{exists_at_path_or_none}}
- Required reviewers: {{count_or_teams}}

---

## Architectural Quirks

> Things that would surprise a developer new to this repo.

- {{e.g., "All DB access must go through the repository layer — never query directly from service layer"}}
- {{e.g., "The `config/` module is a singleton loaded once at startup — don't import env vars elsewhere"}}
- {{e.g., "Feature flags live in LaunchDarkly; use the wrapper in `lib/flags.ts` not the SDK directly"}}

---

## Prior ADRs

> Significant past decisions that constrain future choices.

| ADR | Decision | Location |
|---|---|---|
| {{title}} | {{one_line_summary}} | {{link_or_path}} |

---

## Known Issues / Tech Debt

> Things to be aware of but not necessarily fix in every project.

- {{e.g., "The authentication middleware has a known N+1 query — tracked in TICKET-456"}}

---

## Notes

{{freeform_notes}}
