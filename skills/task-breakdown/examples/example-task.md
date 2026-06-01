# Example: Task 003 — Add idempotency check to PaymentService

> payments-v2 · Est. 2h · Status: complete

---

## Goal

Before processing a charge, check if a transaction with the same `idempotency_key` already exists. If it does, return the existing transaction without calling Stripe.

---

## Context

ADR-001 chose DB-level idempotency over Stripe-only. Task 001 added the `idempotency_key` column and unique index. Task 002 added `TransactionRepository.findByIdempotencyKey()`. This task adds the guard to `PaymentService.charge()`.

The repository layer must be used for all DB access (CONVENTIONS.md §3). Do not query the DB directly from the service.

Race condition note: the app-level check + DB unique constraint together provide the guarantee. If two concurrent requests both pass the app check simultaneously, the DB constraint will reject the second insert. Catch the unique constraint violation and return the existing transaction (see ADR-001 for handling details).

---

## Files to Touch

| Action | File | Notes |
|---|---|---|
| modify | `src/services/PaymentService.ts` | Add idempotency guard to `charge()` method |
| modify | `src/services/__tests__/PaymentService.test.ts` | Add 3 new test cases |

---

## Acceptance Criteria

- [ ] When `charge()` is called with an `idempotency_key` that matches an existing transaction, the existing transaction is returned and Stripe is NOT called
- [ ] When `charge()` is called with a new `idempotency_key`, charge proceeds normally
- [ ] When `charge()` is called without an `idempotency_key`, charge proceeds normally (key is optional per PRD)
- [ ] A duplicate-key DB error from the unique constraint is caught and handled (returns existing transaction, does not surface as 500)

---

## Test Requirements

- [ ] Unit: returns existing transaction when `idempotency_key` matches — verify `stripeChargeMock` NOT called
- [ ] Unit: proceeds with new charge when `idempotency_key` is new
- [ ] Unit: proceeds with new charge when `idempotency_key` is undefined
- [ ] Unit: handles DB unique constraint violation gracefully

---

## Dependencies

- Depends on: 001 (migration), 002 (repository method)
- Blocks: 004 (charge endpoint), 006 (integration tests)

---

## Implementation Notes

- Follow the `SubscriptionService.createSubscription()` pattern for service-layer idempotency (see `src/services/SubscriptionService.ts:L88`)
- Do NOT add logging inside the idempotency check — the audit log is written by a separate step in `charge()` after the guard
