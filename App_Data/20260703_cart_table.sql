BEGIN;

CREATE TABLE IF NOT EXISTS cart (
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

COMMIT;
