# Recommendation Gate Checklist — Stage 04 (spike)

## Hard Gates

- [ ] **`04-recommendation/recommendation.md` exists and is non-empty**

- [ ] **Contains a clear decision verdict**
  - Must contain one of: ACCEPT, REJECT, DEFER
  - Run: `grep -i "ACCEPT\|REJECT\|DEFER" 04-recommendation/recommendation.md`
  - Failure: verdict missing, or only "it depends", "further investigation needed"

- [ ] **Next steps present** (required for ACCEPT; optional for REJECT/DEFER)

- [ ] **No `{{placeholder}}` tokens**
  ```bash
  grep -r "{{" 04-recommendation/
  ```

## Soft Gates

- [ ] **`03-findings/options.md` has ≥ 2 options** — recommendation should evaluate alternatives
