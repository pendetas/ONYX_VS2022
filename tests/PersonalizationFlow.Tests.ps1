$root = Split-Path $PSScriptRoot -Parent
$schemaPath = "$root\App_Data\20260705_user_personalization_profiles.sql"
$schemaText = if (Test-Path $schemaPath) { Get-Content $schemaPath -Raw } else { '' }
$catalogSearchSchemaPath = "$root\App_Data\20260706_catalog_search_events.sql"
$profileModel = "$root\Models\UserPersonalizationProfile.cs"
$profileModelText = if (Test-Path $profileModel) { Get-Content $profileModel -Raw } else { '' }
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
$homeMarkup = Get-Content "$root\customer_page\onyx_home.aspx" -Raw
$homeCode = Get-Content "$root\customer_page\onyx_home.aspx.cs" -Raw
$catalogMarkup = Get-Content "$root\customer_page\onyx_catalog.aspx" -Raw
$catalogCode = Get-Content "$root\customer_page\onyx_catalog.aspx.cs" -Raw
$productServiceText = Get-Content "$root\Services\ProductService.cs" -Raw
$catalogQueryText = Get-Content "$root\Models\CatalogQuery.cs" -Raw

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

    'Personalization schema stores expanded questionnaire answers' =
        $schemaText -match 'comfort_preferences' -and
        $schemaText -match 'performance_preferences' -and
        $schemaText -match 'setup_constraints'

    'User personalization profile model exists' =
        (Test-Path $profileModel) -and
        ((Get-Content $profileModel -Raw) -match 'class UserPersonalizationProfile') -and
        ((Get-Content $profileModel -Raw) -match 'IList<string> PreferredCategories') -and
        ((Get-Content $profileModel -Raw) -match 'IList<string> Priorities')

    'User personalization profile model stores expanded answer lists' =
        $profileModelText -match 'IList<string>\s+ComfortPreferences' -and
        $profileModelText -match 'IList<string>\s+PerformancePreferences' -and
        $profileModelText -match 'IList<string>\s+SetupConstraints'

    'Personalized product model exists' =
        (Test-Path $productModel) -and
        ((Get-Content $productModel -Raw) -match 'class PersonalizedProduct') -and
        ((Get-Content $productModel -Raw) -match 'Product Product') -and
        ((Get-Content $productModel -Raw) -match 'int Score') -and
        ((Get-Content $productModel -Raw) -match 'string Reason')

    'Project includes personalization model and schema files' =
        $project -match 'App_Data\\20260705_user_personalization_profiles.sql' -and
        $project -match 'App_Data\\20260706_catalog_search_events.sql' -and
        $project -match 'Models\\UserPersonalizationProfile.cs' -and
        $project -match 'Models\\PersonalizedProduct.cs'

    'Catalog search events schema records searchable behavior signals' =
        (Test-Path $catalogSearchSchemaPath) -and
        ((Get-Content $catalogSearchSchemaPath -Raw) -match 'CREATE TABLE IF NOT EXISTS catalog_search_events') -and
        ((Get-Content $catalogSearchSchemaPath -Raw) -match 'user_id') -and
        ((Get-Content $catalogSearchSchemaPath -Raw) -match 'search_term') -and
        ((Get-Content $catalogSearchSchemaPath -Raw) -match 'inferred_category') -and
        ((Get-Content $catalogSearchSchemaPath -Raw) -match 'searched_at')

    'Repository exposes profile completion check' =
        $repositoryText -match 'class PersonalizationRepository' -and
        $repositoryText -match 'bool\s+HasCompletedProfile\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'UserPersonalizationProfile\s+GetProfile\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'void\s+SaveProfile\s*\(\s*UserPersonalizationProfile\s+profile\s*\)'

    'Repository self-heals personalization schema before profile reads and saves' =
        $repositoryText -match 'EnsureProfileSchema' -and
        $repositoryText -match 'CREATE TABLE IF NOT EXISTS user_personalization_profiles' -and
        $repositoryText -match 'ADD COLUMN IF NOT EXISTS comfort_preferences' -and
        $repositoryText -match 'ADD COLUMN IF NOT EXISTS performance_preferences' -and
        $repositoryText -match 'ADD COLUMN IF NOT EXISTS setup_constraints' -and
        $repositoryText -match 'profileSchemaEnsured'

    'Repository reads wishlist and purchased category signals' =
        $repositoryText -match 'IList<string>\s+GetWishlistCategories\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'IList<string>\s+GetPurchasedCategories\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'wishlist' -and
        $repositoryText -match 'order_items'

    'Repository records and reads catalog search category signals' =
        $repositoryText -match 'void\s+RecordCatalogSearch\s*\(\s*long\s+userId\s*,\s*string\s+searchTerm\s*\)' -and
        $repositoryText -match 'IList<string>\s+GetSearchedCategories\s*\(\s*long\s+userId\s*\)' -and
        $repositoryText -match 'catalog_search_events' -and
        $repositoryText -match 'InferSearchCategory'

    'Repository treats catalog search writes as best-effort telemetry' =
        $repositoryText -match 'Catalog search personalization event skipped' -and
        $repositoryText -match 'Catalog search personalization event failed' -and
        $repositoryText -match 'catch\s*\(\s*Exception\s+exception\s*\)' -and
        $repositoryText -match 'TraceWarning'

    'Repository treats missing optional signal tables as empty signals' =
        $repositoryText -match 'PostgresException' -and
        $repositoryText -match 'PostgresErrorCodes\.UndefinedTable' -and
        $repositoryText -match 'Optional personalization signal lookup skipped' -and
        $repositoryText -match 'return values;'

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

    'Service scores gaming style recommendation signals' =
        $serviceText -match 'MatchedGamingStyles' -and
        $serviceText -match 'GamingStyleMatches' -and
        $serviceText -match 'suits your' -and
        $serviceText -match 'player\?' -and
        $serviceText -match 'PickReason'

    'Service scores dynamic behavior signals from orders and searches' =
        $serviceText -match 'GetSearchedCategories' -and
        $serviceText -match 'SearchedCategoryMatches' -and
        $serviceText -match 'PurchasedCategoryMatches' -and
        $serviceText -match 'MatchedSearchedCategories' -and
        $serviceText -match 'MatchedPurchasedCategories' -and
        $serviceText -match 'Math\.Min\s*\(\s*signals\.MatchedPurchasedCategories\.Count,\s*5\s*\)\s*\*\s*18' -and
        $serviceText -match 'Math\.Min\s*\(\s*signals\.MatchedSearchedCategories\.Count,\s*5\s*\)\s*\*\s*12'

    'Recommendation ranking supports expanded answer scoring and price intent' =
        $serviceText -match 'MatchedComfortPreferences' -and
        $serviceText -match 'MatchedPerformancePreferences' -and
        $serviceText -match 'MatchedSetupConstraints' -and
        $serviceText -match 'BudgetRange' -and
        $serviceText -match 'Premium Build' -and
        $serviceText -match 'Entry' -and
        $serviceText -match 'GetPriceIntent' -and
        $serviceText -match 'ThenByPriceIntent' -and
        $serviceText -match 'GetBudgetDistance' -and
        $serviceText -match 'ThenBy\s*\(\s*item\s*=>\s*item\.Product\.Price\s*\)' -and
        $serviceText -match 'ThenByDescending\s*\(\s*item\s*=>\s*item\.Product\.Price\s*\)'

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

    'Personalization page uses one-question stepper onboarding' =
        $pageText -match 'onyx-personalization-progress' -and
        $pageText -match 'onyx-personalization-step' -and
        $pageText -match 'data-step-index="0"' -and
        $pageText -match 'data-step-index="1"[\s\S]*?hidden' -and
        $pageText -match 'data-step-count="8"' -and
        $pageText -match 'STEP 1 OF 8' -and
        $pageText -match 'onyxPersonalizationNext' -and
        $pageText -match 'onyxPersonalizationBack' -and
        $pageText -match 'onyx-personalization\.css\?v='

    'Personalization page expands to eight saved steps' =
        $pageText -match 'data-step-count="8"' -and
        $pageText -match 'STEP 1 OF 8' -and
        $pageText -match 'comfort_preferences' -and
        $pageText -match 'performance_preferences' -and
        $pageText -match 'setup_constraints' -and
        $pageText -match 'What matters most for your comfort\?' -and
        $pageText -match 'What performance feature do you care about the most\?' -and
        $pageText -match 'What setup constraint should ONYX respect\?'

    'Personalization page opens with split-text intro animation' =
        $pageText -match 'Welcome to ONYX\.' -and
        $pageText -match 'Let us customize your preferences\.' -and
        $pageText -match 'onyx-personalization-intro-title"\s+data-split-text' -and
        $pageText -notmatch 'onyx-personalization-intro-subtitle"\s+data-split-text' -and
        $pageText -match 'splitText\s*\(' -and
        $pageText -match 'subtitle\.classList\.add\(\s*''is-visible''\s*\)' -and
        $cssText -match 'onyx-split-char-in' -and
        $cssText -match '\.onyx-personalization-intro-subtitle\.is-visible'

    'Personalization action buttons stay white in all states' =
        $pageText -match 'onyx-personalization\.css\?v=20260707-stepper-css-1' -and
        $pageText -match '\.onyx-personalization-page \.onyx-personalization-back,[\s\S]*?background:\s*#f8f8f8\s*!important' -and
        $pageText -match '\.onyx-personalization-page \.onyx-personalization-next,[\s\S]*?background:\s*#f8f8f8\s*!important' -and
        $pageText -match '\.onyx-personalization-page input\.onyx-personalization-submit,[\s\S]*?background:\s*#f8f8f8\s*!important'

    'Personalization page exposes the approved onboarding choices' =
        $pageText -match 'data-target="gaming_style"\s+data-value="FPS"\s+data-multi="true"' -and
        $pageText -match 'data-target="gaming_style"\s+data-value="MOBA"\s+data-multi="true"' -and
        $pageText -match 'data-target="gaming_style"\s+data-value="RPG"\s+data-multi="true"' -and
        $pageText -match 'data-target="gaming_style"\s+data-value="Racing"\s+data-multi="true"' -and
        $pageText -match 'data-target="gaming_style"\s+data-value="Casual"\s+data-multi="true"' -and
        $pageText -match 'data-target="gaming_style"\s+data-value="Creator"\s+data-multi="true"' -and
        $pageText -match 'data-target="priorities"\s+data-multi="true"\s+data-value="Speed"' -and
        $pageText -match 'data-target="priorities"\s+data-multi="true"\s+data-value="Comfort"' -and
        $pageText -match 'data-target="priorities"\s+data-multi="true"\s+data-value="Wireless"' -and
        $pageText -match 'data-target="priorities"\s+data-multi="true"\s+data-value="Budget"' -and
        $pageText -match 'data-target="priorities"\s+data-multi="true"\s+data-value="RGB"' -and
        $pageText -match 'data-target="priorities"\s+data-multi="true"\s+data-value="Premium Build"'

    'Personalization code requires login and saves profile' =
        $codeText -match 'AuthHelper.RequireLogin' -and
        $codeText -match 'PersonalizationService' -and
        $codeText -match 'SaveProfile' -and
        $codeText -match 'onyx_home.aspx'

    'Personalization save maps expanded questionnaire answers' =
        $codeText -match 'GamingStyleField\.Value' -and
        $codeText -match 'PreferredCategoriesField\.Value' -and
        $codeText -match 'PrioritiesField\.Value' -and
        $codeText -match 'BudgetRangeField\.Value' -and
        $codeText -match 'SetupGoalField\.Value' -and
        $codeText -match 'ComfortPreferencesField\.Value' -and
        $codeText -match 'PerformancePreferencesField\.Value' -and
        $codeText -match 'SetupConstraintsField\.Value' -and
        $codeText -match 'GamingStyle\s*=\s*GamingStyleField\.Value' -and
        $codeText -match 'PreferredCategories\s*=\s*SplitValues' -and
        $codeText -match 'Priorities\s*=\s*SplitValues' -and
        $codeText -match 'BudgetRange\s*=\s*BudgetRangeField\.Value' -and
        $codeText -match 'SetupGoal\s*=\s*SetupGoalField\.Value' -and
        $codeText -match 'ComfortPreferences\s*=\s*SplitValues' -and
        $codeText -match 'PerformancePreferences\s*=\s*SplitValues' -and
        $codeText -match 'SetupConstraints\s*=\s*SplitValues'

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
        $cssText -notmatch '#0b1220|#0f172a|#172554|#1d4ed8|#2563eb|#0284c7|#f0d6d6|\bnavy\b|\bblue\b|\bcyan\b|\bpink\b|\bred\b'

    'Project includes personalization page files' =
        $project -match 'customer_page\\onyx_personalization.aspx' -and
        $project -match 'customer_page\\onyx_personalization.aspx.cs' -and
        $project -match 'customer_page\\onyx_personalization.aspx.designer.cs' -and
        $project -match 'Content\\onyx-personalization.css'

    'Home page binds personalized recommendation strip' =
        $homeMarkup -match 'PersonalizedProductsRepeater' -and
        $homeMarkup -match 'For your setup' -and
        $homeMarkup -match 'PersonalizedSetupHeadline' -and
        $homeMarkup -match 'PersonalizedSetupSubheadline' -and
        $homeCode -match 'Recommended products' -and
        $homeCode -notmatch 'Based on your preferences' -and
        $homeCode -match 'GetRecommendedProducts' -and
        $homeCode -match 'GetProfile' -and
        $homeCode -match 'PersonalizedProductsPanel' -and
        $homeCode -match 'catch\s*\(\s*Exception' -and
        $homeCode -match 'PersonalizedProductsPanel\.Visible\s*=\s*false;'

    'Catalog exposes recommended sort' =
        $catalogMarkup -match 'value="recommended"' -and
        $catalogCode -match 'recommended' -and
        $catalogQueryText -match 'long\?\s+UserId'

    'Catalog defaults signed-in Shop All to personalized recommended sort' =
        $catalogCode -match 'ResolveCatalogSort' -and
        $catalogCode -match 'Request\.QueryString\["sort"\]' -and
        $catalogCode -match 'TryGetCurrentUserId' -and
        $catalogCode -match 'return\s+"recommended";'

    'Catalog explicit sort query overrides personalized recommended default' =
        $catalogCode -match 'ResolveCatalogSort' -and
        $catalogCode -match 'string\s+explicitSort\s*=\s*Request\.QueryString\["sort"\];' -and
        $catalogCode -match 'if\s*\(\s*!string\.IsNullOrWhiteSpace\(explicitSort\)\s*\)\s*\{\s*return\s+NormalizeSort\(explicitSort\);\s*\}' -and
        $catalogCode -match 'if\s*\(\s*TryGetCurrentUserId\(out\s*_\)\s*\)\s*\{\s*return\s+"recommended";\s*\}'

    'Catalog recognizes supported explicit sort options' =
        $catalogCode -match 'case\s+"name":' -and
        $catalogCode -match 'case\s+"price-asc":' -and
        $catalogCode -match 'case\s+"price-desc":' -and
        $catalogCode -match 'case\s+"recommended":'

    'Catalog records logged-in non-empty searches for personalization' =
        $catalogCode -match 'RecordCatalogSearch' -and
        $catalogCode -match '!string\.IsNullOrWhiteSpace\(SearchTerm\)' -and
        $catalogCode -match 'recommendationUserId\.HasValue' -and
        $catalogCode -match 'GetCatalogProducts[\s\S]*RecordCatalogSearch'

    'Search personalization records immediate dynamic signals' =
        $repositoryText -match 'InferSearchCategories' -and
        $repositoryText -match 'mic' -and
        $repositoryText -match 'mousepad' -and
        $catalogCode -match 'StoreRecentSearchSignal' -and
        $catalogCode -match 'GetRecentSearchSignals' -and
        $catalogCode -match 'CurrentSearchSignals' -and
        $catalogCode -match 'UrlEncode' -and
        $catalogCode -match 'UrlDecode' -and
        $productServiceText -match 'normalizedQuery\.CurrentSearchSignals'

    'Product service handles recommended sort through personalization' =
        $productServiceText -match 'recommended' -and
        $productServiceText -match 'PersonalizationService' -and
        $productServiceText -match 'filteredCandidates' -and
        $productServiceText -match 'catch\s*\(\s*Exception' -and
        $productServiceText -match 'Trace\.TraceWarning' -and
        $productServiceText -match 'GetRepositoryCatalogProducts'

    'Recommended catalog search preserves normal searchable fields' =
        $productServiceText -match 'product\.Name' -and
        $productServiceText -match 'product\.Brand' -and
        $productServiceText -match 'product\.Category' -and
        $productServiceText -match 'product\.Description'

    'Recommended catalog path clamps page to the last valid result page' =
        $productServiceText -match 'totalPages' -and
        $productServiceText -match 'Math\.Min\s*\(\s*normalizedQuery\.Page\s*,\s*totalPages\s*\)'

    'Recommended catalog path falls back to repository results when personalization is unavailable' =
        $productServiceText -match 'HasCompletedProfile' -and
        $productServiceText -match 'GetRepositoryCatalogProducts' -and
        $productServiceText -match 'GetRecommendedProducts' -and
        $productServiceText -match 'catch\s*\(\s*Exception' -and
        $productServiceText -match 'Trace\.TraceWarning'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing personalization schema/model requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Personalization schema/model source contract passes.'
