# Task 2 Report — Voucher Domain Models and Pure Calculator

Completed Task 2 in `ONYX_VS2022` with the voucher domain model layer and a pure, database-agnostic calculator.

What was added:

- `Models/Voucher.cs`
  - Voucher entity for the approved schema-backed fields.
  - Public constants for voucher discount types and redemption statuses.
  - `Categories` is initialized in the constructor so callers can add eligible categories safely.

- `Models/VoucherQuote.cs`
  - `VoucherCartLine` input model for calculator calls.
  - `VoucherQuote` output model containing subtotal, eligible subtotal, discount amount, and final total.

- `Models/VoucherAdminMetrics.cs`
  - Simple admin metrics DTO for active count, redeemed count, and redeemed savings.

- `Services/VoucherCalculator.cs`
  - Pure `VoucherCalculator.Calculate(...)` implementation.
  - Customer-safe `VoucherValidationException`.
  - Uses `decimal` for all money math.
  - Rounds percentage discounts with `MidpointRounding.AwayFromZero`.
  - Enforces:
    - archived / inactive / not-yet-active / expired vouchers
    - total usage limit
    - per-user usage limit
    - empty cart
    - invalid cart lines
    - minimum purchase threshold on full subtotal
    - category eligibility
    - percentage cap
    - fixed discount capped to eligible subtotal
  - Category matching is case-insensitive, while discount-type matching follows the approved lower-case constants.

- `Tests/VoucherCalculator.Tests.ps1`
  - Executable focused test covering:
    - category-aware percentage discount
    - percentage cap
    - fixed discount cap
    - per-user usage failure
    - case-insensitive category matching
    - away-from-zero rounding

- `ONYX_DDAC.csproj`
  - Added compile entries for the three model files and `Services/VoucherCalculator.cs`.

Verification performed:

- First run of `Tests/VoucherCalculator.Tests.ps1` failed as expected with missing source files.
- After implementation, `Tests/VoucherCalculator.Tests.ps1` passed:
  - `Voucher calculator behavior passes.`

Notes:

- Unrelated pre-existing working-tree changes were left untouched.
- The calculator stays independent of database and Web Forms types, so later checkout and repository tasks can call it directly.
- The calculator currently validates the data it receives; schema-backed normalization and orchestration remain for later tasks.

Concerns:

- No additional integration/build verification was run beyond the focused calculator test and source-review sanity check.
- The repository still contains unrelated unstaged changes from prior work.

## Reviewer Fix — July 17, 2026

Fixed two voucher-domain issues called out in review:

1. `Models/Voucher.cs` now sets the approved constructor defaults:
   - `PerUserUsageLimit = 1`
   - `IsActive = true`
   - `AppliesToAllCategories = true`
   - `Categories` still initializes to an empty list.

2. `Services/VoucherCalculator.cs` now fails closed on malformed discount configurations before calculation:
   - percentage discounts must be `> 0` and `<= 100`
   - fixed discounts must be `> 0`
   - percentage caps, if supplied, must be `> 0`
   - fixed discounts cannot supply a cap
   - valid discounts still clamp normally to the eligible subtotal

Verification command:

- `powershell -ExecutionPolicy Bypass -File tests\VoucherCalculator.Tests.ps1`

Verification output:

- `Voucher calculator behavior passes.`

Files changed in this fix:

- `Models/Voucher.cs`
- `Services/VoucherCalculator.cs`
- `tests/VoucherCalculator.Tests.ps1`
- `.superpowers/sdd/task-2-report.md`
