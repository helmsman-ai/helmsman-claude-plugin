# Example: Clean PRD — payments-v2

> This is a worked example showing what a well-formed Stage 02 output looks like.
> The raw PRD input was: "Allow users to make payments. Should be fast and reliable.
> Support cards and wallets."

---

## 1. Problem Statement

Users currently cannot pay for orders within the app — they are redirected to an external payment page, which has a 23% drop-off rate. This project adds a native `/charge` endpoint and frontend payment flow to capture payments without leaving the app, supporting saved cards and wallet balance.

---

## 2. Goals

- [ ] Users can complete a payment using a saved card in under 3 steps from the checkout screen
- [ ] Users can pay using their wallet balance when sufficient funds exist
- [ ] The `/charge` endpoint is idempotent: duplicate requests with the same `idempotency_key` return the existing transaction without double-charging
- [ ] Failed payment attempts surface a machine-readable error code (defined in §5) to the frontend
- [ ] All payment events are written to the audit log within 1 second of occurrence

---

## 3. Non-Goals

- Refunds are NOT in scope for this iteration (confirmed by PM 2025-01-15; tracked in OOS-01)
- Adding new payment methods beyond cards and wallet is NOT in scope
- International/multi-currency support is NOT in scope
- Admin-initiated payments on behalf of users are NOT in scope

---

## 4. User Stories

| # | Role | Action | Outcome |
|---|---|---|---|
| US-01 | Authenticated customer | Pay for an order using a saved card | Order is confirmed and charged; I receive a receipt |
| US-02 | Authenticated customer | Pay using my wallet balance | Wallet is debited; order is confirmed |
| US-03 | Authenticated customer | See a clear error when my card is declined | I understand what went wrong and can try a different method |
| US-04 | System (API caller) | Retry a failed charge request with the same `idempotency_key` | The charge is not duplicated; existing result is returned |

---

## 5. Acceptance Criteria

| # | Criterion | Story | Priority |
|---|---|---|---|
| AC-01 | `POST /api/payments/charge` responds with HTTP 200 and a `transaction_id` within 2000ms at p95 under normal load | US-01, US-02 | Must Have |
| AC-02 | Duplicate requests with identical `idempotency_key` return the original transaction; Stripe is called exactly once | US-04 | Must Have |
| AC-03 | A declined card returns HTTP 402 with `error.code` set to one of: `card_declined`, `insufficient_funds`, `expired_card`, `do_not_honor` | US-03 | Must Have |
| AC-04 | Wallet payment debits `wallet_balance` atomically with charge creation — no partial state possible | US-02 | Must Have |
| AC-05 | Every charge attempt (success or failure) writes an entry to the `payment_audit_log` table within 1 second | US-01, US-02 | Must Have |
| AC-06 | Endpoint rejects requests from unauthenticated callers with HTTP 401 | US-01 | Must Have |

---

## 6. Constraints

| Type | Constraint | Source |
|---|---|---|
| Performance | `/charge` p95 latency ≤ 2000ms | PM stated; matches existing SLA tier |
| Security | PCI-DSS SAQ-A compliance maintained (no raw card data on our servers) | Legal requirement |
| Compatibility | Existing Stripe integration (`stripe-node` v12) must be reused | Platform team decision |
| Conventions | All DB access via repository layer; no direct queries in service layer | CONVENTIONS.md §3 |

---

## 7. Key Metrics

| Metric | Baseline | Target | Method |
|---|---|---|---|
| Checkout drop-off rate | 23% | < 10% | Analytics funnel event `checkout_completed` |
| Payment p95 latency | N/A (new) | ≤ 2000ms | APM trace on `/charge` |
| Idempotency collision rate | N/A | < 0.1% duplicate charges | DB query on `transactions` table |

---

## 8. Dependencies

| Dependency | Type | Status | Contact |
|---|---|---|---|
| Stripe API | External | Active; v12 SDK in use | Platform Team |
| `wallet_balance` table (payments-service) | Upstream | Exists; read-write access confirmed | Payments Team |
| Audit log service | Downstream | Exists; write-only API available | Data Team |

---

## Open Items

- [PENDING Q-01] Exact `idempotency_key` format (UUID? caller-generated string? max length?) — owner: PM
- [PENDING Q-02] Wallet top-up is out of scope confirmed, but what happens when wallet balance is insufficient and card backup is not set up? — owner: PM

> See `open-questions.md` for full tracking.
