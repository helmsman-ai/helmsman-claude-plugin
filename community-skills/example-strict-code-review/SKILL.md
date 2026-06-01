---
name: example-strict-code-review
version: 1.0.0
author: helmsman-contributors
description: >
  Security-hardened code review. Extends the standard review with mandatory
  threat model verification, dependency audit, and secrets scanning. Intended
  for teams shipping customer-facing or security-sensitive features.
target_stage: "07-review"
helmsman_min_version: "1.3.0"
---

# Strict Code Review Skill

## What this skill produces

A structured review report covering:
- Standard code quality (same as built-in `code-review`)
- Threat model checklist (mandatory for this skill)
- Dependency audit summary
- Secrets scan result

## When to use this skill

Use `community/example-strict-code-review` instead of the built-in `code-review` when:
- The feature handles authentication, authorization, or payments
- The feature introduces new external dependencies
- Your team policy requires a security review sign-off before merging

## How to activate

In your project's `state.yaml`, set the review stage's skill:

```yaml
stages:
  "07-review":
    skill: community/example-strict-code-review
```

Or configure it as the default for all projects in `manifest.yaml`:

```yaml
defaults:
  default_review_skill: community/example-strict-code-review
```

## Gates

| Gate ID | Severity | Check |
|---|---|---|
| `no_critical_issues` | hard | No critical or high-severity issues in the review |
| `strict_threat_model_complete` | hard | Threat model section is filled in (not empty or placeholder) |
| `strict_secrets_scan_pass` | hard | No secrets detected in the diff |
| `strict_deps_reviewed` | soft | New dependencies noted and justified |
