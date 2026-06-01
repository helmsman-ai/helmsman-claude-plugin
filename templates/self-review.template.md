# Self-Review — Task {{number}}: {{title}}

> **Stage**: 07-review
> **Project**: {{project_name}}
> **Produced by**: Reviewer agent
> **Task file**: `05-tasks/{{number}}-{{slug}}.md`
> **Commit(s) reviewed**: `{{commit_sha}}`
> **Date**: {{date}}

---

## Verdict

> **PASS** — ready for developer review
> **PASS WITH COMMENTS** — ready for developer review; comments below
> **FAIL** — must address issues before developer review

**Verdict**: {{verdict}}

---

## Acceptance Criteria Check

| Criterion | Met? | Notes |
|---|---|---|
| {{criterion_1}} | ✅ / ❌ / ⚠️ | {{notes}} |
| {{criterion_2}} | ✅ / ❌ / ⚠️ | {{notes}} |

---

## Convention Compliance

| Convention | Compliant? | Notes |
|---|---|---|
| Naming conventions | ✅ / ❌ | {{notes}} |
| File / module layout | ✅ / ❌ | {{notes}} |
| Commit message format | ✅ / ❌ | {{notes}} |
| Test naming | ✅ / ❌ | {{notes}} |

---

## Issues Found

> Severity: 🔴 Critical (must fix before proceed) · 🟠 Major (strong recommend) · 🟡 Minor (should fix) · 🔵 Nit (optional)

| # | Severity | File | Line | Issue | Recommendation |
|---|---|---|---|---|---|
| I-01 | 🔴 Critical | `{{file}}` | {{line}} | {{issue}} | {{recommendation}} |
| I-02 | 🟡 Minor | `{{file}}` | {{line}} | {{issue}} | {{recommendation}} |

---

## Security Check

- [ ] No secrets or credentials in code
- [ ] Input validation at system boundaries
- [ ] No SQL injection vectors
- [ ] No unintended data exposure in API responses
- [ ] Permissions/authorization correct

**Security notes**: {{security_notes_or_none}}

---

## Edge Cases Considered

| Edge Case | Handled? | Notes |
|---|---|---|
| {{edge_case_1}} | ✅ / ❌ | {{notes}} |
| {{edge_case_2}} | ✅ / ❌ | {{notes}} |

---

## Test Coverage

- Tests added: {{count}}
- Tests passing: {{count}} / {{count}}
- Coverage delta: {{delta}}
- Untested paths: {{untested_or_none}}

---

## Reviewer Notes

> Overall assessment, patterns noticed, anything the developer should know.

{{reviewer_notes}}
