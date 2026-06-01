# Strict Code Review — Gate Checklist

Run by the Orchestrator during `/advance` from the code review stage.

---

## Gate: `no_critical_issues` — HARD

**Check:** `07-review/strict-review-report.md` exists AND its `## Verdict` section contains `PASS` (or `PASS WITH WARNINGS`), NOT `FAIL`.

**Pass condition:** File exists and verdict is not `FAIL`.

**Fail message:**
> 🚫 Cannot advance: strict code review verdict is FAIL.
> Open `07-review/strict-review-report.md` to see the critical/high issues that must be resolved.
> Fix the issues, ask the reviewer to re-run (`/comment "please re-review"`), then `/advance` again.

---

## Gate: `strict_threat_model_complete` — HARD

**Check:** `07-review/strict-review-report.md` has a `## Threat Model` section AND that section is not empty, not `TODO`, and not a placeholder line like `_Fill in..._`.

**Pass condition:** Section exists with substantive content (≥ 2 non-empty lines, or `N/A — no new user-facing surface area introduced`).

**Fail message:**
> 🚫 Cannot advance: `07-review/strict-review-report.md` is missing a completed threat model.
> The `## Threat Model` section must be filled in or explicitly marked N/A.
> Ask the reviewer to complete it: `/comment "complete the threat model section"`

---

## Gate: `strict_secrets_scan_pass` — HARD

**Check:** `07-review/strict-review-report.md` has a `## Secrets Scan` section AND that section does not contain the word `DETECTED` or `FOUND` (case-insensitive).

**Pass condition:** Section exists and contains "No secrets detected" or equivalent.

**Fail message:**
> 🚫 Cannot advance: the secrets scan detected potential credentials in the diff.
> See `07-review/strict-review-report.md → Secrets Scan` for details.
> Remove the secrets from the diff (use environment variables or a secrets manager), then re-review.

---

## Gate: `strict_deps_reviewed` — SOFT

**Check:** If the diff adds any dependency files (package.json, requirements.txt, go.mod, etc.), the `## Dependency Review` section in the report must exist and must not be empty.

**Pass condition:** Section exists with content, OR no dependency files were changed.

**Warn message:**
> ⚠️ The dependency review section is incomplete. New dependencies were added but not reviewed.
> Consider filling in `07-review/strict-review-report.md → Dependency Review` before shipping.
