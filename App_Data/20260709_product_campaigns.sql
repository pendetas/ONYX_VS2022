BEGIN;

CREATE TABLE IF NOT EXISTS public.product_campaigns (
  product_id BIGINT PRIMARY KEY REFERENCES public.products(id) ON DELETE CASCADE,
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

INSERT INTO public.product_campaigns (
  product_id,
  campaign_enabled,
  hero_eyebrow,
  hero_headline,
  hero_body,
  hero_image_url,
  overview_eyebrow,
  overview_headline,
  overview_body,
  performance_eyebrow,
  performance_headline,
  performance_body,
  feature_cards,
  specs_text
)
SELECT
  2,
  true,
  '80HE performance keyboard',
  'Full control without the full-size footprint',
  'The ONYX 80HE keeps the function row and navigation cluster close while giving every key the magnetic control profile competitive players expect.',
  '/Content/home/products/onyx-80he.png',
  'Review',
  'Built for players who still use the extra keys',
  'An 80% layout gives you the familiar command surface for play, editing, and everyday shortcuts while staying tighter than a full-size board.',
  'Unmatched performance',
  'Fast response, tuned control',
  'Hall-effect sensing, rapid reset behavior, and per-key profiles keep repeated inputs predictable across shooters, rhythm games, and long work sessions.',
  'Rapid Trigger|Reset and reactivate keys as soon as movement changes, helping repeated inputs feel immediate.
Adjustable Actuation|Tune each key from feather-light taps to deeper deliberate presses.
80% Control Layout|Keep arrows, navigation, and function keys without surrendering the whole desk.',
  'Layout|80% performance layout
Switch type|Hall-effect magnetic switch platform
Actuation|Adjustable per-key actuation
Profiles|Multiple onboard profiles
Connection|USB-C wired
Lighting|Per-key RGB lighting
Warranty|2-year limited warranty'
WHERE EXISTS (SELECT 1 FROM public.products WHERE id = 2)
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO public.product_campaigns (
  product_id,
  campaign_enabled,
  hero_eyebrow,
  hero_headline,
  hero_body,
  hero_image_url,
  overview_eyebrow,
  overview_headline,
  overview_body,
  performance_eyebrow,
  performance_headline,
  performance_body,
  feature_cards,
  specs_text
)
SELECT
  3,
  true,
  '60HE v2 compact keyboard',
  'Less board, more room to move',
  'The ONYX 60HE v2 strips the layout down for mouse space and travel while preserving the magnetic switch tuning that makes each input feel deliberate.',
  '/Content/home/products/onyx-60he-v2.jpeg',
  'Review',
  'A compact board with a serious control surface',
  'The 60% frame keeps the desk clear and pushes frequent actions into layers, making it a focused fit for low-sensitivity aim and portable setups.',
  'Unmatched performance',
  'Compact speed with exact reset control',
  'Analog actuation and rapid reset make short repeated inputs feel sharp, while onboard profiles keep the compact layout usable across games.',
  'Rapid Trigger|Reset quickly for strafes, peeks, rhythm taps, and repeated movement chains.
Adjustable Actuation|Set shallow or deliberate key travel per profile.
60% Desk Space|A smaller footprint leaves more room for wide mouse movement.',
  'Layout|60% compact performance layout
Switch type|Hall-effect magnetic switch platform
Actuation|Adjustable per-key actuation
Profiles|Multiple onboard profiles
Connection|USB-C wired
Lighting|Per-key RGB lighting
Warranty|2-year limited warranty'
WHERE EXISTS (SELECT 1 FROM public.products WHERE id = 3)
ON CONFLICT (product_id) DO NOTHING;

COMMIT;
