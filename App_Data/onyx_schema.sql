CREATE TABLE users (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fullname VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  address TEXT,
  dob DATE,
  phone_number VARCHAR(30),
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX ux_users_username_ci
  ON users (LOWER(username));

CREATE UNIQUE INDEX ux_users_email_ci
  ON users (LOWER(email));

CREATE TABLE user_oauth_accounts (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider VARCHAR(30) NOT NULL,
  provider_user_id VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  email_verified BOOLEAN NOT NULL DEFAULT false,
  display_name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,
  CONSTRAINT ux_user_oauth_provider_user UNIQUE (provider, provider_user_id)
);

CREATE INDEX ix_user_oauth_accounts_user_id
  ON user_oauth_accounts (user_id);

CREATE TABLE password_reset_tokens (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(64) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ix_password_reset_tokens_user_active
  ON password_reset_tokens (user_id, expires_at)
  WHERE used_at IS NULL;

CREATE INDEX ix_password_reset_tokens_token_active
  ON password_reset_tokens (token_hash)
  WHERE used_at IS NULL;


CREATE TABLE auth_rate_limits (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  action VARCHAR(50) NOT NULL,
  identity_key VARCHAR(320) NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  window_started_at TIMESTAMP NOT NULL,
  blocked_until TIMESTAMP,
  last_attempt_at TIMESTAMP NOT NULL,
  UNIQUE (action, identity_key)
);

CREATE INDEX ix_auth_rate_limits_blocked_until
  ON auth_rate_limits (blocked_until);

CREATE TABLE products (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  brand VARCHAR(50),
  category VARCHAR(50) NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL,
  stock_qty INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE product_variants (
  product_variant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL,
  variant_type VARCHAR(50) NOT NULL,
  variant_value VARCHAR(100) NOT NULL,
  variant_price NUMERIC(10,2) NOT NULL,
  stock_qty INTEGER NOT NULL,
  image_url TEXT,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT ux_product_variants_product_variant
    UNIQUE (product_id, product_variant_id)
);

CREATE TABLE product_images (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  image_path TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX ix_product_images_product_order
  ON product_images (product_id, display_order, id);

CREATE UNIQUE INDEX ux_product_images_single_primary
  ON product_images (product_id)
  WHERE is_primary;

CREATE TABLE product_campaigns (
  product_id BIGINT PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
  campaign_enabled BOOLEAN NOT NULL DEFAULT false,
  hero_eyebrow VARCHAR(120),
  hero_headline VARCHAR(180),
  hero_body TEXT,
  hero_image_url TEXT,
  overview_eyebrow VARCHAR(120),
  overview_headline VARCHAR(180),
  overview_body TEXT,
  performance_eyebrow VARCHAR(120),
  performance_headline VARCHAR(180),
  performance_body TEXT,
  feature_cards TEXT,
  specs_text TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE product_campaign_blocks (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  block_type VARCHAR(50) NOT NULL,
  sort_order INTEGER NOT NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  eyebrow VARCHAR(100),
  headline VARCHAR(200),
  body TEXT,
  media_type VARCHAR(20),
  media_url TEXT,
  media_alt VARCHAR(200),
  layout_variant VARCHAR(50),
  background_variant VARCHAR(50),
  json_content TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP
);

CREATE INDEX ix_product_campaign_blocks_product_sort
  ON product_campaign_blocks (product_id, sort_order, id);

CREATE TABLE cart (
  cart_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  product_variant_id BIGINT,
  variant_key BIGINT GENERATED ALWAYS AS (COALESCE(product_variant_id, 0)) STORED,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (product_variant_id) REFERENCES product_variants(product_variant_id) ON DELETE CASCADE,
  UNIQUE (user_id, product_id, variant_key)
);

CREATE TABLE orders (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending_payment',
  total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  subtotal_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  voucher_id BIGINT,
  voucher_code VARCHAR(40),
  voucher_name VARCHAR(120),
  shipping_address TEXT NOT NULL,
  delivery_method VARCHAR(50),
  checkout_attempt_token TEXT,
  payment_cancel_token_hash TEXT,
  stripe_checkout_session_id TEXT,
  stripe_payment_intent_id TEXT,
  payment_method VARCHAR(100),
  payment_expires_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  checkout_success_email_sent_at TIMESTAMPTZ,
  receipt_s3_key TEXT,
  ordered_at TIMESTAMP NOT NULL DEFAULT now(),
  status_updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE UNIQUE INDEX ux_orders_stripe_checkout_session
  ON orders (stripe_checkout_session_id)
  WHERE stripe_checkout_session_id IS NOT NULL;

CREATE UNIQUE INDEX ux_orders_active_checkout_attempt
  ON orders (checkout_attempt_token)
  WHERE checkout_attempt_token IS NOT NULL
    AND status = 'pending_payment';

CREATE UNIQUE INDEX ux_orders_payment_cancel_token_hash
  ON orders (payment_cancel_token_hash)
  WHERE payment_cancel_token_hash IS NOT NULL;

CREATE UNIQUE INDEX ux_orders_stripe_payment_intent
  ON orders (stripe_payment_intent_id)
  WHERE stripe_payment_intent_id IS NOT NULL;

CREATE TABLE vouchers (
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

CREATE UNIQUE INDEX ux_vouchers_code_ci
  ON vouchers (LOWER(code));

CREATE INDEX ix_vouchers_active_dates
  ON vouchers (is_active, valid_from, expires_at)
  WHERE archived_at IS NULL;

CREATE TABLE voucher_categories (
  voucher_id BIGINT NOT NULL REFERENCES vouchers(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL,
  PRIMARY KEY (voucher_id, category)
);

CREATE TABLE voucher_redemptions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  voucher_id BIGINT NOT NULL REFERENCES vouchers(id),
  user_id BIGINT NOT NULL REFERENCES users(id),
  order_id BIGINT NOT NULL REFERENCES orders(id),
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

CREATE INDEX ix_voucher_redemptions_voucher_status
  ON voucher_redemptions (voucher_id, status);

CREATE INDEX ix_voucher_redemptions_user_status
  ON voucher_redemptions (voucher_id, user_id, status);

ALTER TABLE orders
  ADD CONSTRAINT fk_orders_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers(id);

CREATE TABLE order_items (
  order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  product_variant_id BIGINT,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (product_variant_id) REFERENCES product_variants(product_variant_id)
);

CREATE TABLE stock_reservations (
  reservation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  product_variant_id BIGINT,
  variant_key BIGINT GENERATED ALWAYS AS (COALESCE(product_variant_id, 0)) STORED,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'completed', 'released')),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT fk_stock_reservations_product_variant
    FOREIGN KEY (product_id, product_variant_id)
    REFERENCES product_variants(product_id, product_variant_id),
  UNIQUE (order_id, product_id, variant_key)
);

CREATE INDEX ix_stock_reservations_availability
  ON stock_reservations (product_id, variant_key, status, expires_at);

CREATE TABLE stripe_events (
  stripe_event_id TEXT PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE reviews (
  review_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE (user_id, product_id)
);

CREATE TABLE wishlists (
  wishlist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  added_at TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE (user_id, product_id)
);

CREATE TABLE user_personalization_profiles (
  user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  gaming_style VARCHAR(40) NOT NULL,
  preferred_categories TEXT NOT NULL,
  priorities TEXT NOT NULL,
  budget_range VARCHAR(40) NOT NULL,
  setup_goal VARCHAR(60) NOT NULL,
  comfort_preferences TEXT NOT NULL DEFAULT '',
  performance_preferences TEXT NOT NULL DEFAULT '',
  setup_constraints TEXT NOT NULL DEFAULT '',
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_personalization_completed
  ON user_personalization_profiles (completed_at);

CREATE TABLE catalog_search_events (
  catalog_search_event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  search_term TEXT NOT NULL,
  inferred_category VARCHAR(50),
  searched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_catalog_search_events_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_catalog_search_events_user_time
  ON catalog_search_events (user_id, searched_at DESC);

CREATE INDEX idx_catalog_search_events_user_category
  ON catalog_search_events (user_id, inferred_category)
  WHERE inferred_category IS NOT NULL;

INSERT INTO users (fullname, username, email, password_hash, role)
VALUES ('Admin', 'admin', 'admin@onyx.com',
'$2a$11$FYR4Rhbh92HnhCgO7qLhqesjfb.BJwLu.ZpwRVqEh4T4b/kyv.QAy', 'admin');

