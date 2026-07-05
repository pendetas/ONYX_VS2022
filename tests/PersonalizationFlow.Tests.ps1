$root = Split-Path $PSScriptRoot -Parent
$schemaPath = "$root\App_Data\20260705_user_personalization_profiles.sql"
$profileModel = "$root\Models\UserPersonalizationProfile.cs"
$productModel = "$root\Models\PersonalizedProduct.cs"
$repositoryPath = "$root\DAL\PersonalizationRepository.cs"
$servicePath = "$root\Services\PersonalizationService.cs"
$project = Get-Content "$root\ONYX_DDAC.csproj" -Raw
$repositoryText = if (Test-Path $repositoryPath) { Get-Content $repositoryPath -Raw } else { '' }
$userRepositoryText = Get-Content "$root\DAL\UserRepository.cs" -Raw
$serviceText = if (Test-Path $servicePath) { Get-Content $servicePath -Raw } else { '' }
$redirectHelperPath = "$root\Helpers\PostAuthRedirectHelper.cs"
$redirectHelperText = if (Test-Path $redirectHelperPath) { Get-Content $redirectHelperPath -Raw } else { '' }
$authServiceText = Get-Content "$root\Services\AuthService.cs" -Raw
$loginText = Get-Content "$root\auth_page\onyx_login.aspx.cs" -Raw
$registerText = Get-Content "$root\auth_page\onyx_register.aspx.cs" -Raw
$googleCallbackText = Get-Content "$root\auth_page\google_callback.aspx.cs" -Raw
$oauthCallbackText = Get-Content "$root\auth_page\oauth_callback.aspx.cs" -Raw
$masterCodeText = Get-Content "$root\customer_page\onyx_user.Master.cs" -Raw
$masterMarkupText = Get-Content "$root\customer_page\onyx_user.Master" -Raw
$personalizationPage = "$root\customer_page\onyx_personalization.aspx"
$personalizationCode = "$root\customer_page\onyx_personalization.aspx.cs"
$personalizationCss = "$root\Content\onyx-personalization.css"
$pageText = if (Test-Path $personalizationPage) { Get-Content $personalizationPage -Raw } else { '' }
$codeText = if (Test-Path $personalizationCode) { Get-Content $personalizationCode -Raw } else { '' }
$cssText = if (Test-Path $personalizationCss) { Get-Content $personalizationCss -Raw } else { '' }

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
        $serviceText -match 'ThenBy\s*\(\s*item\s*=>\s*item\.Product\.Name\s*,\s*StringComparer\.Ordinal\s*\)' -and
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

    'Post-auth redirect helper routes incomplete customers to personalization' =
        $redirectHelperText -match 'class PostAuthRedirectHelper' -and
        $redirectHelperText -match 'onyx_personalization.aspx' -and
        $redirectHelperText -match 'UserRequiresPersonalization' -and
        $redirectHelperText -match 'CompleteRequest'

    'Manual registration returns created user for auto-login' =
        $authServiceText -match 'User\s+RegisterCustomer\s*\(' -and
        $authServiceText -match 'GetUserByEmailForWrite\s*\(' -and
        $userRepositoryText -match 'User\s+GetUserByEmailForWrite\s*\('

    'Privileged roles bypass customer personalization routing' =
        $redirectHelperText -match 'user\.Role' -and
        $redirectHelperText -match '"admin"' -and
        $redirectHelperText -match '"owner"' -and
        $redirectHelperText -match '"staff"' -and
        $redirectHelperText -match 'onyx_admin_dashboard\.aspx'

    'Auth pages use shared post-auth redirect' =
        $loginText -match 'PostAuthRedirectHelper.Redirect' -and
        $registerText -match 'PostAuthRedirectHelper.Redirect' -and
        $googleCallbackText -match 'PostAuthRedirectHelper.Redirect' -and
        $oauthCallbackText -match 'PostAuthRedirectHelper.Redirect'

    'Authenticated login page no longer bypasses incomplete customers to home' =
        $loginText -match 'PostAuthRedirectHelper.GetTarget' -and
        $loginText -notmatch 'Session\["UserId"\]\s*!=\s*null[\s\S]*?onyx_home\.aspx'

    'Customer master guard routes incomplete customer sessions to personalization without loops' =
        $masterCodeText -match 'PersonalizationService' -and
        $masterCodeText -match 'HasCompletedProfile' -and
        $masterCodeText -match 'IsPersonalizationPage' -and
        $masterCodeText -match 'EnsureCustomerPersonalizationCompleted' -and
        $masterCodeText -match 'IsPersonalizationPage\s*\|\|\s*!IsCustomerPage\(\)' -and
        $masterCodeText -match 'onyx_personalization\.aspx' -and
        $masterCodeText -match '"customer"'

    'Personalization page defines required questions and submit action' =
        $pageText -match 'Build Your ONYX Setup' -and
        $pageText -match 'gaming_style' -and
        $pageText -match 'preferred_categories' -and
        $pageText -match 'priorities' -and
        $pageText -match 'budget_range' -and
        $pageText -match 'setup_goal' -and
        $pageText -match 'Build My Setup'

    'Personalization code requires login and saves profile' =
        $codeText -match 'AuthHelper.RequireLogin' -and
        $codeText -match 'PersonalizationService' -and
        $codeText -match 'SaveProfile' -and
        $codeText -match 'onyx_home.aspx'

    'Personalization code keeps validation messages but hides unexpected failures' =
        $codeText -match 'catch\s*\(\s*ArgumentException' -and
        $codeText -match 'Personalization is temporarily unavailable\. Please try again\.' -and
        $codeText -notmatch 'exception\.Message'

    'Personalization page is customer-scoped and routes privileged roles away' =
        $codeText -match 'Session\["Role"\]' -and
        $codeText -match '"customer"' -and
        $codeText -match '"admin"' -and
        $codeText -match '"owner"' -and
        $codeText -match '"staff"' -and
        $codeText -match 'onyx_admin_dashboard\.aspx'

    'Personalization page marks the master shell for page-scoped monochrome overrides' =
        $masterMarkupText -match 'BodyCssClass' -and
        $masterMarkupText -match 'HtmlCssClass' -and
        $masterMarkupText -match 'ShellCssClass'

    'Personalization CSS is monochrome ONYX theme' =
        $cssText -match '#000' -and
        $cssText -match '#0b0b0c' -and
        $cssText -match '#d8dde3' -and
        $cssText -match 'html\.onyx-personalization-shell-page' -and
        $cssText -match 'body\.onyx-personalization-shell-page' -and
        $cssText -match '\.onyx-personalization-shell-page\s+\.onyx-ddac-nav' -and
        $cssText -match '\.onyx-personalization-shell-page\s+\.onyx-master-footer' -and
        $cssText -notmatch '#0b1220|#0f172a|#f0d6d6|navy|blue|pink|red'

    'Project includes personalization page files' =
        $project -match 'customer_page\\onyx_personalization.aspx' -and
        $project -match 'customer_page\\onyx_personalization.aspx.cs' -and
        $project -match 'customer_page\\onyx_personalization.aspx.designer.cs' -and
        $project -match 'Content\\onyx-personalization.css'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing personalization schema/model requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Personalization schema/model source contract passes.'
