# Strict Code Review Report

**Project:** {{project}}
**Task / Stage:** {{task_or_stage}}
**Reviewer:** Helmsman reviewer agent
**Date:** {{date}}

---

## Verdict

<!-- PASS | PASS WITH WARNINGS | FAIL -->
**PASS**

---

## Summary

<!-- 2-3 sentences: what was reviewed, overall quality, notable findings -->

---

## Issues Found

<!-- One entry per issue. Remove this section if none. -->

| Severity | Location | Description | Recommendation |
|---|---|---|---|
| critical | | | |
| high | | | |
| medium | | | |
| low | | | |

---

## Threat Model

<!-- Required. For each new user-facing surface area: auth, authz, input validation,
     output encoding, rate limiting, sensitive data exposure.
     If no new user-facing surface area: write exactly:
     "N/A — no new user-facing surface area introduced." -->

**Authentication:** <!-- Protected? Correct scope? -->

**Authorization:** <!-- Row-level checks? Cross-user access possible? -->

**Input validation:** <!-- Validated at boundary? Injection vectors closed? -->

**Output encoding:** <!-- User-controlled data escaped? -->

**Rate limiting:** <!-- Endpoint rate-limited or idempotent? -->

**Sensitive data exposure:** <!-- Response leaks PII or internal fields? -->

---

## Secrets Scan

<!-- Result of scanning the diff for hardcoded credentials, keys, tokens.
     If nothing found, write: "No secrets detected." -->

No secrets detected.

---

## Dependency Review

<!-- If no new dependencies: "No new dependencies."
     Otherwise: list each, note direct vs transitive, flag CVEs or abandoned packages. -->

No new dependencies.

---

## Test Coverage Assessment

<!-- Do tests cover acceptance criteria? Happy path + key failure paths? -->

---

## Notes for Developer

<!-- Optional: suggestions, questions, things to watch for in the next task. -->
