# Task 5 Report: Personalized Home And Catalog Recommendations

Date: 2026-07-06
Branch: feature/Jovan-OAuth-on-main
Commit message: `Show personalized product recommendations`

## Scope completed

Implemented Task 5 only:

- Added home-page personalized recommendation rendering for completed signed-in customers.
- Added catalog `recommended` sort wiring and recommended-product paging/filtering through `PersonalizationService`.
- Extended the Task 5 source-contract coverage in `tests/PersonalizationFlow.Tests.ps1`.

No auth routing or onboarding flow behavior was changed.

## Test-first sequence followed

1. Appended the Task 5 source-contract assertions to `tests/PersonalizationFlow.Tests.ps1`.
2. Ran:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
   ```

3. Observed expected failure for:
   - `Home page binds personalized recommendation strip`
   - `Catalog exposes recommended sort`
   - `Product service handles recommended sort through personalization`
4. Implemented the minimum production changes to satisfy those requirements.
5. Re-ran the focused test and then MSBuild.

## Files changed

- `Models/CatalogQuery.cs`
- `Services/ProductService.cs`
- `customer_page/onyx_home.aspx`
- `customer_page/onyx_home.aspx.cs`
- `customer_page/onyx_home.aspx.designer.cs`
- `customer_page/onyx_catalog.aspx`
- `customer_page/onyx_catalog.aspx.cs`
- `tests/PersonalizationFlow.Tests.ps1`

## Implementation details

### 1. Catalog query contract

Added:

```csharp
public long? UserId { get; set; }
```

This allows catalog requests to carry the current signed-in user when the `recommended` sort is selected.

### 2. Product service recommended sort

Updated `ProductService` to:

- accept `recommended` as a normalized sort option
- use `PersonalizationService.GetRecommendedProducts(userId, 48)` when:
  - sort is `recommended`
  - `CatalogQuery.UserId` has a value
- filter the personalized results with the existing catalog category/search inputs
- apply existing pagination semantics through `PagedResult<Product>`

This keeps repository-backed sorting unchanged for `newest`, `name`, `price-asc`, and `price-desc`.

### 3. Catalog page wiring

Updated the catalog page to:

- add `Recommended` as the first sort option
- pass the signed-in user ID into `CatalogQuery.UserId`
- allow `recommended` through page-level `NormalizeSort`

Existing filters, wishlist toggle behavior, paging links, and product-card markup were preserved.

### 4. Home personalized strip

Added a new `PersonalizedProductsPanel` section before featured products that:

- stays hidden by default
- shows only when the current user is signed in and has completed personalization
- binds up to 4 recommendations from `PersonalizationService`
- reuses the existing ONYX product-grid/card language and dark styling

Because Web Forms nested `Eval("Product.*")` bindings can be brittle, the repeater uses code-behind helpers for:

- name
- price
- reason
- image URL
- alt text
- details URL

### 5. Designer update

Added the required declarations for:

- `PersonalizedProductsPanel`
- `PersonalizedProductsRepeater`

## Verification

Focused source-contract test:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Result:

- Passed with `Personalization schema/model source contract passes.`

Build:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Result:

- Build succeeded
- `0 Warning(s)`
- `0 Error(s)`

## Task 5 follow-up: personalization failure fallback

Fixed the remaining Task 5 error-handling issue so personalization DB failures no longer bubble to the browser:

- `Services/ProductService.cs` now catches personalization read failures on the `recommended` catalog path, logs a warning, and falls back to the standard repository catalog path.
- `customer_page/onyx_home.aspx.cs` now catches personalization read failures while binding the recommendation strip, logs a warning, hides the strip, and keeps rendering the normal home page.
- `tests/PersonalizationFlow.Tests.ps1` now checks for the fallback/error-handling source contract.

Verification rerun for this follow-up:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Result:

- Passed with `Personalization schema/model source contract passes.`

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Result:

- Build succeeded
- `0 Warning(s)`
- `0 Error(s)`

## Notes / concerns

- The catalog `Recommended` sort option is visible in the UI regardless of sign-in state, but personalized ordering only activates when a user ID is available. In all other cases, the current normalization/pathing remains stable and the page still builds and functions.
- The home recommendation strip intentionally reuses existing image/category presentation helpers to stay visually consistent with current ONYX cards.

## Review follow-up: Task 5 findings

Applied the requested fixes in the personalized catalog recommendation path:

- Recommended search now preserves the repository catalog fields: `Name`, `Brand`, `Category`, and `Description`.
- Recommended pagination now clamps out-of-range requested pages to the last valid page, matching `ProductRepository.GetCatalogProducts`.
- Recommended sort now falls back to the normal repository catalog path for anonymous users, incomplete-profile users, and empty recommendation results instead of returning a blank catalog.
- Extended `tests/PersonalizationFlow.Tests.ps1` so those safeguards are visible in the source-contract assertions.

Verification rerun after the fix:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Result:

- Passed with `Personalization schema/model source contract passes.`

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Result:

- Build succeeded
- `0 Warning(s)`
- `0 Error(s)`
