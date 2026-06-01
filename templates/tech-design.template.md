# Tech Design — {{project_name}}

> **Stage**: 04-tech-design
> **Produced by**: Architect agent
> **Last updated**: {{date}}
> **Status**: Draft / In Review / Approved

---

## 1. Overview

> One paragraph: what is being built, why, and the key architectural decision.

{{overview}}

---

## 2. Goals & Non-Goals (Technical)

**Goals**
- {{technical_goal_1}}
- {{technical_goal_2}}

**Non-Goals**
- {{technical_non_goal_1}}

---

## 3. System Context

> How this feature fits into the existing system. Describe the before/after state.

### Current State

{{current_state_description}}

### Target State

{{target_state_description}}

---

## 4. Component Design

> Describe the components, services, or modules involved. For each: purpose, inputs, outputs, owner.

### {{component_name}}

- **Purpose**: {{purpose}}
- **Inputs**: {{inputs}}
- **Outputs**: {{outputs}}
- **Notes**: {{notes}}

---

## 5. Data Model

> New tables, fields, or schema changes. Include migration strategy if altering existing data.

### New / Modified Schema

```sql
-- {{description}}
{{schema_definition}}
```

### Migration Strategy

{{migration_notes}}

---

## 6. API / Interface Contracts

> New or modified endpoints, events, or interfaces. Be precise about request/response shapes.

### `{{METHOD}} {{/path}}`

**Request**
```json
{{request_example}}
```

**Response**
```json
{{response_example}}
```

**Error cases**: {{error_cases}}

---

## 7. Sequence / Flow Diagrams

> Optional but recommended for multi-component flows. Use Mermaid or ASCII.

```
{{sequence_diagram}}
```

---

## 8. Security Considerations

- **Authentication**: {{auth_approach}}
- **Authorization**: {{authz_approach}}
- **Data sensitivity**: {{data_classification}}
- **Threat surface**: {{threats}}

---

## 9. Performance & Scalability

- **Expected load**: {{load_estimate}}
- **Bottlenecks identified**: {{bottlenecks}}
- **Caching strategy**: {{caching}}
- **SLA targets**: {{sla}}

---

## 10. Testing Strategy

- **Unit tests**: {{unit_test_approach}}
- **Integration tests**: {{integration_test_approach}}
- **Load / stress tests**: {{load_test_approach}}

---

## 11. Risks

See `risks.md` for the full risk register.

**Top risks for this design:**
- {{top_risk_1}}
- {{top_risk_2}}

---

## 12. Alternatives Considered

See `alternatives.md` for full comparison.

**Chosen approach**: {{chosen_approach}} — {{one_line_reason}}

---

## 13. ADRs

| # | Decision | Status | Link |
|---|---|---|---|
| ADR-001 | {{decision_title}} | Accepted | [adrs/001-{{slug}}.md](adrs/001-{{slug}}.md) |

---

## 14. Open Implementation Questions

> Things the Architect flagged that the Implementer needs to resolve.

- [ ] {{implementation_question}}
