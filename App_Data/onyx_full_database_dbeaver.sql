BEGIN;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fullname VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  address TEXT,
  dob DATE,
  phone_number VARCHAR(30),
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  auth_provider VARCHAR(30) NOT NULL DEFAULT 'local',
  google_sub VARCHAR(255),
  google_email_verified BOOLEAN NOT NULL DEFAULT false,
  avatar_url TEXT,
  last_login_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_google_sub
  ON users (google_sub)
  WHERE google_sub IS NOT NULL;

CREATE TABLE IF NOT EXISTS products (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  brand VARCHAR(50),
  category VARCHAR(50) NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  stock_qty INTEGER NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  image_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS product_variants (
  product_variant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL,
  variant_type VARCHAR(50) NOT NULL,
  variant_value VARCHAR(100) NOT NULL,
  variant_price NUMERIC(10,2) NOT NULL CHECK (variant_price >= 0),
  stock_qty INTEGER NOT NULL CHECK (stock_qty >= 0),
  image_url TEXT,
  CONSTRAINT fk_product_variants_product
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT ux_product_variants_product_variant
    UNIQUE (product_id, product_variant_id)
);

CREATE INDEX IF NOT EXISTS ix_product_variants_product_id
  ON product_variants (product_id);

CREATE TABLE IF NOT EXISTS auth_rate_limits (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  scope VARCHAR(40) NOT NULL,
  identifier VARCHAR(255) NOT NULL,
  action VARCHAR(50) NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  window_start TIMESTAMPTZ NOT NULL DEFAULT now(),
  locked_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT ux_auth_rate_limits_scope_identifier_action
    UNIQUE (scope, identifier, action)
);

CREATE INDEX IF NOT EXISTS ix_auth_rate_limits_identifier
  ON auth_rate_limits (identifier);

CREATE INDEX IF NOT EXISTS ix_auth_rate_limits_locked_until
  ON auth_rate_limits (locked_until)
  WHERE locked_until IS NOT NULL;

CREATE TABLE IF NOT EXISTS pending_registrations (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fullname VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  address TEXT,
  dob DATE,
  phone_number VARCHAR(30),
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  otp_hash VARCHAR(64) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_pending_registrations_email_expires
  ON pending_registrations (email, expires_at);

CREATE INDEX IF NOT EXISTS ix_pending_registrations_username_expires
  ON pending_registrations (username, expires_at);

CREATE TABLE IF NOT EXISTS user_oauth_accounts (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  provider VARCHAR(30) NOT NULL,
  provider_user_id VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  email_verified BOOLEAN NOT NULL DEFAULT false,
  display_name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,
  CONSTRAINT fk_user_oauth_accounts_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT ux_user_oauth_provider_user
    UNIQUE (provider, provider_user_id)
);

CREATE INDEX IF NOT EXISTS ix_user_oauth_accounts_user_id
  ON user_oauth_accounts (user_id);

CREATE TABLE IF NOT EXISTS user_personalization_profiles (
  user_id BIGINT PRIMARY KEY,
  gaming_style VARCHAR(40) NOT NULL,
  preferred_categories TEXT NOT NULL,
  priorities TEXT NOT NULL,
  budget_range VARCHAR(40) NOT NULL,
  setup_goal VARCHAR(60) NOT NULL,
  comfort_preferences TEXT NOT NULL DEFAULT '',
  performance_preferences TEXT NOT NULL DEFAULT '',
  setup_constraints TEXT NOT NULL DEFAULT '',
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_user_personalization_profiles_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_personalization_completed
  ON user_personalization_profiles (completed_at);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  token_hash VARCHAR(64) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_password_reset_tokens_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_password_reset_tokens_user_active
  ON password_reset_tokens (user_id, expires_at)
  WHERE used_at IS NULL;

CREATE INDEX IF NOT EXISTS ix_password_reset_tokens_token_active
  ON password_reset_tokens (token_hash)
  WHERE used_at IS NULL;

CREATE TABLE IF NOT EXISTS cart (
  cart_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  product_variant_id BIGINT,
  variant_key BIGINT GENERATED ALWAYS AS (COALESCE(product_variant_id, 0)) STORED,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT fk_cart_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_product
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_product_variant
    FOREIGN KEY (product_id, product_variant_id)
    REFERENCES product_variants(product_id, product_variant_id)
    ON DELETE CASCADE,
  CONSTRAINT ux_cart_user_product_variant
    UNIQUE (user_id, product_id, variant_key)
);

CREATE INDEX IF NOT EXISTS ix_cart_user_id
  ON cart (user_id);

CREATE INDEX IF NOT EXISTS ix_cart_product_id
  ON cart (product_id);

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending_payment',
  total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
  shipping_address TEXT NOT NULL,
  delivery_method VARCHAR(50),
  checkout_attempt_token TEXT,
  payment_cancel_token_hash TEXT,
  stripe_checkout_session_id TEXT,
  stripe_payment_intent_id TEXT,
  payment_method VARCHAR(100),
  payment_expires_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  receipt_s3_key TEXT,
  ordered_at TIMESTAMP NOT NULL DEFAULT now(),
  status_updated_at TIMESTAMP,
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS ix_orders_user_id
  ON orders (user_id);

CREATE INDEX IF NOT EXISTS ix_orders_status_ordered_at
  ON orders (status, ordered_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_stripe_checkout_session
  ON orders (stripe_checkout_session_id)
  WHERE stripe_checkout_session_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_active_checkout_attempt
  ON orders (checkout_attempt_token)
  WHERE checkout_attempt_token IS NOT NULL
    AND status = 'pending_payment';

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_payment_cancel_token_hash
  ON orders (payment_cancel_token_hash)
  WHERE payment_cancel_token_hash IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_stripe_payment_intent
  ON orders (stripe_payment_intent_id)
  WHERE stripe_payment_intent_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  product_variant_id BIGINT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  subtotal NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT fk_order_items_product_variant
    FOREIGN KEY (product_id, product_variant_id)
    REFERENCES product_variants(product_id, product_variant_id)
);

CREATE INDEX IF NOT EXISTS ix_order_items_order_id
  ON order_items (order_id);

CREATE INDEX IF NOT EXISTS ix_order_items_product_id
  ON order_items (product_id);

CREATE TABLE IF NOT EXISTS stock_reservations (
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
  CONSTRAINT fk_stock_reservations_order
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_reservations_product
    FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT fk_stock_reservations_product_variant
    FOREIGN KEY (product_id, product_variant_id)
    REFERENCES product_variants(product_id, product_variant_id),
  CONSTRAINT ux_stock_reservations_order_product_variant
    UNIQUE (order_id, product_id, variant_key)
);

CREATE INDEX IF NOT EXISTS ix_stock_reservations_availability
  ON stock_reservations (product_id, variant_key, status, expires_at);

CREATE INDEX IF NOT EXISTS ix_stock_reservations_order_id
  ON stock_reservations (order_id);

CREATE TABLE IF NOT EXISTS stripe_events (
  stripe_event_id TEXT PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reviews (
  review_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT fk_reviews_user
    FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_reviews_product
    FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT ux_reviews_user_product
    UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS ix_reviews_product_id
  ON reviews (product_id);

CREATE TABLE IF NOT EXISTS wishlists (
  wishlist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  added_at TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT fk_wishlists_user
    FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_wishlists_product
    FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT ux_wishlists_user_product
    UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS ix_wishlists_product_id
  ON wishlists (product_id);

CREATE TABLE IF NOT EXISTS catalog_search_events (
  catalog_search_event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  search_term TEXT NOT NULL,
  inferred_category VARCHAR(50),
  searched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_catalog_search_events_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_catalog_search_events_user_time
  ON catalog_search_events (user_id, searched_at DESC);

CREATE INDEX IF NOT EXISTS idx_catalog_search_events_user_category
  ON catalog_search_events (user_id, inferred_category)
  WHERE inferred_category IS NOT NULL;

INSERT INTO users (fullname, username, email, password_hash, role)
VALUES (
  'Admin',
  'admin',
  'admin@onyx.com',
  '$2a$11$FYR4Rhbh92HnhCgO7qLhqesjfb.BJwLu.ZpwRVqEh4T4b/kyv.QAy',
  'admin'
)
ON CONFLICT DO NOTHING;

COMMIT;
