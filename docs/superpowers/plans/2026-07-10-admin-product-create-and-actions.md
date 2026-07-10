# Admin Product Creation and Action Bar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair product creation against the imported RDS data and provide a persistent, accessible ONYX action bar for the long admin product form.

**Architecture:** Repair identity state through an idempotent deployment migration rather than mutating sequences during normal repository inserts. Keep the existing Web Forms save pipeline, add non-sensitive failure guidance at the page boundary, and make the action bar sticky with a small client-side double-submit guard.

**Tech Stack:** ASP.NET Web Forms on .NET Framework, C#, Npgsql/PostgreSQL, PowerShell source-contract tests, HTML/CSS/vanilla JavaScript.

## Global Constraints

- Do not expose SQL statements, database hostnames, credentials, or stack traces in browser messages.
- Do not insert or delete product data while repairing the identity sequence.
- Preserve the existing monochrome ONYX admin visual identity in dark and light modes.
- Preserve unrelated modifications in `Services/PersonalizationService.cs`, `Web.config`, catalog files, uploaded assets, and `outputs/`.
- Use the configured user-level `ONYX_DB_*` values for database verification and never print the password.
- The primary action says `Save product` in create mode and `Save changes` in edit mode.
- The action bar remains keyboard accessible, responsive, and usable with reduced motion.

---

### Task 1: Product identity sequence migration

**Files:**
- Create: `App_Data/20260710_repair_products_identity_sequence.sql`
- Modify: `Tests/AdminProductForm.Tests.ps1`

**Interfaces:**
- Consumes: PostgreSQL identity sequence returned by `pg_get_serial_sequence('public.products', 'id')`.
- Produces: an idempotent migration that makes the next generated product ID greater than every existing `products.id`.

- [ ] **Step 1: Add a failing source-contract test**

Add the migration path and content near the other migration variables in `Tests/AdminProductForm.Tests.ps1`:

```powershell
$sequenceMigrationPath = "$root\App_Data\20260710_repair_products_identity_sequence.sql"
$sequenceMigration = if (Test-Path $sequenceMigrationPath) { Get-Content $sequenceMigrationPath -Raw } else { '' }
```

Add this check to `$checks`:

```powershell
'Product identity repair safely advances an imported sequence' =
    $sequenceMigration -match 'LOCK TABLE public\.products IN SHARE ROW EXCLUSIVE MODE' -and
    $sequenceMigration -match "pg_get_serial_sequence\('public\.products',\s*'id'\)" -and
    $sequenceMigration -match 'MAX\(id\)' -and
    $sequenceMigration -match 'setval' -and
    $sequenceMigration -match 'v_max_id IS NOT NULL'
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run:

```powershell
& .\Tests\AdminProductForm.Tests.ps1
```

Expected: exit code `1` and `Missing admin product form requirements: Product identity repair safely advances an imported sequence`.

- [ ] **Step 3: Create the guarded, idempotent migration**

Create `App_Data/20260710_repair_products_identity_sequence.sql` with:

```sql
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
```

- [ ] **Step 4: Run the focused test and verify it passes**

Run:

```powershell
& .\Tests\AdminProductForm.Tests.ps1
```

Expected: exit code `0` and `Admin product form source contract passes.`

- [ ] **Step 5: Commit the migration contract**

```powershell
git add -- App_Data/20260710_repair_products_identity_sequence.sql Tests/AdminProductForm.Tests.ps1
git commit -m "fix: repair imported product identity sequence"
```

### Task 2: Persistent ONYX action bar and failure guidance

**Files:**
- Modify: `admin_page/onyx_admin_products_form.aspx`
- Modify: `admin_page/onyx_admin_products_form.aspx.cs`
- Modify: `Tests/AdminProductForm.Tests.ps1`

**Interfaces:**
- Consumes: existing `btnSave_Click`, `btnDelete_Click`, `validateProductImagesBeforeSubmit()`, `IsEditMode`, and `ShowAlert` behavior.
- Produces: `validateAndPrepareProductSave(button): boolean`, mode-specific save labels, sticky action markup identified by `data-admin-product-actions`, and a non-sensitive failure message.

- [ ] **Step 1: Add failing checks for action behavior and visual states**

Add these checks to `$checks` in `Tests/AdminProductForm.Tests.ps1`:

```powershell
'Product form uses a persistent ONYX command bar' =
    $markup -match 'data-admin-product-actions' -and
    $markup -match '\.form-actions\s*\{[\s\S]*position:\s*sticky' -and
    $markup -match 'backdrop-filter:\s*blur' -and
    $markup -match '\.btn-save:focus-visible' -and
    $markup -match '@media\s*\(prefers-reduced-motion:\s*reduce\)'

