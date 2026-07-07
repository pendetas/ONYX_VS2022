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

INSERT INTO products (name, brand, category, price, stock_qty, description)
VALUES
('Viper V2 Pro', 'Razer', 'Mouse', 599.00, 23, 'Ultra-lightweight wireless gaming mouse'),
('BlackWidow V3', 'Razer', 'Keyboard', 449.00, 15, 'Mechanical gaming keyboard with Razer Green switches'),
('Kraken X', 'Razer', 'Headset', 299.00, 31, '7.1 surround sound gaming headset'),
('DeathAdder V3', 'Razer', 'Mouse', 349.00, 4, 'Ergonomic wired gaming mouse'),
('Huntsman Mini', 'Razer', 'Keyboard', 529.00, 10, '60% compact gaming keyboard'),
('Predator XB273U', 'Acer', 'Monitor', 1899.00, 8, '27-inch 165Hz IPS gaming monitor'),
('Secretlab Titan', 'Secretlab', 'Chair', 2199.00, 5, 'Ergonomic gaming chair with lumbar support'),
('G502 X Plus', 'Logitech', 'Mouse', 499.00, 18, 'HERO sensor wireless gaming mouse');
