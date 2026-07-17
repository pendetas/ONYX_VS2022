# Voucher Loyalty Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a production-ready Loyalty Management voucher module whose category-aware discounts are enforced transactionally and reflected consistently in checkout, Stripe, orders, and invoices.

**Architecture:** Replace the mock Promotions admin experience with voucher-backed Loyalty Management. Keep discount rules in a pure calculator, persistence and row locking in `VoucherRepository`, orchestration in `VoucherService`, and final authority inside the existing checkout transaction. Represent the calculated discount in Stripe with an order-specific one-time amount-off coupon while ONYX remains the source of truth.

**Tech Stack:** ASP.NET Web Forms on .NET Framework 4.8, C#, PostgreSQL/Npgsql, Stripe.net 50.0.0, PowerShell source-contract and calculator tests, HTML/CSS/vanilla JavaScript.

## Global Constraints

- Preserve all unrelated working-tree changes and stage only files named by the active task.
- Public voucher codes are available to any authenticated customer who knows the code.
- One voucher is allowed per order; voucher stacking is not supported.
- Discounts apply only to eligible-category items; minimum purchase uses the full pre-discount cart subtotal.
- Support percentage and fixed-MYR discounts; percentage discounts may have a positive cap.
- Default per-user usage limit is one; total and per-user limits are configurable.
- Final voucher validation and calculation occur server-side in the order transaction.
- Pending and redeemed redemptions count toward limits; released redemptions do not.
- Terms are multiline plain text, HTML-encoded on output, with no raw administrator HTML.
- Existing non-voucher checkout, Stripe idempotency, stock reservation, and cancellation behavior must remain intact.
- Delivery remains free; do not add free-shipping vouchers.
- Match existing ONYX admin typography, monochrome dark/light themes, spacing, focus treatment, and responsive behavior.
- Use parameterized SQL and `decimal` monetary arithmetic with `MidpointRounding.AwayFromZero`.

---

## File Structure

### New files

- `App_Data/20260717_voucher_loyalty_management.sql` — idempotent migration for vouchers, categories, redemptions, and order snapshots.
- `Models/Voucher.cs` — voucher entity and discount/redemption constants.
- `Models/VoucherQuote.cs` — calculator input line and immutable quote result.
- `Models/VoucherAdminMetrics.cs` — Loyalty dashboard totals.
- `Services/VoucherCalculator.cs` — pure eligibility and monetary calculation.
- `DAL/VoucherRepository.cs` — admin CRUD, quote reads, row locks, usage counts, and redemption state transitions.
- `Services/VoucherService.cs` — admin validation and checkout quote orchestration.
- `admin_page/onyx_admin_voucher_form.aspx` — voucher create/edit form.
- `admin_page/onyx_admin_voucher_form.aspx.cs` — create/edit lifecycle and validation messages.
- `admin_page/onyx_admin_voucher_form.aspx.designer.cs` — Web Forms control declarations.
- `Tests/VoucherSchema.Tests.ps1` — migration and project-inclusion source contract.
- `Tests/VoucherCalculator.Tests.ps1` — executable calculator behavior tests.
- `Tests/VoucherPersistence.Tests.ps1` — repository, locking, lifecycle, and checkout source contract.
- `Tests/VoucherAdmin.Tests.ps1` — Loyalty navigation/list/form/theme source contract.
- `Tests/VoucherCheckout.Tests.ps1` — checkout, Stripe, payment lifecycle, and order-display source contract.

### Existing files to modify

- `App_Data/onyx_schema.sql` — canonical fresh-database schema.
- `ONYX_DDAC.csproj` — include all new migration, model, service, repository, and Web Forms files.
- `admin_page/admin.Master`, `.cs`, `.designer.cs` — rename navigation to Loyalty and treat list/form routes as one active section.
- `admin_page/onyx_admin_promos.aspx`, `.cs`, `.designer.cs` — replace mock promotions with the voucher list.
- `Models/CartItem.cs`, `Order.cs`, `OrderDetail.cs`, `OrderSummary.cs` — category and voucher/order snapshot properties.
- `DAL/CheckoutRepository.cs` — authoritative voucher lock, calculation, reservation, and order persistence.
- `Services/CheckoutService.cs` — accept a voucher code without weakening existing checkout validation.
- `Services/StripePaymentService.cs` — create and attach an order-specific amount-off coupon.
- `DAL/PaymentRepository.cs` — redeem or release vouchers with payment state transitions.
- `customer_page/onyx_checkout.aspx`, `.cs`, `.designer.cs` — apply/remove voucher, totals, and T&C modal.
- `DAL/OrderRepository.cs` — hydrate voucher snapshot totals for admin/customer views.
- `admin_page/onyx_admin_order_details.aspx`, `.cs`, `.designer.cs` — show subtotal, discount, voucher, and free shipping.
- `customer_page/onyx_order_history.aspx`, `.cs` — show applied voucher summary.
- `customer_page/onyx_invoice.aspx`, `.cs`, `.designer.cs` — show subtotal, discount, voucher, and total.
- `customer_page/onyx_payment_confirmation.aspx`, `.cs` — show the same final breakdown after payment.
- `Content/onyx-commerce.css` — checkout voucher and modal styling.

---

### Task 1: Database schema and migration contract

**Files:**
- Create: `Tests/VoucherSchema.Tests.ps1`
- Create: `App_Data/20260717_voucher_loyalty_management.sql`
- Modify: `App_Data/onyx_schema.sql`
- Modify: `ONYX_DDAC.csproj:209-220`

**Interfaces:**
- Consumes: existing `users`, `products`, and `orders` tables.
- Produces: `vouchers`, `voucher_categories`, `voucher_redemptions`, and order snapshot columns used by all later tasks.

- [ ] **Step 1: Write the failing schema contract**

Create `Tests/VoucherSchema.Tests.ps1`:

```powershell
$root = Split-Path $PSScriptRoot -Parent
$migrationPath = "$root\App_Data\20260717_voucher_loyalty_management.sql"
$schemaPath = "$root\App_Data\onyx_schema.sql"
$projectPath = "$root\ONYX_DDAC.csproj"

$migration = if (Test-Path $migrationPath) { Get-Content $migrationPath -Raw } else { '' }
$schema = Get-Content $schemaPath -Raw
$project = Get-Content $projectPath -Raw

$checks = [ordered]@{
    'Migration creates voucher tables' =
        $migration -match 'CREATE TABLE IF NOT EXISTS vouchers' -and
        $migration -match 'CREATE TABLE IF NOT EXISTS voucher_categories' -and
        $migration -match 'CREATE TABLE IF NOT EXISTS voucher_redemptions'
    'Voucher code is case-insensitively unique' =
        $migration -match 'CREATE UNIQUE INDEX IF NOT EXISTS ux_vouchers_code_ci' -and
        $migration -match 'LOWER\(code\)'
    'Voucher rules have database checks' =
        $migration -match "discount_type IN \('percentage', 'fixed'\)" -and
        $migration -match 'discount_value > 0' -and
        $migration -match 'expires_at > valid_from' -and
        $migration -match "status IN \('pending', 'redeemed', 'released'\)"
    'Orders preserve voucher snapshots' =
        $migration -match 'ADD COLUMN IF NOT EXISTS subtotal_amount' -and
        $migration -match 'ADD COLUMN IF NOT EXISTS discount_amount' -and
        $migration -match 'ADD COLUMN IF NOT EXISTS voucher_id' -and
        $migration -match 'ADD COLUMN IF NOT EXISTS voucher_code' -and
        $migration -match 'ADD COLUMN IF NOT EXISTS voucher_name'
    'Canonical schema contains voucher tables' =
        $schema -match 'CREATE TABLE vouchers' -and
        $schema -match 'CREATE TABLE voucher_redemptions'
    'Project includes voucher migration' =
        $project -match 'App_Data\\20260717_voucher_loyalty_management\.sql'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing voucher schema requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Voucher schema source contract passes.'
```

- [ ] **Step 2: Run the schema contract and verify failure**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherSchema.Tests.ps1
```

Expected: exit code `1` beginning with `Missing voucher schema requirements`.

- [ ] **Step 3: Add the idempotent migration**

Create `App_Data/20260717_voucher_loyalty_management.sql` with:

```sql
BEGIN;

