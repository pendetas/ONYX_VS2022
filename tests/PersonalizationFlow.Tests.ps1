$root = Split-Path $PSScriptRoot -Parent
$schemaPath = "$root\App_Data\20260705_user_personalization_profiles.sql"
$profileModel = "$root\Models\UserPersonalizationProfile.cs"
$productModel = "$root\Models\PersonalizedProduct.cs"
$repositoryPath = "$root\DAL\PersonalizationRepository.cs"
$servicePath = "$root\Services\PersonalizationService.cs"
$project = Get-Content "$root\ONYX_DDAC.csproj" -Raw
$repositoryText = if (Test-Path $repositoryPath) { Get-Content $repositoryPath -Raw } else { '' }
$serviceText = if (Test-Path $servicePath) { Get-Content $servicePath -Raw } else { '' }

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

    'Repository exposes profile completion check' =
        $repositoryText -match 'class PersonalizationRepository' -and
        $repositoryText -match 'bool\s+HasCompletedProfile\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'UserPersonalizationProfile\s+GetProfile\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'void\s+SaveProfile\s*\(\s*UserPersonalizationProfile\s+profile\s*\)'

    'Repository reads wishlist and purchased category signals' =
        $repositoryText -match 'IList<string>\s+GetWishlistCategories\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'IList<string>\s+GetPurchasedCategories\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'wishlist' -and
        $repositoryText -match 'order_items'

    'Service exposes deterministic recommendation scoring' =
        $serviceText -match 'class PersonalizationService' -and
        $serviceText -match 'bool\s+UserRequiresPersonalization\s*\(\s*User\s+user\s*\)' -and
        $serviceText -match 'IList<PersonalizedProduct>\s+GetRecommendedProducts\s*\(\s*long\s+userId,\s*int\s+count\s*\)' -and
        $serviceText -match 'RankProductsForProfile' -and
        $serviceText -match 'CalculateScore'

    'Service uses stable ranking tie-breakers' =
        $serviceText -match 'ThenBy\s*\(\s*item\s*=>\s*item\.Product\.Price\s*\)' -and
        $serviceText -match 'ThenBy\s*\(\s*item\s*=>\s*item\.Product\.Name\s*\)' -and
        $serviceText -match 'ThenBy\s*\(\s*item\s*=>\s*item\.Product\.Id\s*\)'

    'Service explains non-category recommendation signals' =
        $serviceText -match 'BuildReason' -and
        $serviceText -match 'Supports your' -and
        $serviceText -match 'Fits the budget range' -and
        $serviceText -match 'wishlist' -and
        $serviceText -match 'setup'

    'Service normalizes list values case-insensitively' =
        $serviceText -match 'Distinct\s*\(\s*StringComparer\.OrdinalIgnoreCase\s*\)'

    'Project includes personalization repository and service' =
        $project -match 'DAL\\PersonalizationRepository.cs' -and
        $project -match 'Services\\PersonalizationService.cs'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing personalization schema/model requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Personalization schema/model source contract passes.'
