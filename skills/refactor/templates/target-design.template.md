# Target Design — {{project-name}}

## Overview

{{2-3 sentences: what the code will look like after the refactor and why this is better}}

## Target Structure

{{ASCII diagram or description of new file/module layout}}

## Responsibilities (Target)

| Unit | File(s) | Responsibility |
|---|---|---|
| {{name}} | `{{path}}` | {{single, clear responsibility}} |

## Interface Changes

Changes that affect consumers of the refactored code:
| Consumer | Current interface | New interface | Migration needed |
|---|---|---|---|
| `{{path}}` | `{{old}}` | `{{new}}` | {{yes/no + what}} |

## ADRs

| ADR | Decision | Rationale |
|---|---|---|
| ADR-001 | {{decision}} | {{why}} |

## Migration Approach

{{How will this be done safely? Can it be done in parallel with feature work?
Will there be a flag day? What is the rollback strategy?}}