CREATE TABLE IF NOT EXISTS vouchers (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(40) NOT NULL,
  discount_type VARCHAR(20) NOT NULL,
  discount_value NUMERIC(10,2) NOT NULL,
  maximum_discount_amount NUMERIC(10,2),
  minimum_purchase_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  applies_to_all_categories BOOLEAN NOT NULL DEFAULT true,
  valid_from TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  total_usage_limit INTEGER,
  per_user_usage_limit INTEGER NOT NULL DEFAULT 1,
  is_active BOOLEAN NOT NULL DEFAULT true,
  terms_and_conditions TEXT NOT NULL,
  created_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_at TIMESTAMPTZ,
  CONSTRAINT ck_vouchers_discount_type
    CHECK (discount_type IN ('percentage', 'fixed')),
  CONSTRAINT ck_vouchers_discount_value
    CHECK (discount_value > 0 AND (discount_type <> 'percentage' OR discount_value <= 100)),
  CONSTRAINT ck_vouchers_maximum_discount
    CHECK (
      (discount_type = 'fixed' AND maximum_discount_amount IS NULL) OR
      (discount_type = 'percentage' AND (maximum_discount_amount IS NULL OR maximum_discount_amount > 0))
    ),
  CONSTRAINT ck_vouchers_minimum_purchase CHECK (minimum_purchase_amount >= 0),
  CONSTRAINT ck_vouchers_validity CHECK (expires_at > valid_from),
  CONSTRAINT ck_vouchers_total_limit CHECK (total_usage_limit IS NULL OR total_usage_limit > 0),
  CONSTRAINT ck_vouchers_user_limit CHECK (per_user_usage_limit > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_vouchers_code_ci ON vouchers (LOWER(code));
CREATE INDEX IF NOT EXISTS ix_vouchers_active_dates
  ON vouchers (is_active, valid_from, expires_at)
  WHERE archived_at IS NULL;

CREATE TABLE IF NOT EXISTS voucher_categories (
  voucher_id BIGINT NOT NULL REFERENCES vouchers(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL,
  PRIMARY KEY (voucher_id, category)
);

CREATE TABLE IF NOT EXISTS voucher_redemptions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  voucher_id BIGINT NOT NULL REFERENCES vouchers(id),
  user_id BIGINT NOT NULL REFERENCES users(id),
  order_id BIGINT NOT NULL REFERENCES orders(id),
  eligible_subtotal NUMERIC(10,2) NOT NULL CHECK (eligible_subtotal >= 0),
  discount_amount NUMERIC(10,2) NOT NULL CHECK (discount_amount > 0),
  status VARCHAR(20) NOT NULL,
  reserved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  redeemed_at TIMESTAMPTZ,
  released_at TIMESTAMPTZ,
  CONSTRAINT ux_voucher_redemptions_order UNIQUE (order_id),
  CONSTRAINT ck_voucher_redemptions_status
    CHECK (status IN ('pending', 'redeemed', 'released'))
);

CREATE INDEX IF NOT EXISTS ix_voucher_redemptions_voucher_status
  ON voucher_redemptions (voucher_id, status);
CREATE INDEX IF NOT EXISTS ix_voucher_redemptions_user_status
  ON voucher_redemptions (voucher_id, user_id, status);

ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal_amount NUMERIC(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_amount NUMERIC(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS voucher_id BIGINT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS voucher_code VARCHAR(40);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS voucher_name VARCHAR(120);

UPDATE orders
SET subtotal_amount = total_amount
WHERE subtotal_amount IS NULL;

UPDATE orders
SET discount_amount = 0
WHERE discount_amount IS NULL;

ALTER TABLE orders ALTER COLUMN subtotal_amount SET DEFAULT 0;
ALTER TABLE orders ALTER COLUMN subtotal_amount SET NOT NULL;
ALTER TABLE orders ALTER COLUMN discount_amount SET DEFAULT 0;
ALTER TABLE orders ALTER COLUMN discount_amount SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_orders_voucher'
  ) THEN
    ALTER TABLE orders
      ADD CONSTRAINT fk_orders_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers(id);
  END IF;
END $$;

COMMIT;
```

- [ ] **Step 4: Update the canonical schema and project file**

Insert equivalent non-idempotent `CREATE TABLE` statements after `orders` in `App_Data/onyx_schema.sql`, including the same constraints, indexes, and five order columns. Add this content entry beside the existing migrations in `ONYX_DDAC.csproj`:

```xml
<Content Include="App_Data\20260717_voucher_loyalty_management.sql" />
```

- [ ] **Step 5: Run the schema contract and whitespace check**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherSchema.Tests.ps1
git diff --check -- App_Data/20260717_voucher_loyalty_management.sql App_Data/onyx_schema.sql ONYX_DDAC.csproj Tests/VoucherSchema.Tests.ps1
```

Expected: `Voucher schema source contract passes.` and no whitespace errors.

- [ ] **Step 6: Commit the schema task**

```powershell
git add -- App_Data/20260717_voucher_loyalty_management.sql App_Data/onyx_schema.sql ONYX_DDAC.csproj Tests/VoucherSchema.Tests.ps1
git commit -m "feat: add voucher loyalty schema"
```

---

### Task 2: Voucher domain models and pure calculator

**Files:**
- Create: `Models/Voucher.cs`
- Create: `Models/VoucherQuote.cs`
- Create: `Models/VoucherAdminMetrics.cs`
- Create: `Services/VoucherCalculator.cs`
- Create: `Tests/VoucherCalculator.Tests.ps1`
- Modify: `ONYX_DDAC.csproj:560-610,650-680`

**Interfaces:**
- Produces: `VoucherCalculator.Calculate(Voucher, IEnumerable<VoucherCartLine>, DateTimeOffset, int, int): VoucherQuote`.
- Produces: `VoucherValidationException` for customer-safe rule failures.
- Consumes: no database or Web Forms types, allowing direct calculator tests.

- [ ] **Step 1: Write executable calculator tests**

Create `Tests/VoucherCalculator.Tests.ps1`:

```powershell
$root = Split-Path $PSScriptRoot -Parent
$sources = @(
    "$root\Models\Voucher.cs",
    "$root\Models\VoucherQuote.cs",
    "$root\Services\VoucherCalculator.cs"
)

foreach ($source in $sources) {
    if (-not (Test-Path $source)) { throw "Missing calculator source: $source" }
}

Add-Type -Path $sources

function Assert-Decimal([decimal]$actual, [decimal]$expected, [string]$name) {
    if ($actual -ne $expected) { throw "$name expected $expected but got $actual" }
}

function New-Voucher([string]$type, [decimal]$value) {
    $voucher = [ONYX_DDAC.Models.Voucher]::new()
    $voucher.Id = 7
    $voucher.Name = 'Mouse Launch'
    $voucher.Code = 'MOUSE20'
    $voucher.DiscountType = $type
    $voucher.DiscountValue = $value
    $voucher.MinimumPurchaseAmount = 100
    $voucher.AppliesToAllCategories = $false
    $voucher.Categories.Add('Mouse')
    $voucher.ValidFrom = [DateTimeOffset]::Parse('2026-07-01T00:00:00Z')
    $voucher.ExpiresAt = [DateTimeOffset]::Parse('2026-08-01T00:00:00Z')
    $voucher.PerUserUsageLimit = 1
    $voucher.IsActive = $true
    $voucher.TermsAndConditions = 'Mouse products only.'
    return $voucher
}

$lines = [System.Collections.Generic.List[ONYX_DDAC.Models.VoucherCartLine]]::new()
$lines.Add([ONYX_DDAC.Models.VoucherCartLine]@{ Category='Mouse'; UnitPrice=200; Quantity=1 })
$lines.Add([ONYX_DDAC.Models.VoucherCartLine]@{ Category='Keyboard'; UnitPrice=300; Quantity=1 })
$now = [DateTimeOffset]::Parse('2026-07-17T00:00:00Z')

$percentage = New-Voucher 'percentage' 20
$quote = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($percentage, $lines, $now, 0, 0)
Assert-Decimal $quote.Subtotal 500 'Subtotal'
Assert-Decimal $quote.EligibleSubtotal 200 'Eligible subtotal'
Assert-Decimal $quote.DiscountAmount 40 'Category percentage discount'
Assert-Decimal $quote.TotalAmount 460 'Final total'

$percentage.MaximumDiscountAmount = 25
$capped = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($percentage, $lines, $now, 0, 0)
Assert-Decimal $capped.DiscountAmount 25 'Percentage cap'

$fixed = New-Voucher 'fixed' 250
$fixedQuote = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($fixed, $lines, $now, 0, 0)
Assert-Decimal $fixedQuote.DiscountAmount 200 'Fixed discount eligible-subtotal cap'

$failed = $false
try { [ONYX_DDAC.Services.VoucherCalculator]::Calculate($percentage, $lines, $now, 0, 1) } catch { $failed = $_.Exception.Message -match 'already used' }
if (-not $failed) { throw 'Per-user usage limit was not enforced.' }

Write-Output 'Voucher calculator behavior passes.'
```

- [ ] **Step 2: Run the calculator tests and verify failure**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherCalculator.Tests.ps1
```

Expected: exit code `1` with `Missing calculator source`.

- [ ] **Step 3: Add voucher models**

Create `Models/Voucher.cs`:

```csharp
using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Models
{
    public static class VoucherDiscountTypes
    {
        public const string Percentage = "percentage";
        public const string Fixed = "fixed";
    }

    public static class VoucherRedemptionStatuses
    {
        public const string Pending = "pending";
        public const string Redeemed = "redeemed";
        public const string Released = "released";
    }

    public class Voucher
    {
        public Voucher() { Categories = new List<string>(); }
        public long Id { get; set; }
        public string Name { get; set; }
        public string Code { get; set; }
        public string DiscountType { get; set; }
        public decimal DiscountValue { get; set; }
        public decimal? MaximumDiscountAmount { get; set; }
        public decimal MinimumPurchaseAmount { get; set; }
        public bool AppliesToAllCategories { get; set; }
        public IList<string> Categories { get; set; }
        public DateTimeOffset ValidFrom { get; set; }
        public DateTimeOffset ExpiresAt { get; set; }
        public int? TotalUsageLimit { get; set; }
        public int PerUserUsageLimit { get; set; }
        public bool IsActive { get; set; }
        public string TermsAndConditions { get; set; }
        public DateTimeOffset? ArchivedAt { get; set; }
        public int PendingAndRedeemedUses { get; set; }
        public int RedeemedUses { get; set; }
        public decimal RedeemedSavings { get; set; }
        public bool HasRedemptions { get; set; }
    }
}
```

Create `Models/VoucherQuote.cs`:

```csharp
namespace ONYX_DDAC.Models
{
    public class VoucherCartLine
    {
        public string Category { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
    }

    public class VoucherQuote
    {
        public long VoucherId { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public string TermsAndConditions { get; set; }
        public decimal Subtotal { get; set; }
        public decimal EligibleSubtotal { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
    }
}
```

Create `Models/VoucherAdminMetrics.cs`:

```csharp
namespace ONYX_DDAC.Models
{
    public class VoucherAdminMetrics
    {
        public int ActiveVoucherCount { get; set; }
        public int RedeemedCount { get; set; }
        public decimal RedeemedSavings { get; set; }
    }
}
```

- [ ] **Step 4: Implement the pure calculator**

Create `Services/VoucherCalculator.cs`:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class VoucherValidationException : InvalidOperationException
    {
        public VoucherValidationException(string message) : base(message) { }
    }

    public static class VoucherCalculator
    {
        public static VoucherQuote Calculate(
            Voucher voucher,
            IEnumerable<VoucherCartLine> cartLines,
            DateTimeOffset now,
            int totalUsed,
            int userUsed)
        {
            if (voucher == null || voucher.ArchivedAt.HasValue)
                throw new VoucherValidationException("This voucher code is invalid.");
            if (!voucher.IsActive)
                throw new VoucherValidationException("This voucher is currently paused.");
            if (now < voucher.ValidFrom)
                throw new VoucherValidationException("This voucher is not active yet.");
            if (now >= voucher.ExpiresAt)
                throw new VoucherValidationException("This voucher has expired.");
            if (voucher.TotalUsageLimit.HasValue && totalUsed >= voucher.TotalUsageLimit.Value)
                throw new VoucherValidationException("This voucher has reached its usage limit.");
            if (userUsed >= voucher.PerUserUsageLimit)
                throw new VoucherValidationException("You have already used this voucher.");

            List<VoucherCartLine> lines = (cartLines ?? Enumerable.Empty<VoucherCartLine>()).ToList();
            if (lines.Count == 0)
                throw new VoucherValidationException("Your cart is empty.");
            if (lines.Any(line => line == null || line.Quantity <= 0 || line.UnitPrice < 0))
                throw new VoucherValidationException("Your cart contains an invalid item.");
            decimal subtotal = lines.Sum(line => line.UnitPrice * line.Quantity);
            if (subtotal < voucher.MinimumPurchaseAmount)
                throw new VoucherValidationException("Your cart does not meet this voucher's minimum purchase.");

            var categories = new HashSet<string>(voucher.Categories, StringComparer.OrdinalIgnoreCase);
            decimal eligibleSubtotal = lines
                .Where(line => voucher.AppliesToAllCategories || categories.Contains(line.Category ?? string.Empty))
                .Sum(line => line.UnitPrice * line.Quantity);
            if (eligibleSubtotal <= 0)
                throw new VoucherValidationException("Your cart has no products eligible for this voucher.");

            decimal discount;
            if (string.Equals(voucher.DiscountType, VoucherDiscountTypes.Percentage, StringComparison.Ordinal))
            {
                discount = RoundMoney(eligibleSubtotal * voucher.DiscountValue / 100m);
                if (voucher.MaximumDiscountAmount.HasValue)
                    discount = Math.Min(discount, voucher.MaximumDiscountAmount.Value);
            }
            else if (string.Equals(voucher.DiscountType, VoucherDiscountTypes.Fixed, StringComparison.Ordinal))
            {
                discount = voucher.DiscountValue;
            }
            else
            {
                throw new VoucherValidationException("This voucher has an invalid discount type.");
            }

            discount = Math.Min(Math.Max(RoundMoney(discount), 0m), eligibleSubtotal);
            return new VoucherQuote
            {
                VoucherId = voucher.Id,
                Code = voucher.Code,
                Name = voucher.Name,
                TermsAndConditions = voucher.TermsAndConditions,
                Subtotal = subtotal,
                EligibleSubtotal = eligibleSubtotal,
                DiscountAmount = discount,
                TotalAmount = subtotal - discount
            };
        }

        private static decimal RoundMoney(decimal value)
        {
            return Math.Round(value, 2, MidpointRounding.AwayFromZero);
        }
    }
}
```

- [ ] **Step 5: Include the new C# files in the project and run tests**

Add exact `<Compile Include="..." />` entries for the three model files and `Services\VoucherCalculator.cs` in their matching `ONYX_DDAC.csproj` groups. Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherCalculator.Tests.ps1
```

Expected: `Voucher calculator behavior passes.`

- [ ] **Step 6: Commit the domain task**

```powershell
git add -- Models/Voucher.cs Models/VoucherQuote.cs Models/VoucherAdminMetrics.cs Services/VoucherCalculator.cs Tests/VoucherCalculator.Tests.ps1 ONYX_DDAC.csproj
git commit -m "feat: add voucher eligibility calculator"
```

---

### Task 3: Voucher persistence and service boundary

**Files:**
- Create: `DAL/VoucherRepository.cs`
- Create: `Services/VoucherService.cs`
- Create: `Tests/VoucherPersistence.Tests.ps1`
- Modify: `Models/CartItem.cs`
- Modify: `ONYX_DDAC.csproj`

**Interfaces:**
- Produces: admin CRUD methods on `VoucherService`.
- Produces: `GetCheckoutQuote(long userId, string code, IEnumerable<CartItem> items): VoucherQuote`.
- Produces: transaction helpers `LockByCode`, `ReserveRedemption`, `RedeemForOrder`, and `ReleaseForOrder` on `VoucherRepository`.

- [ ] **Step 1: Write the failing persistence contract**

Create `Tests/VoucherPersistence.Tests.ps1` with ordered checks for these exact signatures and SQL safeguards:

```powershell
$root = Split-Path $PSScriptRoot -Parent
$repoPath = "$root\DAL\VoucherRepository.cs"
$servicePath = "$root\Services\VoucherService.cs"
$cartPath = "$root\Models\CartItem.cs"
$repo = if (Test-Path $repoPath) { Get-Content $repoPath -Raw } else { '' }
$service = if (Test-Path $servicePath) { Get-Content $servicePath -Raw } else { '' }
$cart = Get-Content $cartPath -Raw

$checks = [ordered]@{
    'Repository exposes admin CRUD' =
        $repo -match 'IList<Voucher>\s+GetAll\(' -and
        $repo -match 'Voucher\s+GetById\(' -and
        $repo -match 'long\s+Create\(' -and
        $repo -match 'void\s+Update\(' -and
        $repo -match 'void\s+SetActive\(' -and
        $repo -match 'void\s+Archive\('
    'Repository locks vouchers and counts active usage' =
        $repo -match 'LockByCode' -and $repo -match 'FOR UPDATE' -and
        $repo -match "status IN \(@PendingStatus, @RedeemedStatus\)"
    'Repository owns redemption lifecycle' =
        $repo -match 'ReserveRedemption' -and
        $repo -match 'RedeemForOrder' -and
        $repo -match 'ReleaseForOrder'
    'Service validates admin input and quotes checkout' =
        $service -match 'ValidateForSave' -and
        $service -match 'GetCheckoutQuote' -and
        $service -match 'VoucherCalculator\.Calculate'
    'Cart items carry authoritative category' = $cart -match 'string\s+Category'
    'SQL remains parameterized' = $repo -notmatch 'CommandText\s*=.*\+.*(code|Code|voucher|Voucher)'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher persistence requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher persistence source contract passes.'
```

- [ ] **Step 2: Run the persistence contract and verify failure**

Run `powershell -ExecutionPolicy Bypass -File Tests\VoucherPersistence.Tests.ps1`.

Expected: exit code `1` with missing repository/service requirements.

- [ ] **Step 3: Implement repository public and transaction interfaces**

Create `DAL/VoucherRepository.cs` in namespace `ONYX_DDAC.DAL`. Implement these exact signatures with parameterized Npgsql commands:

```csharp
public IList<Voucher> GetAll();
public Voucher GetById(long id);
public Voucher GetByCode(string normalizedCode);
public VoucherAdminMetrics GetMetrics(DateTimeOffset now);
public IList<string> GetAvailableCategories();
public long Create(Voucher voucher, long? adminUserId);
public void Update(Voucher voucher);
public void SetActive(long id, bool isActive);
public void Archive(long id);
public int CountTotalActiveUses(long voucherId);
public int CountUserActiveUses(long voucherId, long userId);

internal static Voucher LockByCode(DbConnection conn, DbTransaction tx, string normalizedCode);
internal static int CountTotalActiveUses(DbConnection conn, DbTransaction tx, long voucherId);
internal static int CountUserActiveUses(DbConnection conn, DbTransaction tx, long voucherId, long userId);
internal static void ReserveRedemption(DbConnection conn, DbTransaction tx, long voucherId, long userId, long orderId, VoucherQuote quote);
internal static void RedeemForOrder(DbConnection conn, DbTransaction tx, long orderId);
internal static void ReleaseForOrder(DbConnection conn, DbTransaction tx, long orderId);
```

Use this active-use predicate in both count methods:

```sql
WHERE voucher_id = @VoucherId
  AND status IN (@PendingStatus, @RedeemedStatus)
```

Use these terminal updates and require either zero rows for a non-voucher order or exactly one valid transition:

```sql
UPDATE voucher_redemptions
SET status = @RedeemedStatus, redeemed_at = now(), released_at = NULL
WHERE order_id = @OrderId AND status = @PendingStatus;

UPDATE voucher_redemptions
SET status = @ReleasedStatus, released_at = now()
WHERE order_id = @OrderId AND status = @PendingStatus;
```

`Create` and `Update` must save categories in the same transaction as the voucher. Before changing immutable fields, query whether any `voucher_redemptions` row exists. Once one exists, reject changes to code, discount, cap, minimum purchase, valid-from timestamp, or categories; permit only an equal/later expiry and equal/higher limits. `Archive` must reject a voucher with a pending redemption, while a used voucher without pending rows is soft-archived.

- [ ] **Step 4: Implement service validation and quote orchestration**

Create `Services/VoucherService.cs` with:

```csharp
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class VoucherService
    {
        private readonly VoucherRepository _repository;
        public VoucherService() { _repository = new VoucherRepository(); }

        public IList<Voucher> GetAll() { return _repository.GetAll(); }
        public Voucher GetById(long id) { return _repository.GetById(id); }
        public VoucherAdminMetrics GetMetrics() { return _repository.GetMetrics(DateTimeOffset.UtcNow); }
        public IList<string> GetAvailableCategories() { return _repository.GetAvailableCategories(); }

        public long Create(Voucher voucher, long? adminUserId)
        {
            ValidateForSave(voucher);
            voucher.Code = NormalizeCode(voucher.Code);
            return _repository.Create(voucher, adminUserId);
        }

        public void Update(Voucher voucher)
        {
            ValidateForSave(voucher);
            voucher.Code = NormalizeCode(voucher.Code);
            _repository.Update(voucher);
        }

        public void SetActive(long id, bool active) { _repository.SetActive(id, active); }
        public void Archive(long id) { _repository.Archive(id); }

        public VoucherQuote GetCheckoutQuote(long userId, string code, IEnumerable<CartItem> items)
        {
            if (userId <= 0) throw new VoucherValidationException("Sign in to use a voucher.");
            Voucher voucher = _repository.GetByCode(NormalizeCode(code));
            var lines = (items ?? Enumerable.Empty<CartItem>()).Select(item => new VoucherCartLine
            {
                Category = item.Category,
                UnitPrice = item.Price,
                Quantity = item.Quantity
            });
            return VoucherCalculator.Calculate(
                voucher,
                lines,
                DateTimeOffset.UtcNow,
                voucher == null ? 0 : _repository.CountTotalActiveUses(voucher.Id),
                voucher == null ? 0 : _repository.CountUserActiveUses(voucher.Id, userId));
        }

        public static string NormalizeCode(string code)
        {
            return (code ?? string.Empty).Trim().ToUpper(CultureInfo.InvariantCulture);
        }

        public static void ValidateForSave(Voucher voucher)
        {
            if (voucher == null) throw new InvalidOperationException("Voucher details are required.");
            string normalizedCode = NormalizeCode(voucher.Code);
            if (string.IsNullOrWhiteSpace(voucher.Name) || voucher.Name.Trim().Length > 120) throw new InvalidOperationException("Voucher name must be between 1 and 120 characters.");
            if (!System.Text.RegularExpressions.Regex.IsMatch(normalizedCode, "^[A-Z0-9_-]{3,40}$")) throw new InvalidOperationException("Voucher code must be 3 to 40 letters, numbers, underscores, or hyphens.");
            if (voucher.DiscountType != VoucherDiscountTypes.Percentage && voucher.DiscountType != VoucherDiscountTypes.Fixed) throw new InvalidOperationException("Select a valid discount type.");
            if (voucher.DiscountValue <= 0) throw new InvalidOperationException("Discount value must be greater than zero.");
            if (voucher.DiscountType == VoucherDiscountTypes.Percentage && voucher.DiscountValue > 100) throw new InvalidOperationException("Percentage discount cannot exceed 100%.");
            if (voucher.DiscountType == VoucherDiscountTypes.Fixed && voucher.MaximumDiscountAmount.HasValue) throw new InvalidOperationException("Fixed vouchers cannot have a maximum discount cap.");
            if (voucher.MaximumDiscountAmount.HasValue && voucher.MaximumDiscountAmount.Value <= 0) throw new InvalidOperationException("Maximum discount must be greater than zero.");
            if (voucher.MinimumPurchaseAmount < 0) throw new InvalidOperationException("Minimum purchase cannot be negative.");
            if (voucher.ExpiresAt <= voucher.ValidFrom) throw new InvalidOperationException("Expiry must be later than the valid-from date.");
            if (!voucher.AppliesToAllCategories && (voucher.Categories == null || voucher.Categories.Count == 0)) throw new InvalidOperationException("Select at least one eligible category.");
            if (voucher.TotalUsageLimit.HasValue && voucher.TotalUsageLimit.Value <= 0) throw new InvalidOperationException("Total usage limit must be greater than zero.");
            if (voucher.PerUserUsageLimit <= 0) throw new InvalidOperationException("Per-customer limit must be at least one.");
            if (string.IsNullOrWhiteSpace(voucher.TermsAndConditions)) throw new InvalidOperationException("Terms and conditions are required.");
            if (voucher.TermsAndConditions.Length > 8000) throw new InvalidOperationException("Terms and conditions cannot exceed 8000 characters.");
        }
    }
}
```

- [ ] **Step 5: Add category to `CartItem` and include files in the project**

Add `public string Category { get; set; }` after `ProductName` in `Models/CartItem.cs`. Add compile entries for `DAL\VoucherRepository.cs` and `Services\VoucherService.cs`; keep the model and calculator entries added by Task 2 exactly once.

- [ ] **Step 6: Run focused tests and build**

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherCalculator.Tests.ps1
powershell -ExecutionPolicy Bypass -File Tests\VoucherPersistence.Tests.ps1
MSBuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: both tests pass and MSBuild exits `0`.

- [ ] **Step 7: Commit persistence and service**

```powershell
git add -- DAL/VoucherRepository.cs Services/VoucherService.cs Models/CartItem.cs Tests/VoucherPersistence.Tests.ps1 ONYX_DDAC.csproj
git commit -m "feat: add voucher persistence service"
```

---

### Task 4: Loyalty navigation and voucher list

**Files:**
- Create: `Tests/VoucherAdmin.Tests.ps1`
- Modify: `admin_page/admin.Master:400-412`
- Modify: `admin_page/admin.Master.cs:20-45`
- Modify: `admin_page/onyx_admin_promos.aspx`
- Modify: `admin_page/onyx_admin_promos.aspx.cs`
- Modify: `admin_page/onyx_admin_promos.aspx.designer.cs`

**Interfaces:**
- Consumes: `VoucherService.GetAll`, `GetMetrics`, `SetActive`, and `Archive`.
- Produces: the Loyalty list and links to `onyx_admin_voucher_form.aspx`.

- [ ] **Step 1: Add failing admin source-contract checks**

Create `Tests/VoucherAdmin.Tests.ps1` checking that:

```powershell
$root = Split-Path $PSScriptRoot -Parent
$master = Get-Content "$root\admin_page\admin.Master" -Raw
$masterCode = Get-Content "$root\admin_page\admin.Master.cs" -Raw
$list = Get-Content "$root\admin_page\onyx_admin_promos.aspx" -Raw
$listCode = Get-Content "$root\admin_page\onyx_admin_promos.aspx.cs" -Raw

$checks = [ordered]@{
    'Sidebar exposes Loyalty' = $master -match '>\s*Loyalty\s*</a>'
    'Voucher form keeps Loyalty active' = $masterCode -match 'onyx_admin_voucher_form\.aspx'
    'List is database-backed' = $listCode -match 'VoucherService' -and $listCode -notmatch 'mockPromos'
    'List supports server actions' = $list -match 'OnItemCommand="rptVouchers_ItemCommand"' -and $listCode -match 'rptVouchers_ItemCommand'
    'List uses ONYX monochrome theme' = $list -notmatch 'bootstrap' -and $list -notmatch '#00ff87|#a78bfa'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher admin requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher admin source contract passes.'
```

- [ ] **Step 2: Run the admin contract and verify failure**

Run `powershell -ExecutionPolicy Bypass -File Tests\VoucherAdmin.Tests.ps1`.

Expected: failure listing Loyalty/list/form requirements.

- [ ] **Step 3: Rename navigation and active routes**

Change the existing nav anchor text in `admin.Master`:

```aspx
<li><a id="navPromos" runat="server" href="onyx_admin_promos.aspx"><i data-lucide="badge-percent"></i> Loyalty</a></li>
```

In `HighlightActiveNavLink`, map both list and form routes to `navPromos`:

```csharp
{ "onyx_admin_promos.aspx", navPromos },
{ "onyx_admin_voucher_form.aspx", navPromos },
```

- [ ] **Step 4: Replace mock list markup with a server-backed Loyalty page**

Use these required controls in `onyx_admin_promos.aspx`:

```aspx
<div class="page-header">
    <div>
        <h1 class="page-title">Loyalty Management</h1>
        <p class="page-subtitle">Create and control checkout vouchers.</p>
    </div>
    <a class="primary-action" href="onyx_admin_voucher_form.aspx"><i data-lucide="plus"></i>Add voucher</a>
</div>

<div class="stat-strip">
    <div class="stat-box"><asp:Literal ID="litActiveCount" runat="server" /><span>Active vouchers</span></div>
    <div class="stat-box"><asp:Literal ID="litRedeemedCount" runat="server" /><span>Redemptions</span></div>
    <div class="stat-box"><asp:Literal ID="litSavingsGiven" runat="server" /><span>Total savings</span></div>
</div>

<asp:Repeater ID="rptVouchers" runat="server" OnItemCommand="rptVouchers_ItemCommand">
    <ItemTemplate>
        <tr>
            <td><strong><%#: Eval("Name") %></strong><span class="code"><%#: Eval("Code") %></span></td>
            <td><%#: GetDiscountText(Container.DataItem) %></td>
            <td><%#: GetEligibilityText(Container.DataItem) %></td>
            <td><%#: GetMinimumText(Container.DataItem) %></td>
            <td><%#: GetUsageText(Container.DataItem) %></td>
            <td><%#: GetValidityText(Container.DataItem) %></td>
            <td><span class='<%#: "status status--" + GetStatusKey(Container.DataItem) %>'><%#: GetStatusText(Container.DataItem) %></span></td>
            <td class="actions">
                <a href='<%#: "onyx_admin_voucher_form.aspx?id=" + Eval("Id") %>'>Edit</a>
                <asp:LinkButton runat="server" CommandName="Toggle" CommandArgument='<%# Eval("Id") %>' Text='<%#: (bool)Eval("IsActive") ? "Pause" : "Resume" %>' />
                <asp:LinkButton runat="server" CommandName="Archive" CommandArgument='<%# Eval("Id") %>' Text="Archive" OnClientClick="return confirm('Archive this voucher?');" />
            </td>
        </tr>
    </ItemTemplate>
</asp:Repeater>
```

Define local styles with the same values used by Orders: `#111113` panels, `rgba(255,255,255,0.05)` borders, `10px` radius, white primary text, muted uppercase labels, and corresponding `html[data-theme="light"]` overrides. Do not import Bootstrap or use green/purple primary accents.

- [ ] **Step 5: Bind list data and commands**

In `onyx_admin_promos.aspx.cs`, instantiate `VoucherService`, bind metrics and vouchers on first load, and handle `Toggle`/`Archive` with `long.TryParse`. Status helpers must return upcoming, active, paused, expired, exhausted, or archived based on UTC dates, flags, and use limits. After a successful command, rebind; on error, show an encoded `asp:Label` message.

- [ ] **Step 6: Update designer declarations and run the contract**

Declare `litActiveCount`, `litRedeemedCount`, `litSavingsGiven`, `rptVouchers`, and the message label in `onyx_admin_promos.aspx.designer.cs`. Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherAdmin.Tests.ps1
```

Expected: `Voucher admin source contract passes.`

- [ ] **Step 7: Commit the Loyalty list**

```powershell
git add -- admin_page/admin.Master admin_page/admin.Master.cs admin_page/onyx_admin_promos.aspx admin_page/onyx_admin_promos.aspx.cs admin_page/onyx_admin_promos.aspx.designer.cs Tests/VoucherAdmin.Tests.ps1
git commit -m "feat: add loyalty voucher dashboard"
```

---

### Task 5: Voucher create and edit form

**Files:**
- Create: `admin_page/onyx_admin_voucher_form.aspx`
- Create: `admin_page/onyx_admin_voucher_form.aspx.cs`
- Create: `admin_page/onyx_admin_voucher_form.aspx.designer.cs`
- Modify: `ONYX_DDAC.csproj`
- Modify: `Tests/VoucherAdmin.Tests.ps1`

**Interfaces:**
- Consumes: `VoucherService.GetById`, `GetAvailableCategories`, `Create`, and `Update`.
- Produces: valid `Voucher` objects and category selections.

- [ ] **Step 1: Extend the failing form contract**

Load the new form before the existing `$checks` declaration, then add the following entries inside the `$checks` ordered dictionary:

```powershell
$form = if (Test-Path "$root\admin_page\onyx_admin_voucher_form.aspx") { Get-Content "$root\admin_page\onyx_admin_voucher_form.aspx" -Raw } else { '' }

'Dedicated voucher form exists' = $form -match 'Voucher Details'
'Voucher form has identity fields' = $form -match 'ID="txtName"' -and $form -match 'ID="txtCode"'
'Voucher form has discount fields' = $form -match 'ID="ddlDiscountType"' -and $form -match 'ID="txtDiscountValue"' -and $form -match 'ID="txtMaximumDiscount"' -and $form -match 'ID="txtMinimumPurchase"'
'Voucher form has category selection' = $form -match 'ID="chkAllCategories"' -and $form -match 'ID="cblCategories"'
'Voucher form has validity and limits' = $form -match 'ID="txtValidFrom"' -and $form -match 'ID="txtExpiresAt"' -and $form -match 'ID="txtTotalLimit"' -and $form -match 'ID="txtPerUserLimit"'
'Voucher form stores plain text terms' = $form -match 'ID="txtTerms"' -and $form -notmatch 'contenteditable|innerHTML'
'Voucher form uses sticky action bar' = $form -match 'data-voucher-actions' -and $form -match 'position:\s*sticky'
```

- [ ] **Step 2: Build the create/edit markup**

Create a page using `admin.Master` with five `.form-section` panels and these server controls:

```aspx
<asp:TextBox ID="txtName" runat="server" MaxLength="120" CssClass="field-input" />
<asp:TextBox ID="txtCode" runat="server" MaxLength="40" CssClass="field-input code-input" />
<asp:DropDownList ID="ddlDiscountType" runat="server" CssClass="field-select">
    <asp:ListItem Value="percentage">Percentage (%)</asp:ListItem>
    <asp:ListItem Value="fixed">Fixed amount (RM)</asp:ListItem>
</asp:DropDownList>
<asp:TextBox ID="txtDiscountValue" runat="server" TextMode="Number" CssClass="field-input" />
<asp:TextBox ID="txtMaximumDiscount" runat="server" TextMode="Number" CssClass="field-input" />
<asp:TextBox ID="txtMinimumPurchase" runat="server" TextMode="Number" Text="0" CssClass="field-input" />
<asp:CheckBox ID="chkAllCategories" runat="server" Text="All categories" Checked="true" />
<asp:CheckBoxList ID="cblCategories" runat="server" RepeatLayout="Flow" CssClass="category-grid" />
<asp:TextBox ID="txtValidFrom" runat="server" TextMode="DateTimeLocal" CssClass="field-input" />
<asp:TextBox ID="txtExpiresAt" runat="server" TextMode="DateTimeLocal" CssClass="field-input" />
<asp:TextBox ID="txtTotalLimit" runat="server" TextMode="Number" CssClass="field-input" />
<asp:TextBox ID="txtPerUserLimit" runat="server" TextMode="Number" Text="1" CssClass="field-input" />
<asp:CheckBox ID="chkIsActive" runat="server" Text="Voucher is active" Checked="true" />
<asp:TextBox ID="txtTerms" runat="server" TextMode="MultiLine" Rows="10" MaxLength="8000" CssClass="field-textarea" />

<div class="form-actions" data-voucher-actions>
    <asp:Button ID="btnSave" runat="server" Text="Create voucher" CssClass="btn-save" OnClick="btnSave_Click" />
    <a href="onyx_admin_promos.aspx" class="btn-cancel">Cancel</a>
</div>
```

Use the exact form typography, section labels, responsive two-column field rows, light overrides, focus-visible outlines, and sticky action treatment from the current admin product form, adapted to voucher controls.

- [ ] **Step 3: Implement code-behind parsing and save**

In `onyx_admin_voucher_form.aspx.cs`:

- On first load, bind categories from `VoucherService.GetAvailableCategories()` and load an optional positive `id` query parameter.
- Parse money with `decimal.TryParse(..., NumberStyles.Number, CultureInfo.InvariantCulture, out value)` after replacing locale commas only when needed.
- Parse `DateTimeOffset` from `DateTimeLocal` values using the application local timezone and convert to UTC.
- Build `Voucher.Categories` from selected `ListItem` values unless all categories is checked.
- Set code and immutable controls read-only when `HasRedemptions` is true.
- Call `Create` with `Session["UserId"]` converted to `long?`, or call `Update`; redirect to `onyx_admin_promos.aspx` on success.
- Catch expected validation/database exceptions, trace the full exception, and show only a safe summary in `lblMessage`.

The save handler must construct every field explicitly:

```csharp
var voucher = new Voucher
{
    Id = EditId,
    Name = txtName.Text.Trim(),
    Code = txtCode.Text,
    DiscountType = ddlDiscountType.SelectedValue,
    DiscountValue = discountValue,
    MaximumDiscountAmount = maximumDiscount,
    MinimumPurchaseAmount = minimumPurchase,
    AppliesToAllCategories = chkAllCategories.Checked,
    ValidFrom = validFrom,
    ExpiresAt = expiresAt,
    TotalUsageLimit = totalLimit,
    PerUserUsageLimit = perUserLimit,
    IsActive = chkIsActive.Checked,
    TermsAndConditions = txtTerms.Text.Trim(),
    Categories = cblCategories.Items.Cast<ListItem>().Where(item => item.Selected).Select(item => item.Value).ToList()
};
```

- [ ] **Step 4: Add designer and project entries**

Declare every server control in the designer. Add one `<Content Include>` and two dependent `<Compile Include>` entries in `ONYX_DDAC.csproj`, matching other Web Forms pages.

- [ ] **Step 5: Run admin tests and build**

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherAdmin.Tests.ps1
MSBuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: admin contract passes and build exits `0`.

- [ ] **Step 6: Commit the form**

```powershell
git add -- admin_page/onyx_admin_voucher_form.aspx admin_page/onyx_admin_voucher_form.aspx.cs admin_page/onyx_admin_voucher_form.aspx.designer.cs ONYX_DDAC.csproj Tests/VoucherAdmin.Tests.ps1
git commit -m "feat: add voucher management form"
```

---

### Task 6: Checkout preview, apply/remove, and T&C modal

**Files:**
- Create: `Tests/VoucherCheckout.Tests.ps1`
- Modify: `DAL/CheckoutRepository.cs:600-865`
- Modify: `customer_page/onyx_checkout.aspx`
- Modify: `customer_page/onyx_checkout.aspx.cs`
- Modify: `customer_page/onyx_checkout.aspx.designer.cs`
- Modify: `Content/onyx-commerce.css`

**Interfaces:**
- Consumes: `VoucherService.GetCheckoutQuote` and authoritative `CartItem.Category`.
- Produces: `AppliedVoucherCode` and preview `VoucherQuote` for checkout display.

- [ ] **Step 1: Write the failing checkout contract**

Create `Tests/VoucherCheckout.Tests.ps1` with checks for:

```powershell
$root = Split-Path $PSScriptRoot -Parent
$markup = Get-Content "$root\customer_page\onyx_checkout.aspx" -Raw
$page = Get-Content "$root\customer_page\onyx_checkout.aspx.cs" -Raw
$checkoutRepo = Get-Content "$root\DAL\CheckoutRepository.cs" -Raw

$checks = [ordered]@{
    'Checkout loads authoritative category' = $checkoutRepo -match 'product_category' -and $checkoutRepo -match 'Category\s*='
    'Checkout can apply and remove voucher' = $markup -match 'ID="txtVoucherCode"' -and $markup -match 'ID="btnApplyVoucher"' -and $markup -match 'ID="btnRemoveVoucher"' -and $page -match 'btnApplyVoucher_Click' -and $page -match 'btnRemoveVoucher_Click'
    'Checkout displays voucher totals' = $markup -match 'litCheckoutSubtotal' -and $markup -match 'litVoucherDiscount' -and $markup -match 'litCheckoutTotal'
    'Terms use an accessible modal' = $markup -match 'role="dialog"' -and $markup -match 'aria-modal="true"' -and $page -match 'HtmlEncode'
    'Checkout passes code to service' = $page -match 'AppliedVoucherCode' -and $page -match 'StartCheckout[\s\S]*AppliedVoucherCode'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher checkout requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher checkout source contract passes.'
```

- [ ] **Step 2: Run the checkout contract and verify failure**

Run `powershell -ExecutionPolicy Bypass -File Tests\VoucherCheckout.Tests.ps1`.

Expected: failure listing checkout, Stripe, and lifecycle requirements.

- [ ] **Step 3: Hydrate authoritative categories**

In `CheckoutRepository.LoadAuthoritativeCart`, select `p.category AS product_category`, assign it to `CheckoutItem.Category`, copy it in `ToCartItem`, and add `Category` to the private `CheckoutItem` class.

- [ ] **Step 4: Add checkout voucher controls and summary**

Add this structure before the total:

```aspx
<div class="onyx-voucher-entry">
    <label for="<%= txtVoucherCode.ClientID %>">Voucher code</label>
    <div class="onyx-voucher-entry__row">
        <asp:TextBox ID="txtVoucherCode" runat="server" MaxLength="40" CssClass="onyx-checkout-input" />
        <asp:Button ID="btnApplyVoucher" runat="server" Text="Apply" OnClick="btnApplyVoucher_Click" CssClass="onyx-voucher-apply" />
    </div>
    <asp:Label ID="lblVoucherMessage" runat="server" Visible="false" CssClass="onyx-checkout-message" />
</div>

<asp:Panel ID="pnlAppliedVoucher" runat="server" Visible="false" CssClass="onyx-voucher-applied">
    <div><strong><asp:Literal ID="litVoucherName" runat="server" /></strong><span><asp:Literal ID="litVoucherCode" runat="server" /></span></div>
    <button type="button" class="onyx-voucher-terms-link" data-voucher-terms-open>T&amp;C apply</button>
    <asp:LinkButton ID="btnRemoveVoucher" runat="server" Text="Remove" OnClick="btnRemoveVoucher_Click" />
</asp:Panel>

<div class="onyx-checkout-totals">
    <div><span>Subtotal</span><asp:Literal ID="litCheckoutSubtotal" runat="server" /></div>
    <asp:Panel ID="pnlVoucherDiscount" runat="server" Visible="false"><span>Voucher discount</span><strong>-<asp:Literal ID="litVoucherDiscount" runat="server" /></strong></asp:Panel>
    <div class="onyx-checkout-total"><span>Total</span><asp:Literal ID="litCheckoutTotal" runat="server" /></div>
</div>

<div id="voucherTermsModal" class="onyx-voucher-modal" hidden role="dialog" aria-modal="true" aria-labelledby="voucherTermsTitle">
    <div class="onyx-voucher-modal__panel">
        <button type="button" data-voucher-terms-close aria-label="Close terms">&times;</button>
        <h2 id="voucherTermsTitle">Voucher terms</h2>
        <div class="onyx-voucher-terms"><asp:Literal ID="litVoucherTerms" runat="server" /></div>
    </div>
</div>
```

Add this JavaScript after the modal; it opens/closes on controls, backdrop, and Escape while restoring focus:

```javascript
(function () {
    var modal = document.getElementById('voucherTermsModal');
    if (!modal) return;
    var opener = document.querySelector('[data-voucher-terms-open]');
    var closer = modal.querySelector('[data-voucher-terms-close]');
    var previousFocus = null;

    function openTerms() {
        previousFocus = document.activeElement;
        modal.hidden = false;
        document.body.classList.add('voucher-modal-open');
        closer.focus();
    }

    function closeTerms() {
        modal.hidden = true;
        document.body.classList.remove('voucher-modal-open');
        if (previousFocus && previousFocus.focus) previousFocus.focus();
    }

    if (opener) opener.addEventListener('click', openTerms);
    closer.addEventListener('click', closeTerms);
    modal.addEventListener('click', function (event) {
        if (event.target === modal) closeTerms();
    });
    document.addEventListener('keydown', function (event) {
        if (modal.hidden) return;
        if (event.key === 'Escape') {
            closeTerms();
            return;
        }
        if (event.key === 'Tab') {
            var focusable = modal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
            if (!focusable.length) return;
            var first = focusable[0];
            var last = focusable[focusable.length - 1];
            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault();
                last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault();
                first.focus();
            }
        }
    });
}());
```

Add monochrome responsive styles and light-theme rules in `Content/onyx-commerce.css` using `#111113` panels, `rgba(255,255,255,0.08)` borders, white/muted text, a fixed translucent backdrop, a maximum `560px` modal panel, and `html[data-theme="light"]` equivalents.

- [ ] **Step 5: Implement apply/remove and quote display**

In code-behind, add a ViewState-backed `AppliedVoucherCode`. `btnApplyVoucher_Click` loads the validated cart, calls `VoucherService.GetCheckoutQuote`, stores the normalized code, and rebinds. `btnRemoveVoucher_Click` clears the property and rebinds.

During `BindCheckout`, always set subtotal. If a code exists, recalculate the quote; if recalculation fails, clear the code and show the safe message. Encode terms as:

```csharp
litVoucherTerms.Text = Server.HtmlEncode(quote.TermsAndConditions)
    .Replace("\r\n", "<br />")
    .Replace("\n", "<br />");
```

Never place unencoded terms in markup.

- [ ] **Step 6: Update designer declarations and run the focused UI checks**

Declare all new controls, then run `powershell -ExecutionPolicy Bypass -File Tests\VoucherCheckout.Tests.ps1`.

Expected: `Voucher checkout source contract passes.`

- [ ] **Step 7: Commit checkout preview**

```powershell
git add -- DAL/CheckoutRepository.cs customer_page/onyx_checkout.aspx customer_page/onyx_checkout.aspx.cs customer_page/onyx_checkout.aspx.designer.cs Content/onyx-commerce.css Tests/VoucherCheckout.Tests.ps1
git commit -m "feat: add voucher checkout preview"
```

---

### Task 7: Transactional voucher reservation and order snapshots

**Files:**
- Modify: `Models/Order.cs`
- Modify: `Models/OrderDetail.cs`
- Modify: `Models/OrderSummary.cs`
- Modify: `DAL/CheckoutRepository.cs:35-140,600-865`
- Modify: `Services/CheckoutService.cs:27-120`
- Modify: `customer_page/onyx_checkout.aspx.cs:70-100`
- Modify: `Tests/VoucherPersistence.Tests.ps1`

**Interfaces:**
- Changes: `CheckoutService.StartCheckout(..., string voucherCode, string applicationBaseUrl)`.
- Changes: `CheckoutRepository.CreatePendingOrderWithReservations(..., string voucherCode, ..., DateTimeOffset expiresAt)`.
- Produces: `Order.SubtotalAmount`, `DiscountAmount`, `VoucherId`, `VoucherCode`, and `VoucherName`.

- [ ] **Step 1: Extend persistence tests for transactional authority**

Load the checkout repository in `Tests/VoucherPersistence.Tests.ps1` and add checks requiring:

```powershell
$checkoutRepo = Get-Content "$root\DAL\CheckoutRepository.cs" -Raw

'Checkout locks voucher before reservation' =
    $checkoutRepo -match 'VoucherRepository\.LockByCode' -and
    $checkoutRepo -match 'VoucherRepository\.ReserveRedemption'
'Checkout stores subtotal discount and voucher snapshots' =
    $checkoutRepo -match 'subtotal_amount' -and
    $checkoutRepo -match 'discount_amount' -and
    $checkoutRepo -match 'voucher_code' -and
    $checkoutRepo -match 'voucher_name'
'Checkout recalculates inside transaction' =
    $checkoutRepo -match 'VoucherCalculator\.Calculate'
```

- [ ] **Step 2: Add order snapshot properties**

Add to `Order`, `OrderDetail`, and `OrderSummary` where each view needs them:

```csharp
public decimal SubtotalAmount { get; set; }
public decimal DiscountAmount { get; set; }
public long? VoucherId { get; set; }
public string VoucherCode { get; set; }
public string VoucherName { get; set; }
```

- [ ] **Step 3: Pass the code through service and page boundaries**

Add `string voucherCode` before `applicationBaseUrl` in `CheckoutService.StartCheckout`, normalize it with `VoucherService.NormalizeCode`, and pass it to the repository. Update `btnPayWithStripe_Click` to pass `AppliedVoucherCode`.

- [ ] **Step 4: Calculate and reserve inside the order transaction**

After authoritative cart/stock validation, compute `subtotal`. If the normalized code is non-empty:

```csharp
Voucher voucher = VoucherRepository.LockByCode(conn, tx, voucherCode);
int totalUsed = voucher == null ? 0 : VoucherRepository.CountTotalActiveUses(conn, tx, voucher.Id);
int userUsed = voucher == null ? 0 : VoucherRepository.CountUserActiveUses(conn, tx, voucher.Id, userId);
VoucherQuote quote = VoucherCalculator.Calculate(
    voucher,
    items.Select(item => new VoucherCartLine
    {
        Category = item.Category,
        UnitPrice = item.UnitPrice,
        Quantity = item.Quantity
    }),
    DateTimeOffset.UtcNow,
    totalUsed,
    userUsed);
```

For no voucher, use subtotal as total and zero discount. Extend `InsertPendingOrder` to persist all snapshots. Immediately after the order insert, call `ReserveRedemption` when `quote.VoucherId > 0`, before order items/cart changes.

- [ ] **Step 5: Preserve idempotent existing attempts**

Extend `FindActivePendingOrder` to hydrate voucher fields. Before returning an existing attempt, compare its normalized `VoucherCode` with the requested code:

```csharp
if (!string.Equals(
    VoucherService.NormalizeCode(activeOrder.VoucherCode),
    VoucherService.NormalizeCode(voucherCode),
    StringComparison.Ordinal))
{
    throw new InvalidOperationException("The voucher cannot be changed on an active payment attempt.");
}
```

- [ ] **Step 6: Populate returned order snapshots and run tests/build**

Set every new `Order` property before the transaction returns. Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherPersistence.Tests.ps1
MSBuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: persistence contract passes and build exits `0`.

- [ ] **Step 7: Commit transactional reservation**

```powershell
git add -- Models/Order.cs Models/OrderDetail.cs Models/OrderSummary.cs DAL/CheckoutRepository.cs Services/CheckoutService.cs customer_page/onyx_checkout.aspx.cs Tests/VoucherPersistence.Tests.ps1
git commit -m "feat: reserve vouchers during checkout"
```

---

### Task 8: Stripe discount and redemption payment lifecycle

**Files:**
- Modify: `Services/StripePaymentService.cs:35-75,330-370`
- Modify: `DAL/PaymentRepository.cs:60-190,415-445`
- Modify: `DAL/CheckoutRepository.cs:449-510`
- Modify: `Tests/VoucherCheckout.Tests.ps1`

**Interfaces:**
- Consumes: `Order.DiscountAmount`, `VoucherCode`, and `VoucherRepository` transition helpers.
- Produces: a one-time Stripe coupon and terminal voucher redemption state.

- [ ] **Step 1: Extend checkout tests for exact Stripe and lifecycle behavior**

Load the Stripe and payment repository sources, then require order-specific idempotency and amount-off fields:

```powershell
$stripe = Get-Content "$root\Services\StripePaymentService.cs" -Raw
$paymentRepo = Get-Content "$root\DAL\PaymentRepository.cs" -Raw

'Stripe creates one-time order coupon' =
    $stripe -match 'CouponCreateOptions' -and
    $stripe -match 'AmountOff' -and
    $stripe -match 'Currency\s*=\s*"myr"' -and
    $stripe -match 'Duration\s*=\s*"once"' -and
    $stripe -match 'MaxRedemptions\s*=\s*1' -and
    $stripe -match 'onyx-voucher-coupon-'
'Paid orders redeem voucher atomically' =
    $paymentRepo -match 'MarkOrderPaid[\s\S]*RedeemForOrder[\s\S]*tx\.Commit'
'Cancelled orders release voucher atomically' =
    $paymentRepo -match 'ReleaseForOrder[\s\S]*tx\.Commit'
```

- [ ] **Step 2: Create and attach an idempotent Stripe coupon**

Before creating the Session, when `order.DiscountAmount > 0`, create:

```csharp
long amountOff = checked((long)Math.Round(order.DiscountAmount * 100m, 0, MidpointRounding.AwayFromZero));
Coupon coupon = new CouponService().Create(
    new CouponCreateOptions
    {
        AmountOff = amountOff,
        Currency = "myr",
        Duration = "once",
        MaxRedemptions = 1,
        Name = order.VoucherCode,
        Metadata = new Dictionary<string, string>
        {
            { "onyx_order_id", order.Id.ToString() },
            { "onyx_voucher_id", order.VoucherId.Value.ToString() }
        }
    },
    new RequestOptions { IdempotencyKey = "onyx-voucher-coupon-" + order.Id });

options.Discounts = new List<SessionDiscountOptions>
{
    new SessionDiscountOptions { Coupon = coupon.Id }
};
```

Keep original order-item line prices. Existing `ValidatePaymentTerms` already compares `session.AmountTotal` with `orders.total_amount`; retain that check unchanged.

- [ ] **Step 3: Redeem voucher in paid transaction**

In `PaymentRepository.CompletePayment`, call:

```csharp
VoucherRepository.RedeemForOrder(conn, tx, order.OrderId);
```

after `MarkOrderPaid` and before `tx.Commit`. The helper must treat no voucher row as a valid no-op and only transition pending to redeemed.

- [ ] **Step 4: Release voucher in all cancellation transactions**

Call `VoucherRepository.ReleaseForOrder(conn, tx, order.OrderId)` in `PaymentRepository.CancelPayment` after the order cancellation update and before commit. Also call it in `CheckoutRepository.CancelPendingOrderAndReleaseReservations` before commit so definitive Session-creation failures and user-requested cancellations release the voucher.

- [ ] **Step 5: Run checkout tests and build**

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherCheckout.Tests.ps1
powershell -ExecutionPolicy Bypass -File Tests\PendingPaymentCancellation.Tests.ps1
MSBuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: voucher checkout and existing cancellation contracts pass; build exits `0`.

- [ ] **Step 6: Commit Stripe and lifecycle integration**

```powershell
git add -- Services/StripePaymentService.cs DAL/PaymentRepository.cs DAL/CheckoutRepository.cs Tests/VoucherCheckout.Tests.ps1
git commit -m "feat: apply voucher discounts to payments"
```

---

### Task 9: Order, invoice, confirmation, and admin summaries

**Files:**
- Modify: `DAL/OrderRepository.cs`
- Modify: `admin_page/onyx_admin_order_details.aspx`, `.cs`, `.designer.cs`
- Modify: `customer_page/onyx_order_history.aspx`, `.cs`
- Modify: `customer_page/onyx_invoice.aspx`, `.cs`, `.designer.cs`
- Modify: `customer_page/onyx_payment_confirmation.aspx`, `.cs`
- Modify: `Tests/VoucherCheckout.Tests.ps1`

**Interfaces:**
- Consumes: order snapshot columns.
- Produces: identical subtotal, voucher, discount, and final total across post-checkout views.

- [ ] **Step 1: Add failing display checks**

Load each display source before the existing `$checks` declaration, then add these exact entries inside the `$checks` ordered dictionary in `Tests/VoucherCheckout.Tests.ps1`:

```powershell
$orderRepo = Get-Content "$root\DAL\OrderRepository.cs" -Raw
$adminDetails = Get-Content "$root\admin_page\onyx_admin_order_details.aspx" -Raw
$adminDetailsCode = Get-Content "$root\admin_page\onyx_admin_order_details.aspx.cs" -Raw
$history = Get-Content "$root\customer_page\onyx_order_history.aspx" -Raw
$historyCode = Get-Content "$root\customer_page\onyx_order_history.aspx.cs" -Raw
$invoice = Get-Content "$root\customer_page\onyx_invoice.aspx" -Raw
$invoiceCode = Get-Content "$root\customer_page\onyx_invoice.aspx.cs" -Raw
$confirmation = Get-Content "$root\customer_page\onyx_payment_confirmation.aspx" -Raw
$confirmationCode = Get-Content "$root\customer_page\onyx_payment_confirmation.aspx.cs" -Raw

'Order repository hydrates voucher snapshots' =
    $orderRepo -match 'subtotal_amount' -and
    $orderRepo -match 'discount_amount' -and
    $orderRepo -match 'voucher_code' -and
    $orderRepo -match 'voucher_name'
'Admin order shows voucher breakdown and free shipping' =
    $adminDetails -match 'pnlVoucherSummary' -and
    $adminDetailsCode -match 'SubtotalAmount' -and
    $adminDetailsCode -match 'DiscountAmount' -and
    $adminDetails -match 'RM 0\.00' -and
    $adminDetails -notmatch 'RM 10\.00'
'Order history shows voucher savings' =
    ($history + $historyCode) -match 'VoucherCode' -and
    ($history + $historyCode) -match 'DiscountAmount'
'Invoice shows stored voucher totals' =
    ($invoice + $invoiceCode) -match 'SubtotalAmount' -and
    ($invoice + $invoiceCode) -match 'DiscountAmount' -and
    ($invoice + $invoiceCode) -match 'VoucherCode'
'Payment confirmation shows stored voucher totals' =
    ($confirmation + $confirmationCode) -match 'SubtotalAmount' -and
    ($confirmation + $confirmationCode) -match 'DiscountAmount' -and
    ($confirmation + $confirmationCode) -match 'VoucherCode'
```

- [ ] **Step 2: Hydrate snapshots in every order query**

For queries returning `Order`, `OrderDetail`, or `OrderSummary`, select:

```sql
o.subtotal_amount,
o.discount_amount,
o.voucher_id,
o.voucher_code,
o.voucher_name
```

Map nullable strings/IDs safely and map money with `GetDecimal`. Do not calculate subtotal from current product prices.

- [ ] **Step 3: Add admin order breakdown**

Replace the current summary with:

```aspx
<div class="summary-row"><div class="summary-key">Items subtotal</div><div class="summary-value"><asp:Literal ID="litSubtotal" runat="server" /></div></div>
<asp:Panel ID="pnlVoucherSummary" runat="server" Visible="false">
    <div class="summary-row"><div class="summary-key"><asp:Literal ID="litVoucherLabel" runat="server" /></div><div class="summary-value">-<asp:Literal ID="litDiscount" runat="server" /></div></div>
</asp:Panel>
<div class="summary-row"><div class="summary-key">Shipping</div><div class="summary-value">RM 0.00</div></div>
<div class="summary-row summary-total"><div class="summary-key">Total charged</div><div class="summary-value"><asp:Literal ID="litTotal" runat="server" /></div></div>
```

Bind snapshot amounts through `CurrencyHelper.FormatMyr` and encode voucher name/code.

- [ ] **Step 4: Add customer history, invoice, and confirmation breakdowns**

Use the same labels and stored values. Hide the voucher row when `DiscountAmount == 0`. Invoice and confirmation must show `SubtotalAmount`, negative `DiscountAmount`, and `TotalAmount`; order history may show compact text such as `MOUSE20 · saved RM 40.00`.

- [ ] **Step 5: Run focused tests and build**

```powershell
powershell -ExecutionPolicy Bypass -File Tests\VoucherCheckout.Tests.ps1
MSBuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: display checks pass and build exits `0`.

- [ ] **Step 6: Commit order displays**

```powershell
git add -- DAL/OrderRepository.cs admin_page/onyx_admin_order_details.aspx admin_page/onyx_admin_order_details.aspx.cs admin_page/onyx_admin_order_details.aspx.designer.cs customer_page/onyx_order_history.aspx customer_page/onyx_order_history.aspx.cs customer_page/onyx_invoice.aspx customer_page/onyx_invoice.aspx.cs customer_page/onyx_invoice.aspx.designer.cs customer_page/onyx_payment_confirmation.aspx customer_page/onyx_payment_confirmation.aspx.cs Tests/VoucherCheckout.Tests.ps1
git commit -m "feat: show voucher savings on orders"
```

---

### Task 10: Full regression verification and handoff

**Files:**
- Modify only files needed to fix failures directly caused by Tasks 1–9.

**Interfaces:**
- Consumes: the complete voucher feature.
- Produces: evidence that the source contracts and application build pass together.

- [ ] **Step 1: Run all voucher-focused tests**

```powershell
$tests = @(
  'Tests\VoucherSchema.Tests.ps1',
  'Tests\VoucherCalculator.Tests.ps1',
  'Tests\VoucherPersistence.Tests.ps1',
  'Tests\VoucherAdmin.Tests.ps1',
  'Tests\VoucherCheckout.Tests.ps1'
)
foreach ($test in $tests) {
  powershell -ExecutionPolicy Bypass -File $test
  if ($LASTEXITCODE -ne 0) { throw "$test failed" }
}
```

Expected: five pass messages and exit code `0`.

- [ ] **Step 2: Run the full existing PowerShell sweep once per physical file**

```powershell
$files = Get-ChildItem Tests, tests -Filter *.Tests.ps1 -File |
  Sort-Object FullName -Unique
foreach ($file in $files) {
  powershell -ExecutionPolicy Bypass -File $file.FullName
  if ($LASTEXITCODE -ne 0) { throw "$($file.FullName) failed" }
}
```

Expected: every script exits `0`.

- [ ] **Step 3: Run whitespace and project build verification**

```powershell
git diff --check
MSBuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: no whitespace errors and `Build succeeded` with zero errors.

- [ ] **Step 4: Run database verification when PostgreSQL is available**

Apply `App_Data/20260717_voucher_loyalty_management.sql` twice to a disposable database. Verify the second run succeeds, then run SQL scenarios for one pending reservation, release, reuse, redemption, and a concurrent final-limit attempt. Do not run this migration against production from an implementation session.

- [ ] **Step 5: Run Stripe test-mode scenarios**

Verify one successful voucher payment, one user cancellation, one expired Session, and one repeated webhook. For each scenario compare checkout display, `orders.total_amount`, Stripe `amount_total`, and voucher redemption status.

- [ ] **Step 6: Inspect the final diff and repository status**

```powershell
git status --short
git diff --stat origin/main...HEAD
git log --oneline --decorate -12
```

Confirm unrelated pre-existing files remain uncommitted and unchanged by voucher commits.

- [ ] **Step 7: Commit any verification-only corrections**

If and only if verification required a code correction, stage only those voucher-related files and commit:

```powershell
git commit -m "fix: complete voucher integration verification"
```

If no corrections were needed, do not create an empty commit.
