BEGIN;

CREATE TABLE IF NOT EXISTS public.product_images (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  image_path TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_product_images_product_order
  ON public.product_images (product_id, display_order, id);

INSERT INTO public.product_images (product_id, image_path, display_order, is_primary)
SELECT p.id, p.image_url, 0, true
FROM public.products p
WHERE p.image_url IS NOT NULL
  AND btrim(p.image_url) <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM public.product_images pi
    WHERE pi.product_id = p.id
  );

WITH ranked AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY product_id
      ORDER BY is_primary DESC, display_order ASC, id ASC
    ) AS row_number
  FROM public.product_images
)
UPDATE public.product_images pi
SET is_primary = (ranked.row_number = 1)
FROM ranked
WHERE ranked.id = pi.id;

CREATE UNIQUE INDEX IF NOT EXISTS ux_product_images_single_primary
  ON public.product_images (product_id)
  WHERE is_primary;

UPDATE public.products p
SET image_url = pi.image_path
FROM public.product_images pi
WHERE pi.product_id = p.id
  AND pi.is_primary = true;

COMMIT;
