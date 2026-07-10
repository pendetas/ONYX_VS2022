# Admin Product Creation Repair and Action Bar Design

## Objective

Restore reliable product creation in the ONYX admin area and make the long product form's primary actions visible, clear, and accessible without changing the form's established monochrome visual identity.

## Root Cause

The new RDS database contains product IDs through `20`, but `public.products_id_seq` reports `15` as its latest value. `ProductRepository.InsertProduct` relies on that identity sequence, so PostgreSQL attempts to reuse ID `15` and rejects the insert with a `products_pkey` duplicate-key error. The page catches the exception and displays a generic save failure, hiding the actionable cause.

## Database Repair

Add an idempotent SQL migration that locks the products table while it compares the sequence with `MAX(products.id)`, then advances the identity sequence to a safe value. The migration must work for both populated and empty tables and must not insert or delete product data.

Apply the migration to the configured new RDS database. Verify the repair inside a rolled-back transaction by inserting a diagnostic product and confirming the generated ID is greater than the current maximum.

## Application Error Handling

Keep detailed exception information in server tracing. Replace the vague admin-facing message with a specific but non-sensitive message that explains that the product was not created and tells the administrator to check the database configuration or contact an administrator. Do not expose SQL statements, credentials, hostnames, or stack traces.

Prevent double submission by disabling the primary action after client validation succeeds. If server validation rejects the request and redisplays the page, the normal postback render restores the enabled state.

## Action Bar Design

Use a sticky command bar at the bottom of the admin content viewport so actions remain reachable throughout the long form.

- Background: near-black translucent surface matching the ONYX navigation shell.
- Border: restrained white hairline along the top edge.
- Primary action: high-contrast white button labeled `Save product` when creating and `Save changes` when editing, with a right arrow as a directional cue.
- Secondary action: bordered `Cancel` control with the same height and focus treatment.
- Destructive action: red outlined `Delete product`, shown only while editing and visually separated from the primary group.
- Status text: retain the required-fields note at the far edge without competing with actions.
- Interaction: subtle lift/contrast on hover, strong visible focus ring, disabled/loading state after submission, and reduced-motion support.
- Responsive behavior: on narrow screens, stack the primary and secondary controls at full width while keeping the destructive action clearly separated.

The signature element is the persistent command strip: it treats product editing like an ONYX control console rather than a generic web form while staying visually quiet.

## Code Boundaries

- `App_Data`: sequence-repair migration.
- `admin_page/onyx_admin_products_form.aspx`: action markup, button labels, client submission state, and scoped CSS.
- `admin_page/onyx_admin_products_form.aspx.cs`: mode-specific save label and improved non-sensitive error message.
- `Tests/AdminProductForm.Tests.ps1`: source-contract regression checks for the migration and action bar.

No repository-level automatic sequence repair will be added. Sequence synchronization is a database deployment responsibility; mutating sequence state during every product insert would mask broken imports and introduce unnecessary locking in normal requests.

## Verification

1. A regression test fails before the migration/action changes and passes afterward.
2. The migration runs successfully twice to prove idempotence.
3. A diagnostic product insert inside a transaction returns a new ID and is rolled back.
4. Product creation is exercised through the admin UI when the local application is available.
5. All PowerShell source-contract tests pass.
6. The Visual Studio solution builds successfully.
7. Dark mode, light mode, narrow viewport, keyboard focus, and disabled button states are visually checked.
