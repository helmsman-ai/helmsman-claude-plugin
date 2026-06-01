# Example: Tech Design — payments-v2 (excerpt)

> Abbreviated example showing the key sections of a well-formed Stage 04 output.

---

## 1. Overview

We are adding a native `/charge` endpoint to `payments-service` that supports saved cards and wallet balance. The key architectural decision is idempotency storage: we will use a database-level unique constraint on `idempotency_key` combined with an application-layer pre-check, rather than relying solely on Stripe's idempotency API. This gives us full audit trail ownership and works even if we switch payment providers.

---

## 4. Component Design

### `ChargeController` (new)
- **Purpose**: HTTP boundary — validates input, delegates to `PaymentService`
- **Layer**: Controller (`src/controllers/`)
- **Inputs**: `{ amount, currency, payment_method_id, idempotency_key, user_id }`
- **Outputs**: `{ transaction_id, status, amount_charged }` or error

### `PaymentService` (modified)
- **Purpose**: Orchestrates idempotency check → Stripe charge → audit log write
- **Layer**: Service (`src/services/`)
- **Key change**: add `charge()` method with idempotency guard

### `TransactionRepository` (modified)
- **Purpose**: DB access for `transactions` table
- **New method**: `findByIdempotencyKey(key: string): Transaction | null`

---

## 5. Data Model

```sql
-- Add to transactions table
ALTER TABLE transactions
  ADD COLUMN idempotency_key VARCHAR(64),
  ADD UNIQUE INDEX idx_transactions_idempotency_key (idempotency_key);

-- New audit table
CREATE TABLE payment_audit_log (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  transaction_id BIGINT NOT NULL REFERENCES transactions(id),
  event_type  VARCHAR(32) NOT NULL,  -- 'charge_initiated', 'charge_succeeded', 'charge_failed'
  payload     JSON,
  created_at  TIMESTAMP DEFAULT NOW()
);
```

**Migration**: Non-destructive. `idempotency_key` is NULLABLE initially; backfill not required. Deploy migration before deploying code.

---

## 6. API / Interface Contracts

### `POST /api/payments/charge`

**Request**
```json
{
  "amount": 4999,
  "currency": "USD",
  "payment_method": { "type": "saved_card", "id": "pm_abc123" },
  "idempotency_key": "order-789-attempt-1"
}
```

**Response 200**
```json
{ "transaction_id": 42, "status": "succeeded", "amount_charged": 4999 }
```

**Response 402** (card declined)
```json
{ "error": { "code": "card_declined", "message": "Your card was declined." } }
```

**Response 409** (idempotency replay — same key, same result returned)
```json
{ "transaction_id": 42, "status": "succeeded", "amount_charged": 4999, "replayed": true }
```

---

## 13. ADRs

| # | Decision | Link |
|---|---|---|
| ADR-001 | Store idempotency in our DB, not Stripe-only | [adrs/001-idempotency-storage.md](adrs/001-idempotency-storage.md) |
| ADR-002 | Synchronous charge flow (no queue) for MVP | [adrs/002-sync-charge-flow.md](adrs/002-sync-charge-flow.md) |

---

## 14. Open Implementation Questions

- [ ] `idempotency_key` max length: schema says 64 chars — should the controller reject longer keys with 400 or truncate? (recommend: reject with 400)
- [ ] Wallet partial-debit scenario: if wallet has $30 and charge is $50, fail entirely or charge $30 from wallet + $20 from card? (PRD Q-02 still open — implement fail-entirely as default)
