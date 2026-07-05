$root = Split-Path $PSScriptRoot -Parent
$schemaPath = "$root\App_Data\20260705_user_personalization_profiles.sql"
$profileModel = "$root\Models\UserPersonalizationProfile.cs"
$productModel = "$root\Models\PersonalizedProduct.cs"
$project = Get-Content "$root\ONYX_DDAC.csproj" -Raw

$checks = [ordered]@{
    'Personalization schema creates profile table' =
        (Test-Path $schemaPath) -and
        ((Get-Content $schemaPath -Raw) -match 'CREATE TABLE IF NOT EXISTS user_personalization_profiles')

    'Personalization schema stores required answers' =
        (Test-Path $schemaPath) -and
        ((Get-Content $schemaPath -Raw) -match 'gaming_style') -and
        ((Get-Content $schemaPath -Raw) -match 'preferred_categories') -and
        ((Get-Content $schemaPath -Raw) -match 'priorities') -and
        ((Get-Content $schemaPath -Raw) -match 'budget_range') -and
        ((Get-Content $schemaPath -Raw) -match 'setup_goal') -and
        ((Get-Content $schemaPath -Raw) -match 'completed_at')

    'User personalization profile model exists' =
        (Test-Path $profileModel) -and
        ((Get-Content $profileModel -Raw) -match 'class UserPersonalizationProfile') -and
        ((Get-Content $profileModel -Raw) -match 'IList<string> PreferredCategories') -and
        ((Get-Content $profileModel -Raw) -match 'IList<string> Priorities')

    'Personalized product model exists' =
        (Test-Path $productModel) -and
        ((Get-Content $productModel -Raw) -match 'class PersonalizedProduct') -and
        ((Get-Content $productModel -Raw) -match 'Product Product') -and
        ((Get-Content $productModel -Raw) -match 'int Score') -and
        ((Get-Content $productModel -Raw) -match 'string Reason')

    'Project includes personalization model and schema files' =
        $project -match 'App_Data\\20260705_user_personalization_profiles.sql' -and
        $project -match 'Models\\UserPersonalizationProfile.cs' -and
        $project -match 'Models\\PersonalizedProduct.cs'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing personalization schema/model requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Personalization schema/model source contract passes.'
