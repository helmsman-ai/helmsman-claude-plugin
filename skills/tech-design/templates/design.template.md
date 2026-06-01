# Tech Design — {{project_name}}

> Stage 04 · Architect agent · {{date}}

---

## 1. Overview

{{one_paragraph_what_why_key_decision}}

---

## 2. Goals & Non-Goals (Technical)

**Goals**
- {{technical_goal}}

**Non-Goals**
- {{technical_non_goal}}

---

## 3. System Context

**Current state**: {{current_state}}

**Target state**: {{target_state}}

---

## 4. Component Design

### {{component_name}}
- **Purpose**: {{purpose}}
- **Layer**: {{service/repository/controller/etc}}
- **Inputs**: {{inputs}}
- **Outputs**: {{outputs}}

---

## 5. Data Model

```sql
{{schema_changes}}
```

**Migration**: {{migration_strategy}}

---

## 6. API / Interface Contracts

### `{{METHOD}} {{/path}}`

Request: `{{request_shape}}`
Response: `{{response_shape}}`
Errors: `{{error_codes}}`

---

## 7. Sequence / Flow Diagrams

```
{{sequence}}
```

---

## 8. Security Considerations

- **Auth**: {{auth}}
- **Authz**: {{authz}}
- **Data exposure**: {{exposure}}

---

## 9. Performance & Scalability

- **Load estimate**: {{load}}
- **SLA target**: {{sla}}
- **Bottlenecks**: {{bottlenecks}}

---

## 10. Testing Strategy

- **Unit**: {{unit}}
- **Integration**: {{integration}}

---

## 11. Risks

See [`risks.md`](risks.md). Top risks: {{top_risks}}

---

## 12. Alternatives Considered

See [`alternatives.md`](alternatives.md). Chosen: {{chosen_option}} — {{reason}}

---

## 13. ADRs

| # | Decision | Link |
|---|---|---|
| ADR-001 | {{decision}} | [adrs/001-{{slug}}.md](adrs/001-{{slug}}.md) |

---

## 14. Open Implementation Questions

- [ ] {{question_for_implementer}}