'Product save action prevents duplicate submissions' =
    $markup -match 'validateAndPrepareProductSave' -and
    $markup -match 'button\.disabled\s*=\s*true' -and
    $markup -match "button\.value\s*=\s*'Saving"

'Product save action uses mode-specific copy and safe failure guidance' =
    $code -match 'btnSave\.Text\s*=\s*IsEditMode\s*\?\s*"Save changes' -and
    $code -match '"Save product' -and
    $code -match 'The product was not created\. Check the database connection and try again, or contact an administrator\.' -and
    $code -notmatch 'ShowAlert\(ex\.ToString\(\)'
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run:

```powershell
& .\Tests\AdminProductForm.Tests.ps1
```

Expected: exit code `1` listing the three new action-bar requirements.

- [ ] **Step 3: Replace the action CSS with the sticky command-strip styles**

Update the `.form-actions`, `.btn-save`, `.btn-delete`, `.btn-cancel`, focus, responsive, light-mode, and reduced-motion rules in `admin_page/onyx_admin_products_form.aspx` so the core declarations include:

```css
.form-actions {
    position: sticky;
    bottom: 18px;
    z-index: 20;
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 34px -18px 0;
    padding: 12px 14px;
    border: 1px solid rgba(255,255,255,0.10);
    border-top-color: rgba(255,255,255,0.18);
    border-radius: 9px;
    background: rgba(12,12,15,0.88);
    box-shadow: 0 18px 46px rgba(0,0,0,0.34);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
}
.form-actions__main { display: flex; align-items: center; gap: 10px; }
.btn-save, .btn-delete, .btn-cancel {
    min-height: 42px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 6px;
    font-family: inherit;
    font-size: 11px;
    font-weight: 750;
    letter-spacing: 0.09em;
    text-transform: uppercase;
    transition: transform 140ms ease, background 140ms ease, border-color 140ms ease, color 140ms ease;
}
.btn-save { padding: 0 24px; border: 1px solid #fff; background: #fff; color: #08080a; cursor: pointer; }
.btn-save:hover { transform: translateY(-1px); background: #e8e8ea; border-color: #e8e8ea; }
.btn-save:disabled { cursor: wait; opacity: 0.58; transform: none; }
.btn-delete { margin-left: 8px; padding: 0 17px; }
.btn-cancel { padding: 0 18px; border: 1px solid rgba(255,255,255,0.14); color: rgba(255,255,255,0.68); }
.btn-save:focus-visible, .btn-delete:focus-visible, .btn-cancel:focus-visible {
    outline: 2px solid #fff;
    outline-offset: 3px;
}
@media (prefers-reduced-motion: reduce) {
    .btn-save, .btn-delete, .btn-cancel { transition: none; }
}
```

Keep the existing red destructive colors and add light-mode overrides for the command surface, borders, focus rings, and cancel text. In the existing mobile query, set `.form-actions` and `.form-actions__main` to a one-column layout and make all three controls full width.

- [ ] **Step 4: Update the action markup and add the submission guard**

Use this structure for the action controls:

```aspx
<div class="form-actions" data-admin-product-actions>
    <div class="form-actions__main">
        <asp:Button ID="btnSave" runat="server" Text="Save product →"
            CssClass="btn-save" OnClick="btnSave_Click"
            OnClientClick="return validateAndPrepareProductSave(this);" />
        <a href="onyx_admin_products.aspx" class="btn-cancel">Cancel</a>
    </div>
    <asp:Button ID="btnDelete" runat="server" Text="Delete product"
        CssClass="btn-delete" OnClick="btnDelete_Click" CausesValidation="false"
        OnClientClick="return confirm('Delete this product? This cannot be undone.');" />
    <span class="required-note"><span class="req">*</span> Required fields</span>
</div>
```

Add this function beside the existing product image validation script:

```javascript
function validateAndPrepareProductSave(button) {
    if (!validateProductImagesBeforeSubmit()) return false;

    window.setTimeout(function () {
        button.disabled = true;
        button.value = 'Saving…';
        button.setAttribute('aria-disabled', 'true');
        var form = button.closest('form');
        if (form) form.setAttribute('aria-busy', 'true');
    }, 0);

    return true;
}
```

- [ ] **Step 5: Set mode-specific copy and improve the failure message**

In `Page_Load`, after `_EditId` is established and before the method returns, add:

```csharp
btnSave.Text = IsEditMode ? "Save changes →" : "Save product →";
```

Keep `Trace.TraceError` unchanged. Replace the generic `catch (Exception)` alert in `btnSave_Click` with:

```csharp
ShowAlert(
    IsEditMode
        ? "The product changes were not saved. Check the database connection and try again, or contact an administrator."
        : "The product was not created. Check the database connection and try again, or contact an administrator.",
    isError: true);
```

