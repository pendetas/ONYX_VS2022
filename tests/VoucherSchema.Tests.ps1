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
    'Voucher redemption foreign keys cascade on legacy user and order deletes' =
        $migration -match 'user_id BIGINT NOT NULL REFERENCES users\(id\) ON DELETE CASCADE' -and
        $migration -match 'order_id BIGINT NOT NULL REFERENCES orders\(id\) ON DELETE CASCADE' -and
        $schema -match 'user_id BIGINT NOT NULL REFERENCES users\(id\) ON DELETE CASCADE' -and
        $schema -match 'order_id BIGINT NOT NULL REFERENCES orders\(id\) ON DELETE CASCADE'
    'Migration recreates named redemption constraints idempotently without touching orders voucher FK behavior' =
        $migration -match 'fk_voucher_redemptions_user' -and
        $migration -match 'fk_voucher_redemptions_order' -and
        $migration -match 'DROP CONSTRAINT IF EXISTS fk_voucher_redemptions_user' -and
        $migration -match 'DROP CONSTRAINT IF EXISTS fk_voucher_redemptions_order' -and
        $migration -match 'fk_orders_voucher'
    'Project includes voucher migration' =
        $project -match 'App_Data\\20260717_voucher_loyalty_management\.sql'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing voucher schema requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Voucher schema source contract passes.'
