BEGIN;

LOCK TABLE public.products IN SHARE ROW EXCLUSIVE MODE;

DO $repair_products_identity$
DECLARE
    v_sequence_name TEXT;
    v_max_id BIGINT;
BEGIN
    v_sequence_name := pg_get_serial_sequence('public.products', 'id');
    IF v_sequence_name IS NULL THEN
        RAISE EXCEPTION 'Product identity repair stopped: products.id has no owned sequence.';
    END IF;

    SELECT MAX(id) INTO v_max_id
    FROM public.products;

    PERFORM setval(
        v_sequence_name,
        COALESCE(v_max_id, 1),
        v_max_id IS NOT NULL
    );
END
$repair_products_identity$;

COMMIT;

SELECT MAX(id) AS max_product_id,
       pg_get_serial_sequence('public.products', 'id') AS sequence_name
FROM public.products;