- [ ] **Step 6: Run the focused test and verify it passes**

Run:

```powershell
& .\Tests\AdminProductForm.Tests.ps1
```

Expected: exit code `0` and `Admin product form source contract passes.`

- [ ] **Step 7: Commit the admin form changes**

```powershell
git add -- admin_page/onyx_admin_products_form.aspx admin_page/onyx_admin_products_form.aspx.cs Tests/AdminProductForm.Tests.ps1
git commit -m "feat: polish admin product save actions"
```

### Task 3: Apply and prove the RDS repair

**Files:**
- Read: `App_Data/20260710_repair_products_identity_sequence.sql`

**Interfaces:**
- Consumes: user-level `ONYX_DB_HOST`, `ONYX_DB_PORT`, `ONYX_DB_NAME`, `ONYX_DB_USER`, and `ONYX_DB_PASSWORD`.
- Produces: synchronized `public.products_id_seq` state on the configured RDS database without persistent diagnostic data.

- [ ] **Step 1: Record the pre-migration identity state**

Run a read-only query using `psql.exe` and `PGPASSWORD` populated only for the child process:

```sql
SELECT MAX(id) AS max_product_id FROM public.products;
SELECT last_value, is_called FROM public.products_id_seq;
```

Expected before repair in the current database: maximum product ID `20`, sequence value `15`.

- [ ] **Step 2: Apply the migration twice**

Run `App_Data/20260710_repair_products_identity_sequence.sql` twice with `-X -v ON_ERROR_STOP=1` against the user-level ONYX database values.

Expected: both executions exit `0`; no products are inserted or deleted.

- [ ] **Step 3: Prove generated product IDs work without retaining test data**

Run:

```sql
BEGIN;
INSERT INTO public.products (name, brand, category, description, price, stock_qty, image_url)
VALUES ('__ONYX_CREATE_DIAGNOSTIC__', 'ONYX', 'Mouse', NULL, 1.00, 0, NULL)
RETURNING id;
ROLLBACK;
SELECT COUNT(*) AS diagnostic_rows
FROM public.products
WHERE name = '__ONYX_CREATE_DIAGNOSTIC__';
```

Expected: generated ID greater than `20`, `ROLLBACK`, and `diagnostic_rows = 0`.

- [ ] **Step 4: Check for failed-attempt upload leftovers without deleting them**

Run `git status --short` and report untracked `Content/uploads/products/product-*` files. Do not remove them because the repository does not prove whether they are user assets or failed-attempt artifacts.

### Task 4: Full verification and UI inspection

**Files:**
- Verify: `Tests/*.Tests.ps1`
- Build: `ONYX_DDAC.sln`
- Inspect: `admin_page/onyx_admin_products_form.aspx`

**Interfaces:**
- Consumes: completed migration and admin form changes.
- Produces: fresh test, build, database, and visual evidence for handoff.

- [ ] **Step 1: Run every source-contract test**

```powershell
$failed = @()
Get-ChildItem .\Tests\*.Tests.ps1 | Sort-Object Name | ForEach-Object {
    try { & $_.FullName } catch { $failed += $_.Name; Write-Error $_ }
}
if ($failed.Count -gt 0) { throw ('Test failures: ' + ($failed -join ', ')) }
```

Expected: exit code `0` with every test reporting its pass message.

- [ ] **Step 2: Build the Visual Studio solution**

Use Visual Studio 2022 MSBuild:

```powershell
& "$env:ProgramFiles\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" .\ONYX_DDAC.sln /t:Build /p:Configuration=Debug /m /nologo /verbosity:minimal
```

Expected: exit code `0` and `ONYX_DDAC.dll` produced.

- [ ] **Step 3: Inspect the running admin form when available**

Open the local add-product page in the in-app browser. Verify at desktop and a narrow viewport:

- the command strip remains visible while scrolling;
- `Save product →`, `Cancel`, and the required-fields note have clear hierarchy;
- delete is hidden in create mode and separated in edit mode;
- keyboard focus is visible;
- clicking save changes the primary control to `Saving…` only after validation passes;
- dark and light themes retain readable contrast.

If no local app is running or admin authentication is unavailable, report that limitation and rely on source, build, and database verification without claiming end-to-end UI success.

- [ ] **Step 4: Review the final diff and working tree**

Run:

```powershell
git diff --check
git status --short
git diff -- App_Data/20260710_repair_products_identity_sequence.sql Tests/AdminProductForm.Tests.ps1 admin_page/onyx_admin_products_form.aspx admin_page/onyx_admin_products_form.aspx.cs
```

Expected: no whitespace errors; only task-owned files are included in task commits; unrelated user changes remain untouched.
