BEGIN;

ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS delivery_method VARCHAR(50),
    ADD COLUMN IF NOT EXISTS checkout_attempt_token TEXT,
    ADD COLUMN IF NOT EXISTS payment_cancel_token_hash TEXT,
    ADD COLUMN IF NOT EXISTS stripe_checkout_session_id TEXT,
    ADD COLUMN IF NOT EXISTS stripe_payment_intent_id TEXT,
    ADD COLUMN IF NOT EXISTS payment_method VARCHAR(100),
    ADD COLUMN IF NOT EXISTS payment_expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS paid_at TIMESTAMPTZ;

ALTER TABLE orders
    ALTER COLUMN status SET DEFAULT 'pending_payment';

-- Existing foundation timestamps were written as UTC without an attached zone.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'orders'
          AND column_name = 'payment_expires_at'
          AND data_type = 'timestamp without time zone'
    ) THEN
        ALTER TABLE orders
            ALTER COLUMN payment_expires_at TYPE TIMESTAMPTZ
            USING payment_expires_at AT TIME ZONE 'UTC';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'orders'
          AND column_name = 'paid_at'
          AND data_type = 'timestamp without time zone'
    ) THEN
        ALTER TABLE orders
            ALTER COLUMN paid_at TYPE TIMESTAMPTZ
            USING paid_at AT TIME ZONE 'UTC';
    END IF;
END
$$;

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_stripe_checkout_session
    ON orders (stripe_checkout_session_id)
    WHERE stripe_checkout_session_id IS NOT NULL;

UPDATE orders
SET checkout_attempt_token = 'legacy-' || id
WHERE status = 'pending_payment'
  AND checkout_attempt_token IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_active_checkout_attempt
    ON orders (checkout_attempt_token)
    WHERE checkout_attempt_token IS NOT NULL
      AND status = 'pending_payment';

UPDATE orders
SET payment_cancel_token_hash = NULL
WHERE status <> 'pending_payment'
  AND payment_cancel_token_hash IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_payment_cancel_token_hash
    ON orders (payment_cancel_token_hash)
    WHERE payment_cancel_token_hash IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_stripe_payment_intent
    ON orders (stripe_payment_intent_id)
    WHERE stripe_payment_intent_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS stock_reservations (
    reservation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id),
    product_variant_id BIGINT,
    variant_key BIGINT GENERATED ALWAYS AS (COALESCE(product_variant_id, 0)) STORED,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'completed', 'released')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (order_id, product_id, variant_key)
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'stock_reservations'
          AND column_name = 'expires_at'
          AND data_type = 'timestamp without time zone'
    ) THEN
        ALTER TABLE stock_reservations
            ALTER COLUMN expires_at TYPE TIMESTAMPTZ
            USING expires_at AT TIME ZONE 'UTC';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'stock_reservations'
          AND column_name = 'created_at'
          AND data_type = 'timestamp without time zone'
    ) THEN
        ALTER TABLE stock_reservations
            ALTER COLUMN created_at TYPE TIMESTAMPTZ
            USING created_at AT TIME ZONE 'UTC';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'product_variants'::regclass
          AND conname = 'ux_product_variants_product_variant'
    ) THEN
        ALTER TABLE product_variants
            ADD CONSTRAINT ux_product_variants_product_variant
            UNIQUE (product_id, product_variant_id);
    END IF;

    ALTER TABLE stock_reservations
        DROP CONSTRAINT IF EXISTS stock_reservations_product_variant_id_fkey;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'stock_reservations'::regclass
          AND conname = 'fk_stock_reservations_product_variant'
    ) THEN
        ALTER TABLE stock_reservations
            ADD CONSTRAINT fk_stock_reservations_product_variant
            FOREIGN KEY (product_id, product_variant_id)
            REFERENCES product_variants(product_id, product_variant_id);
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS ix_stock_reservations_availability
    ON stock_reservations (product_id, variant_key, status, expires_at);

CREATE TABLE IF NOT EXISTS stripe_events (
    stripe_event_id TEXT PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'stripe_events'
          AND column_name = 'processed_at'
          AND data_type = 'timestamp without time zone'
    ) THEN
        ALTER TABLE stripe_events
            ALTER COLUMN processed_at TYPE TIMESTAMPTZ
            USING processed_at AT TIME ZONE 'UTC';
    END IF;
END
$$;

COMMIT;
