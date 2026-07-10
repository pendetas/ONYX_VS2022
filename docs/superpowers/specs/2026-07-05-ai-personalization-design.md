# ONYX AI-Style Personalization Design

## Goal

New ONYX customers must complete a first-time personalization setup after registration or OAuth signup. Their answers will power personalized product recommendations on the customer home and catalog experience without requiring an external AI API in the first version.

The first version should feel intelligent, but remain deterministic, affordable, and easy to explain for assignment review. A real AI provider can be added later to generate natural-language recommendation explanations or richer insight copy.

## Scope

In scope:

- Detect users who have not completed personalization.
- Redirect first-time registered users to a mandatory personalization page.
- Store personalization answers in PostgreSQL.
- Mark personalization as completed after required answers are saved.
- Rank products using a local scoring engine.
- Show personalized product recommendations on customer-facing pages.
- Match the existing ONYX premium black visual language, typography, and spacing.

Out of scope for the first version:

- Paid AI API calls.
- Chatbot-style recommendations.
- Real-time model training.
- Complex behavior tracking for every click.
- Admin/owner controls for personalization rules.

## First-Time User Detection

The system will use a personalization profile table as the source of truth.

A user is treated as incomplete when no completed profile exists:

```text
user_personalization_profiles.completed_at IS NULL
```

After successful manual registration or OAuth signup, the auth flow should check personalization status before sending the user to the normal customer destination.

Login behavior:

- Existing users with completed personalization go to the normal customer home/catalog destination.
- Existing users without completed personalization are redirected to personalization.
- New users from manual signup or OAuth signup are redirected to personalization.
- Admin/owner/staff roles should not be forced through customer personalization unless they are using a customer role account.

## User Flow

```text
Register or OAuth signup succeeds
-> User session is created
-> Auth redirect helper checks personalization completion
-> Incomplete customer profile redirects to /customer_page/onyx_personalization.aspx
-> User answers required questions
-> System saves profile and completed_at
-> User is redirected to /customer_page/onyx_home.aspx
-> Home/catalog uses personalization score to prioritize products
```

The personalization page is mandatory for first-time customer users. The page should not offer a skip button in the first version.

## Personalization Questions

The first version should use a short setup flow, not a long survey.

Required questions:

1. Main gaming style
   - FPS
   - MOBA
   - RPG
   - Racing
   - Casual
   - Creator

2. Gear interest
   - Mouse
   - Keyboard
   - Headset
   - Accessory

3. Purchase priority
   - Speed
   - Comfort
   - Wireless
   - Budget
   - RGB
   - Premium Build

4. Budget range
   - Entry
   - Mid-range
   - Premium

5. Setup goal
   - Competitive
   - Everyday gaming
   - Streaming
   - Work and gaming

Multi-select is allowed for gear interest and purchase priority. The other answers should be single-select for easier scoring.

## Database Design

Add a migration for personalization profiles:

```sql
CREATE TABLE IF NOT EXISTS user_personalization_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    gaming_style VARCHAR(40) NOT NULL,
    preferred_categories TEXT NOT NULL,
    priorities TEXT NOT NULL,
    budget_range VARCHAR(40) NOT NULL,
    setup_goal VARCHAR(60) NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

`preferred_categories` and `priorities` can store comma-separated normalized values in the first version to keep implementation small. A later version can split them into child tables if the feature grows.

## Recommendation Engine

Create a local personalization service that calculates product scores.

Score inputs:

- Product category
- Product name
- Product description
- Product price
- User personalization answers
- Wishlist categories, when available
- Purchased product categories, when available

Initial scoring:

```text
+50 if product category is in preferred categories
+25 if product name/description matches priority keywords
+20 if product price fits budget range
+15 if category matches previous wishlist categories
+20 if category matches previous purchased categories
+10 if setup goal maps to product category or keyword
```

Budget mapping:

- Entry: prioritize lower-priced products.
- Mid-range: prioritize products near the catalog median price.
- Premium: prioritize higher-priced products and premium build keywords.

The service should return products ordered by score, then fall back to existing catalog ordering when scores tie.

## UI Design

The personalization page should feel like the login/register experience, not a separate default ASP.NET page.

Visual requirements:

- Pure black and charcoal surfaces.
- Monochrome borders and dividers.
- No blue or navy field backgrounds.
- Same ONYX typography behavior used by auth pages.
- Large but restrained page title, such as `Build Your ONYX Setup`.
- Minimal step/progress indicator.
- Choice buttons that look premium and tactile.
- Clear final action: `Build My Setup`.
- Responsive layout for laptop and mobile widths.

The page should use existing ONYX assets where possible. It should avoid decorative gradients, colorful cards, and explanatory marketing blocks.

## Integration Points

Auth:

- Extend post-auth redirect behavior for customer users.
- Manual registration should redirect to personalization after account creation.
- OAuth signup should redirect to personalization after the OAuth account is created.
- Existing OAuth login should redirect to personalization only if the user has no completed profile.

Customer home/catalog:

- Home should show a personalized product strip when a completed profile exists.
- Catalog should add a `Recommended` ordering path for signed-in users with completed personalization.
- Catalog should keep the current ordering behavior for anonymous users or signed-in users without a completed personalization profile.
- Product cards can include a small reason label later, such as `Matched for FPS speed`.

Profile:

- A later version can add an `Edit Preferences` link from the profile page.
- First version only needs onboarding after registration/login.

## Error Handling

- If personalization data cannot be loaded, show a friendly retry message.
- If product scoring fails, fall back to existing product ordering.
- If a required answer is missing, keep the user on the personalization page and highlight the missing section.
- If a non-customer role reaches the page, redirect according to role.
- Database failures should not expose raw exception details to the browser.

## Testing

Add source-level tests or focused checks for:

- Auth redirect requires personalization for incomplete customer users.
- Completed users are not forced back to onboarding.
- Manual registration path can reach personalization.
- OAuth-created users can reach personalization.
- Personalization profile save requires all required fields.
- Recommendation service ranks matching products above unrelated products.
- Home/catalog falls back safely when no personalization profile exists.

Manual verification:

- Create a new manual account and confirm personalization appears before home.
- Create a new OAuth account and confirm personalization appears before home.
- Complete onboarding and confirm the next login goes directly to home.
- Confirm recommended products match selected category and priorities.
- Confirm UI remains black/monochrome across desktop and mobile.

## Future AI Extension

When an AI provider is available, keep the deterministic scoring engine as the source of truth. Use AI only for optional explanation copy or insight summaries.

Examples:

- `Recommended because you prefer FPS games, lightweight control, and competitive performance.`
- `Your setup profile suggests a low-latency mouse and headset upgrade first.`

The first AI version should call the provider only after products have already been selected by the local engine. This keeps the site useful even when the AI API is unavailable.
