# Dynamic Catalog Personalization Design

## Goal
Signed-in customers should see a personalized catalog by default when opening Shop All. Ranking should learn from saved personalization, order history, wishlist behavior, and catalog searches.

## Behavior
- Anonymous users keep the existing catalog behavior.
- Signed-in customers with completed personalization get recommended ranking when opening `/customer_page/onyx_catalog.aspx` without an explicit sort.
- Manual category/search filters still narrow the result set, then personalization ranks the matching products.
- Non-empty logged-in catalog searches are recorded as lightweight search events.
- Search terms such as `keyboard`, `mouse`, `mice`, `headset`, `audio`, `monitor`, and `accessory` become category signals for future recommendations.

## Scoring
- Saved profile answers remain the base.
- Repeated purchased categories receive the strongest behavior boost.
- Repeated searched categories receive a medium boost.
- Wishlist categories receive a smaller boost.
- Optional behavior tables must never break catalog rendering when missing.

## Data
Add `catalog_search_events` with user id, search term, optional inferred category, and timestamp.

## Testing
Update the existing PowerShell source-contract tests to require default recommended catalog behavior, search-event schema/repository methods, behavior signal weighting, and safe optional-table fallback.
