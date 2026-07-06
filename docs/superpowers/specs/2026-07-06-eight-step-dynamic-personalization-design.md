# Eight-Step Dynamic Personalization Design

## Goal

Upgrade ONYX personalization from a five-question static profile into an eight-question profile plus dynamic behavior signals. The catalog and home recommendations should update per user using saved questionnaire answers, order history, wishlist history, and recent search behavior.

## Scope

This design covers the customer personalization questionnaire, profile storage, recommendation scoring, catalog sorting, and search boost reliability. It does not redesign the visual style beyond preserving the existing monochrome one-question-per-page onboarding.

## Questionnaire

The page remains a stepper with one question per page and a progress bar. It expands from five to eight steps:

1. Play style: FPS, MOBA, RPG, Racing, Casual, Creator. Multi-select.
2. Gear focus: Mouse, Keyboard, Headset, Monitor, Accessory, Mic, Mousepad, Cable, Monitor Extension. Multi-select.
3. Buying priority: Speed, Comfort, Wireless, Budget, RGB, Premium Build. Multi-select.
4. Budget range: Entry, Mid-range, Premium. Single-select.
5. Setup goal: Competitive, Streaming, Work and Gaming, Everyday Gaming. Single-select.
6. Comfort preference: Lightweight gear, Ergonomic shape, Soft ear cushions, Wrist support, Adjustable size, Low noise. Multi-select.
7. Performance preference: Low latency, High DPI, Mechanical switches, Noise cancellation, High refresh rate, Long battery life, Accurate tracking. Multi-select.
8. Setup constraint: Small hands, Compact desk, Long sessions, Shared room, Streaming setup, Minimal desk. Multi-select.

Every answer is stored in the database so the user can be ranked consistently across home and catalog.

## Data Model

Add real columns to `user_personalization_profiles`:

- `comfort_preferences TEXT NOT NULL DEFAULT ''`
- `performance_preferences TEXT NOT NULL DEFAULT ''`
- `setup_constraints TEXT NOT NULL DEFAULT ''`

The model adds matching list properties. Repository reads/writes these fields, while older rows remain valid through defaults.

Behavior data stays dynamic:

- Orders continue to influence purchased-category signals.
- Wishlists continue to influence saved-category signals.
- Catalog searches are recorded in `catalog_search_events`.
- A session/cookie recent-search fallback is added for immediate boost when DB readback is unavailable or delayed.

## Recommendation Ranking

The ranking pipeline keeps one source of truth: `PersonalizationService`.

Base score signals:

- Preferred category: strong boost.
- Play style match: medium boost per matching style.
- Buying priority: medium/strong boost.
- Comfort preference: medium boost based on product category and searchable product text.
- Performance preference: medium boost based on product category and searchable product text.
- Setup constraint: medium boost based on category and searchable product text.
- Wishlist category: small/medium boost.
- Search behavior: medium boost, repeated searches increase the strength up to a cap.
- Order history: strongest behavior boost, repeated purchases increase the strength up to a cap.
- Budget fit: boost when product price is inside the chosen budget range.

Tie-breaking changes by price intent:

- Entry or Budget priority: after score, sort lower prices first.
- Premium or Premium Build priority: after score, sort higher prices first.
- Mid-range/default: after score, sort by closer budget fit, then name/id.

This means personalized relevance still wins first, but price direction decides close matches.

## Search Boost Fix

Search should affect recommendations immediately and over time.

Implementation design:

- Record logged-in catalog searches to `catalog_search_events`.
- Also store a small recent-search signal in session/cookie for immediate ranking during the same request/session.
- Infer categories from broader terms: keyboard, keycap, switch, mouse, mice, headset, headphone, audio, mic, microphone, monitor, display, screen, mousepad, pad, cable, wire, accessory, desk, chair, monitor extension, arm, mount.
- If the search table is missing, trace a clear warning and still use session/cookie fallback.
- Current search term should also be converted into a temporary signal for the current recommended catalog response.

Example: if a user chose Racing but repeatedly searches `keyboard`, keyboard products should rise in the catalog because behavior is a live signal.

## Catalog Behavior

For signed-in users opening Shop All with no explicit sort:

- Default sort remains `recommended`.
- Recommended catalog ranks filtered candidates through `PersonalizationService`.
- If a user explicitly selects `price-asc`, `price-desc`, `name`, or another supported sort, that explicit sort wins.
- Search results remain searchable by normal text fields, but recommended order inside those results uses the profile plus live search signals.

## Error Handling

- Missing optional behavior tables should not break catalog/home.
- Missing core profile table should still show the existing generic personalization error on save.
- Invalid or empty required answers should show validation feedback and keep the user on the relevant step.
- Search recording failures should be traced, not shown to customers.

## Testing

Add or extend source-contract tests for:

- Eight personalization steps and updated progress count.
- New hidden fields and code-behind save mapping.
- Profile schema/model/repository support for comfort, performance, and setup constraints.
- Budget sorting direction in recommendation ranking.
- Search category inference for new categories.
- Recommended catalog includes live search/session signal handling.

Run the project build after implementation.
