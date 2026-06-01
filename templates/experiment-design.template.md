# Experiment Design — {{project-name}}

## What to Build

{{Minimal implementation to test the hypothesis. Reference hypothesis.md.}}

## Files to Touch

| Action | File | What Changes |
|---|---|---|
| create/modify | `{{path}}` | {{change}} |

## Instrumentation

How we will collect the success metrics:
| Metric | Instrumentation | Where data lands |
|---|---|---|
| {{metric}} | {{log event / analytics call / manual}} | {{location}} |

## Isolation Strategy

{{How is this experiment isolated from users who should not see it?
Feature flag: {{flag name}}? Shadow mode? Canary %?}}

## Cleanup Plan

If DISCARD:
- Remove: {{list files/flags to delete}}
- Revert: {{any config changes}}
- Estimated cleanup time: {{estimate}}

## Fit Check

Estimated build time: {{estimate}}
Time box from Stage 01: {{time box}}
Fits within time box: {{yes / no — if no, explain what is cut}}
