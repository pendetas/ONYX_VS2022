BEGIN;

CREATE TABLE IF NOT EXISTS vouchers (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(40) NOT NULL,
  discount_type VARCHAR(20) NOT NULL,
  discount_value NUMERIC(10,2) NOT NULL,
  maximum_discount_amount NUMERIC(10,2),
  minimum_purchase_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  applies_to_all_categories BOOLEAN NOT NULL DEFAULT true,
  valid_from TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  total_usage_limit INTEGER,
  per_user_usage_limit INTEGER NOT NULL DEFAULT 1,
  is_active BOOLEAN NOT NULL DEFAULT true,
  terms_and_conditions TEXT NOT NULL,
  created_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  CONSTRAINT ck_vouchers_discount_type
    CHECK (discount_type IN ('percentage', 'fixed')),
  CONSTRAINT ck_vouchers_discount_value
    CHECK (discount_value > 0 AND (discount_type <> 'percentage' OR discount_value <= 100)),
  CONSTRAINT ck_vouchers_maximum_discount
    CHECK (
      (discount_type = 'fixed' AND maximum_discount_amount IS NULL) OR
      (discount_type = 'percentage' AND (maximum_discount_amount IS NULL OR maximum_discount_amount > 0))
    ),
  CONSTRAINT ck_vouchers_minimum_purchase CHECK (minimum_purchase_amount >= 0),
  CONSTRAINT ck_vouchers_validity CHECK (expires_at > valid_from),
  CONSTRAINT ck_vouchers_total_limit CHECK (total_usage_limit IS NULL OR total_usage_limit > 0),
  CONSTRAINT ck_vouchers_user_limit CHECK (per_user_usage_limit > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_vouchers_code_ci ON vouchers (LOWER(code));
CREATE INDEX IF NOT EXISTS ix_vouchers_active_dates
  ON vouchers (is_active, valid_from, expires_at)
  WHERE archived_at IS NULL;

CREATE TABLE IF NOT EXISTS voucher_categories (
  voucher_id BIGINT NOT NULL REFERENCES vouchers(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL,
  PRIMARY KEY (voucher_id, category)
);

CREATE TABLE IF NOT EXISTS voucher_redemptions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  voucher_id BIGINT NOT NULL REFERENCES vouchers(id),
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  eligible_subtotal NUMERIC(10,2) NOT NULL CHECK (eligible_subtotal >= 0),
  discount_amount NUMERIC(10,2) NOT NULL CHECK (discount_amount > 0),
  status VARCHAR(20) NOT NULL,
  reserved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  redeemed_at TIMESTAMPTZ,
  released_at TIMESTAMPTZ,
  CONSTRAINT ux_voucher_redemptions_order UNIQUE (order_id),
  CONSTRAINT ck_voucher_redemptions_status
    CHECK (status IN ('pending', 'redeemed', 'released'))
);

CREATE INDEX IF NOT EXISTS ix_voucher_redemptions_voucher_status
  ON voucher_redemptions (voucher_id, status);
CREATE INDEX IF NOT EXISTS ix_voucher_redemptions_user_status
  ON voucher_redemptions (voucher_id, user_id, status);

ALTER TABLE voucher_redemptions DROP CONSTRAINT IF EXISTS voucher_redemptions_user_id_fkey;
ALTER TABLE voucher_redemptions DROP CONSTRAINT IF EXISTS voucher_redemptions_order_id_fkey;
ALTER TABLE voucher_redemptions DROP CONSTRAINT IF EXISTS fk_voucher_redemptions_user;
ALTER TABLE voucher_redemptions DROP CONSTRAINT IF EXISTS fk_voucher_redemptions_order;
ALTER TABLE voucher_redemptions
  ADD CONSTRAINT fk_voucher_redemptions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_voucher_redemptions_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal_amount NUMERIC(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_amount NUMERIC(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS voucher_id BIGINT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS voucher_code VARCHAR(40);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS voucher_name VARCHAR(120);

UPDATE orders
SET subtotal_amount = total_amount
WHERE subtotal_amount IS NULL;

UPDATE orders
SET discount_amount = 0
WHERE discount_amount IS NULL;

ALTER TABLE orders ALTER COLUMN subtotal_amount SET DEFAULT 0;
ALTER TABLE orders ALTER COLUMN subtotal_amount SET NOT NULL;
ALTER TABLE orders ALTER COLUMN discount_amount SET DEFAULT 0;
ALTER TABLE orders ALTER COLUMN discount_amount SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_orders_voucher'
  ) THEN
    ALTER TABLE orders
      ADD CONSTRAINT fk_orders_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers(id);
  END IF;
END $$;

COMMIT;
