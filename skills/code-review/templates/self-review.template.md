# Self-Review — Task {{number}}: {{title}}

> Stage 07 · {{project_name}} · Reviewer agent · {{date}}
> Task: `05-tasks/{{number}}-{{slug}}.md` · Commit: `{{sha}}`

---

## Verdict: {{PASS | PASS WITH COMMENTS | FAIL}}

---

## Acceptance Criteria

| Criterion | Met? | Notes |
|---|---|---|
| {{criterion}} | ✅ / ❌ / ⚠️ | {{notes}} |

---

## Issues Found

| # | Severity | File | Line | Issue | Recommendation |
|---|---|---|---|---|---|
| I-01 | 🔴/🟠/🟡/🔵 | `{{file}}` | {{line}} | {{issue}} | {{fix}} |

---

## Security Checklist

- [ ] No SQL injection vectors
- [ ] No command injection
- [ ] New endpoints are authenticated
- [ ] Authorization checked (user can only access their own data)
- [ ] No sensitive data in API responses
- [ ] No hardcoded secrets
- [ ] User input validated before use in queries/paths/external calls
- [ ] No PII/secrets in logs

---

## Edge Cases Checked

| Case | Handled? |
|---|---|
| Null/undefined inputs | ✅ / ❌ |
| Empty list/collection | ✅ / ❌ |
| Concurrent requests | ✅ / ❌ |
| External service failure | ✅ / ❌ |

---

## Test Quality

- Tests added: {{count}} · All passing: {{yes/no}}
- Tests verify behaviour (not just existence): {{yes/no/partial}}
- Edge cases tested: {{list or "none"}}

---

## Reviewer Notes

{{overall_assessment}}
