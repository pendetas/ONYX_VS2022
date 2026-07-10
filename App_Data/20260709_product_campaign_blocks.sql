BEGIN;

CREATE TABLE IF NOT EXISTS public.product_campaign_blocks (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
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

CREATE INDEX IF NOT EXISTS ix_product_campaign_blocks_product_sort
  ON public.product_campaign_blocks (product_id, sort_order, id);

COMMIT;
