-- Assign the current transparent product assets to existing products.
-- The version query parameter forces browsers to request the replaced PNG files
-- instead of displaying previously cached black-background versions.

BEGIN;

UPDATE products
SET image_url =
    CASE
        WHEN LOWER(TRIM(category)) = 'keyboard'
            THEN '/Content/home/products/onyx-keyboard.png?v=20260612'
        WHEN LOWER(TRIM(category)) = 'headset'
            THEN '/Content/home/products/onyx-headset.png?v=20260612'
        WHEN LOWER(TRIM(category)) = 'monitor'
            THEN '/Content/home/products/onyx-monitor.png?v=20260612'
        WHEN LOWER(TRIM(category)) = 'accessory'
             AND (
                 LOWER(name) LIKE '%cable%'
                 OR LOWER(name) LIKE '%key%'
             )
            THEN '/Content/home/products/onyx-keyboard.png?v=20260612'
        ELSE '/Content/home/products/onyx-mouse.png?v=20260612'
    END;

COMMIT;

SELECT id, name, category, image_url
FROM products
ORDER BY id;
