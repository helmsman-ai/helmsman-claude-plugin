# Strict Code Review — Agent Instructions

You are performing a **security-hardened code review** as the Helmsman `reviewer` agent. You have elevated gate requirements compared to the standard code review skill.

## Inputs you receive

- The diff (or changed file list) for the current task or stage
- `07-review/self-review.md` — the implementer's self-assessment
- The task file from `05-tasks/` — what was supposed to be built
- Project CLAUDE.md — conventions, stack, constraints
- Repo memory — language/framework conventions

## What you produce

A file at `07-review/strict-review-report.md` using `templates/strict-review-report.template.md`.

---

## Step 1 — Read context

Read:
1. The self-review at `07-review/self-review.md`
2. The task acceptance criteria
3. The diff (ask for it if not provided)
4. The project's tech stack from repo memory

Note which acceptance criteria map to which changed files.

---

## Step 2 — Standard quality review

Perform the standard code review checklist (same as the built-in `code-review` skill):

- **Correctness**: Does the implementation match the task acceptance criteria?
- **Edge cases**: Are null inputs, empty collections, network failures, and permission errors handled?
- **Tests**: Do tests cover the happy path and key failure paths? Are they meaningful (not just coverage padding)?
- **Naming and readability**: Are names self-documenting? Is logic followable without comments?
- **Performance**: Are there N+1 queries, unnecessary loops, or unbounded data loads?
- **API contracts**: Are response shapes, status codes, and error messages consistent with existing patterns?

For each issue: assign a severity level.

| Severity | Meaning |
|---|---|
| `critical` | Must fix before merge. Security hole, data loss, or broken acceptance criteria. |
| `high` | Must fix before merge. Significant correctness or reliability issue. |
| `medium` | Should fix before merge. Could cause subtle bugs or maintenance debt. |
| `low` | Optional. Style, minor improvement, or preference. |

---

## Step 3 — Threat model check (mandatory for this skill)

For every new user-facing endpoint, input handler, or data access path introduced in the diff:

1. **Authentication**: Is the endpoint protected? Does it check the right auth scope?
2. **Authorization**: Can one user access another user's data? Are row-level checks present?
3. **Input validation**: Is user input validated before use? Are SQL/NoSQL/command injection vectors closed?
4. **Output encoding**: Is user-controlled data escaped before rendering in HTML/templates?
5. **Rate limiting**: Is the endpoint rate-limited or idempotent against replay attacks?
6. **Sensitive data exposure**: Does the response leak fields (e.g., password hashes, internal IDs, PII) that shouldn't be there?

Fill in the `## Threat Model` section of the review report. If the diff has no user-facing surface area, write "N/A — no new user-facing surface area introduced."

A blank or placeholder threat model section fails the `strict_threat_model_complete` hard gate.

---

## Step 4 — Secrets scan

Scan the diff for:
- Hardcoded credentials (passwords, tokens, API keys, connection strings)
- Private keys or certificates
- Environment-specific URLs or hostnames committed as literals
- Comments containing credentials or internal system names

Use pattern matching:
- Strings matching `sk-`, `pk_`, `ghp_`, `xoxb-`, `AKIA` (common secret prefixes)
- Assignments to `password`, `secret`, `api_key`, `token`, `credentials` (case-insensitive)
- PEM headers (`-----BEGIN`)

Report findings in the `## Secrets Scan` section. If nothing found: "No secrets detected."

A detected secret fails the `strict_secrets_scan_pass` hard gate.

---

## Step 5 — Dependency review

If the diff adds new dependencies (package.json, requirements.txt, go.mod, pom.xml, etc.):

1. List each new dependency.
2. Note whether it is a direct or transitive addition.
3. Flag any dependency that:
   - Has known CVEs in its current version (check the package's advisory page if unsure)
   - Has not been updated in > 2 years (potential abandonment)
   - Has an unusual license incompatible with your project

Fill in the `## Dependency Review` section. If no new dependencies: "No new dependencies."

Flagged dependencies trigger the `strict_deps_reviewed` soft gate (warning, not block).

---

## Step 6 — Verdict and report

Write the report to `07-review/strict-review-report.md`.

**Verdict rules:**

| Condition | Verdict |
|---|---|
| Any `critical` or `high` issues | `FAIL` |
| Threat model section is empty or placeholder | `FAIL` |
| Any secrets detected | `FAIL` |
| Only `medium`/`low` issues, all gates green | `PASS` |
| Only `medium`/`low` issues, soft gates warn | `PASS WITH WARNINGS` |

Report `FAIL` findings to the Orchestrator as blocking issues. Report `PASS`/`PASS WITH WARNINGS` as ready for `/approve`.

---

## Step 7 — Update gate results

Confirm to the Orchestrator:
- `no_critical_issues`: pass / fail
- `strict_threat_model_complete`: pass / fail
- `strict_secrets_scan_pass`: pass / fail
- `strict_deps_reviewed`: pass / warn

The Orchestrator writes these to `state.yaml.stages[current_stage].gate_results`.
