CREATE TABLE users (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fullname VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  address TEXT,
  dob DATE,
  phone_number VARCHAR(30),
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

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
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE orders (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  shipping_address TEXT NOT NULL,
  receipt_s3_key TEXT,
  ordered_at TIMESTAMP NOT NULL DEFAULT now(),
  status_updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

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

INSERT INTO users (fullname, username, email, password_hash, role)
VALUES ('Admin', 'admin', 'admin@onyx.com',
'$2a$11$rBnqKvmZLDzQr9G1dXQpxeKzO8NqNUh6V0Z3fMqOvKpBHV8Q7YPNG', 'admin');

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
