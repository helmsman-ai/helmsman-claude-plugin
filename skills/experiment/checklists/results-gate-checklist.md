# Results Gate Checklist — Stage 04 (experiment)

## Hard Gates

- [ ] **`04-results/results.md` exists and is non-empty**

- [ ] **Each success metric from Stage 01 is addressed**
  - Check `01-hypothesis/success-metrics.md` and verify each metric appears in results.md
  - Failure: metric missing from results

- [ ] **Hypothesis verdict stated** — confirmed / refuted / inconclusive

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 04-results/
  ```

## Soft Gates

- [ ] **`04-results/metrics.md` exists with raw data table**

- [ ] **Measurement sources cited** — where did each number come from?
