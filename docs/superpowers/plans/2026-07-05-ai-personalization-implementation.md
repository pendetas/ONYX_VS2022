# AI Personalization Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build mandatory first-time customer personalization and local product recommendation scoring without an external AI API.

**Architecture:** Add a small personalization data layer, service layer, and shared post-auth redirect helper. New users answer a required ONYX-themed setup page; home and catalog read a deterministic recommendation score based on profile answers, wishlist categories, and order history.

**Tech Stack:** ASP.NET Web Forms on .NET Framework 4.8, C# 7.3, PostgreSQL through Npgsql, PowerShell source-contract tests, existing ONYX CSS/ASPX patterns.

## Global Constraints

- No paid or external AI API calls in this version.
- Mandatory personalization for first-time customer users.
- Admin/owner/staff roles are not forced through customer personalization.
- UI must use pure black, charcoal, graphite, and soft silver only; no blue or navy field surfaces.
- Use existing ONYX auth typography direction: Inter for body and Syne for display when the page owns its font imports.
- Keep recommendation scoring deterministic and explainable.
- Database failures must not expose raw exception details to the browser.
- Preserve existing OAuth, Cloudflare Turnstile, password reset, and email behavior.

---

## File Structure

- Create `App_Data/20260705_user_personalization_profiles.sql`: PostgreSQL migration for the profile table.
- Create `Models/UserPersonalizationProfile.cs`: user answers and completion timestamp.
- Create `Models/PersonalizedProduct.cs`: product plus recommendation score and short reason.
- Create `DAL/PersonalizationRepository.cs`: read/write profile and category signals from wishlist/orders.
- Create `Services/PersonalizationService.cs`: validation, completion checks, and scoring.
- Create `Helpers/PostAuthRedirectHelper.cs`: one shared redirect path after manual login, manual registration, and OAuth callbacks.
- Create `customer_page/onyx_personalization.aspx`: mandatory onboarding UI.
- Create `customer_page/onyx_personalization.aspx.cs`: validates and saves answers.
- Create `customer_page/onyx_personalization.aspx.designer.cs`: server control declarations.
- Create `Content/onyx-personalization.css`: ONYX black/monochrome onboarding styling.
- Modify `Services/AuthService.cs`: expose registration method that returns the created customer.
- Modify `auth_page/onyx_login.aspx.cs`: use shared post-auth redirect.
- Modify `auth_page/onyx_register.aspx.cs`: auto-login newly registered customer and redirect to onboarding.
- Modify `auth_page/google_callback.aspx.cs`: use shared post-auth redirect after OAuth.
- Modify `auth_page/oauth_callback.aspx.cs`: use shared post-auth redirect after OAuth.
- Modify `customer_page/onyx_home.aspx` and `.cs`: show personalized products for completed users.
- Modify `customer_page/onyx_catalog.aspx` and `.cs`: add `Recommended` sort option.
- Modify `Models/CatalogQuery.cs`: add `long? UserId` to support signed-in recommendation sorting.
- Modify `Services/ProductService.cs`: allow `recommended` sort to call the personalization service.
- Modify `ONYX_DDAC.csproj`: include new compile/content files.
- Create `tests/PersonalizationFlow.Tests.ps1`: source-contract coverage for schema, routing, UI, and scoring.

---

### Task 1: Schema And Models

**Files:**
- Create: `App_Data/20260705_user_personalization_profiles.sql`
- Create: `Models/UserPersonalizationProfile.cs`
- Create: `Models/PersonalizedProduct.cs`
- Modify: `ONYX_DDAC.csproj`
- Test: `tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Produces: `UserPersonalizationProfile` with `UserId`, `GamingStyle`, `PreferredCategories`, `Priorities`, `BudgetRange`, `SetupGoal`, `CompletedAt`, `UpdatedAt`.
- Produces: `PersonalizedProduct` with `Product`, `Score`, `Reason`.

- [ ] **Step 1: Write the failing schema/model source-contract test**

Add this beginning to `tests/PersonalizationFlow.Tests.ps1`:

```powershell
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Expected: FAIL with missing schema/model requirements.

- [ ] **Step 3: Add migration**

Create `App_Data/20260705_user_personalization_profiles.sql`:

```sql
CREATE TABLE IF NOT EXISTS user_personalization_profiles (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    gaming_style VARCHAR(40) NOT NULL,
    preferred_categories TEXT NOT NULL,
    priorities TEXT NOT NULL,
    budget_range VARCHAR(40) NOT NULL,
    setup_goal VARCHAR(60) NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_personalization_completed
    ON user_personalization_profiles (completed_at);
```

- [ ] **Step 4: Add models**

Create `Models/UserPersonalizationProfile.cs`:

```csharp
using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Models
{
    public class UserPersonalizationProfile
    {
        public long UserId { get; set; }
        public string GamingStyle { get; set; }
        public IList<string> PreferredCategories { get; set; } = new List<string>();
        public IList<string> Priorities { get; set; } = new List<string>();
        public string BudgetRange { get; set; }
        public string SetupGoal { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
```

Create `Models/PersonalizedProduct.cs`:

```csharp
namespace ONYX_DDAC.Models
{
    public class PersonalizedProduct
    {
        public Product Product { get; set; }
        public int Score { get; set; }
        public string Reason { get; set; }
    }
}
```

- [ ] **Step 5: Include files in project**

Modify `ONYX_DDAC.csproj`:

```xml
<Content Include="App_Data\20260705_user_personalization_profiles.sql" />
<Compile Include="Models\UserPersonalizationProfile.cs" />
<Compile Include="Models\PersonalizedProduct.cs" />
```

Place the schema near other `App_Data` migrations and model compile entries near other model files.

- [ ] **Step 6: Run test and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Expected: source contract passes; build succeeds with `0 Error(s)`.

- [ ] **Step 7: Commit**

```powershell
git add App_Data/20260705_user_personalization_profiles.sql Models/UserPersonalizationProfile.cs Models/PersonalizedProduct.cs ONYX_DDAC.csproj tests/PersonalizationFlow.Tests.ps1
git commit -m "Add personalization schema models"
```

---

### Task 2: Repository And Scoring Service

**Files:**
- Create: `DAL/PersonalizationRepository.cs`
- Create: `Services/PersonalizationService.cs`
- Modify: `ONYX_DDAC.csproj`
- Modify: `tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Consumes: `UserPersonalizationProfile`, `PersonalizedProduct`, `Product`.
- Produces: `PersonalizationRepository.HasCompletedProfile(long userId) : bool`.
- Produces: `PersonalizationRepository.GetProfile(long userId) : UserPersonalizationProfile`.
- Produces: `PersonalizationRepository.SaveProfile(UserPersonalizationProfile profile) : void`.
- Produces: `PersonalizationService.UserRequiresPersonalization(User user) : bool`.
- Produces: `PersonalizationService.SaveProfile(UserPersonalizationProfile profile) : void`.
- Produces: `PersonalizationService.GetRecommendedProducts(long userId, int count) : IList<PersonalizedProduct>`.
- Produces: `PersonalizationService.RankProductsForProfile(UserPersonalizationProfile profile, IList<Product> products, IList<string> wishlistCategories, IList<string> purchasedCategories, int count) : IList<PersonalizedProduct>`.

- [ ] **Step 1: Extend test for repository and service contracts**

Append to `tests/PersonalizationFlow.Tests.ps1` before the failure check:

```powershell
$repositoryPath = "$root\DAL\PersonalizationRepository.cs"
$servicePath = "$root\Services\PersonalizationService.cs"
$repositoryText = if (Test-Path $repositoryPath) { Get-Content $repositoryPath -Raw } else { '' }
$serviceText = if (Test-Path $servicePath) { Get-Content $servicePath -Raw } else { '' }

$checks['Repository exposes profile completion check'] =
    $repositoryText -match 'class PersonalizationRepository' -and
    $repositoryText -match 'bool\s+HasCompletedProfile\s*\(\s*long\s+userId\s*\)' -and
    $repositoryText -match 'UserPersonalizationProfile\s+GetProfile\s*\(\s*long\s+userId\s*\)' -and
    $repositoryText -match 'void\s+SaveProfile\s*\(\s*UserPersonalizationProfile\s+profile\s*\)'

$checks['Repository reads wishlist and purchased category signals'] =
    $repositoryText -match 'IList<string>\s+GetWishlistCategories\s*\(\s*long\s+userId\s*\)' -and
    $repositoryText -match 'IList<string>\s+GetPurchasedCategories\s*\(\s*long\s+userId\s*\)' -and
    $repositoryText -match 'wishlist' -and
    $repositoryText -match 'order_items'

$checks['Service exposes deterministic recommendation scoring'] =
    $serviceText -match 'class PersonalizationService' -and
    $serviceText -match 'bool\s+UserRequiresPersonalization\s*\(\s*User\s+user\s*\)' -and
    $serviceText -match 'IList<PersonalizedProduct>\s+GetRecommendedProducts\s*\(\s*long\s+userId,\s*int\s+count\s*\)' -and
    $serviceText -match 'RankProductsForProfile' -and
    $serviceText -match 'CalculateScore'

$checks['Project includes personalization repository and service'] =
    $project -match 'DAL\\PersonalizationRepository.cs' -and
    $project -match 'Services\\PersonalizationService.cs'
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Expected: FAIL with repository/service requirements.

- [ ] **Step 3: Implement repository**

Create `DAL/PersonalizationRepository.cs` with this structure:

```csharp
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class PersonalizationRepository
    {
        public bool HasCompletedProfile(long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT COUNT(*)
                        FROM user_personalization_profiles
                        WHERE user_id = @UserId
                          AND completed_at IS NOT NULL";
                    AddParameter(cmd, "@UserId", userId);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        public UserPersonalizationProfile GetProfile(long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT user_id, gaming_style, preferred_categories, priorities,
                               budget_range, setup_goal, completed_at, updated_at
                        FROM user_personalization_profiles
                        WHERE user_id = @UserId";
                    AddParameter(cmd, "@UserId", userId);

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        return reader.Read() ? MapProfile(reader) : null;
                    }
                }
            }
        }

        public void SaveProfile(UserPersonalizationProfile profile)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO user_personalization_profiles
                            (user_id, gaming_style, preferred_categories, priorities,
                             budget_range, setup_goal, completed_at, updated_at)
                        VALUES
                            (@UserId, @GamingStyle, @PreferredCategories, @Priorities,
                             @BudgetRange, @SetupGoal, NOW(), NOW())
                        ON CONFLICT (user_id) DO UPDATE SET
                            gaming_style = EXCLUDED.gaming_style,
                            preferred_categories = EXCLUDED.preferred_categories,
                            priorities = EXCLUDED.priorities,
                            budget_range = EXCLUDED.budget_range,
                            setup_goal = EXCLUDED.setup_goal,
                            completed_at = COALESCE(user_personalization_profiles.completed_at, NOW()),
                            updated_at = NOW()";
                    AddParameter(cmd, "@UserId", profile.UserId);
                    AddParameter(cmd, "@GamingStyle", profile.GamingStyle);
                    AddParameter(cmd, "@PreferredCategories", JoinValues(profile.PreferredCategories));
                    AddParameter(cmd, "@Priorities", JoinValues(profile.Priorities));
                    AddParameter(cmd, "@BudgetRange", profile.BudgetRange);
                    AddParameter(cmd, "@SetupGoal", profile.SetupGoal);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public IList<string> GetWishlistCategories(long userId)
        {
            return GetCategorySignals(@"
                SELECT DISTINCT p.category
                FROM wishlist w
                INNER JOIN products p ON p.id = w.product_id
                WHERE w.user_id = @UserId", userId);
        }

        public IList<string> GetPurchasedCategories(long userId)
        {
            return GetCategorySignals(@"
                SELECT DISTINCT p.category
                FROM orders o
                INNER JOIN order_items oi ON oi.order_id = o.id
                INNER JOIN products p ON p.id = oi.product_id
                WHERE o.user_id = @UserId
                  AND COALESCE(o.status, '') <> 'cancelled'", userId);
        }

        private IList<string> GetCategorySignals(string sql, long userId)
        {
            var values = new List<string>();
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = sql;
                    AddParameter(cmd, "@UserId", userId);
                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (!reader.IsDBNull(0))
                                values.Add(reader.GetString(0));
                        }
                    }
                }
            }
            return values;
        }

        private static UserPersonalizationProfile MapProfile(DbDataReader reader)
        {
            return new UserPersonalizationProfile
            {
                UserId = reader.GetInt64(0),
                GamingStyle = reader.GetString(1),
                PreferredCategories = SplitValues(reader.GetString(2)),
                Priorities = SplitValues(reader.GetString(3)),
                BudgetRange = reader.GetString(4),
                SetupGoal = reader.GetString(5),
                CompletedAt = reader.IsDBNull(6) ? (DateTime?)null : reader.GetDateTime(6),
                UpdatedAt = reader.IsDBNull(7) ? (DateTime?)null : reader.GetDateTime(7)
            };
        }

        private static void AddParameter(DbCommand cmd, string name, object value)
        {
            DbParameter parameter = cmd.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value ?? DBNull.Value;
            cmd.Parameters.Add(parameter);
        }

        private static string JoinValues(IList<string> values)
        {
            return string.Join(",", (values ?? new List<string>())
                .Where(v => !string.IsNullOrWhiteSpace(v))
                .Select(v => v.Trim().ToLowerInvariant())
                .Distinct());
        }

        private static IList<string> SplitValues(string value)
        {
            return (value ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(v => v.Trim())
                .Where(v => v.Length > 0)
                .ToList();
        }
    }
}
```

- [ ] **Step 4: Implement service**

Create `Services/PersonalizationService.cs`:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class PersonalizationService
    {
        private readonly PersonalizationRepository _personalizationRepository;
        private readonly ProductRepository _productRepository;

        public PersonalizationService()
            : this(new PersonalizationRepository(), new ProductRepository())
        {
        }

        public PersonalizationService(
            PersonalizationRepository personalizationRepository,
            ProductRepository productRepository)
        {
            _personalizationRepository = personalizationRepository;
            _productRepository = productRepository;
        }

        public bool UserRequiresPersonalization(User user)
        {
            if (user == null)
                return false;

            if (!string.Equals(user.Role, "customer", StringComparison.OrdinalIgnoreCase))
                return false;

            return !_personalizationRepository.HasCompletedProfile(user.Id);
        }

        public bool HasCompletedProfile(long userId)
        {
            return _personalizationRepository.HasCompletedProfile(userId);
        }

        public UserPersonalizationProfile GetProfile(long userId)
        {
            return _personalizationRepository.GetProfile(userId);
        }

        public void SaveProfile(UserPersonalizationProfile profile)
        {
            ValidateProfile(profile);
            _personalizationRepository.SaveProfile(NormalizeProfile(profile));
        }

        public IList<PersonalizedProduct> GetRecommendedProducts(long userId, int count)
        {
            UserPersonalizationProfile profile = _personalizationRepository.GetProfile(userId);
            if (profile == null || !profile.CompletedAt.HasValue)
                return new List<PersonalizedProduct>();

            IList<Product> products = _productRepository.GetAllProducts();
            IList<string> wishlistCategories = _personalizationRepository.GetWishlistCategories(userId);
            IList<string> purchasedCategories = _personalizationRepository.GetPurchasedCategories(userId);

            return RankProductsForProfile(
                profile,
                products,
                wishlistCategories,
                purchasedCategories,
                count);
        }

        public IList<PersonalizedProduct> RankProductsForProfile(
            UserPersonalizationProfile profile,
            IList<Product> products,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories,
            int count)
        {
            if (profile == null || products == null)
                return new List<PersonalizedProduct>();

            return products
                .Select(product => new PersonalizedProduct
                {
                    Product = product,
                    Score = CalculateScore(profile, product, wishlistCategories, purchasedCategories),
                    Reason = BuildReason(profile, product)
                })
                .OrderByDescending(item => item.Score)
                .ThenBy(item => item.Product.Price)
                .Take(count < 1 ? 4 : count)
                .ToList();
        }

        private static int CalculateScore(
            UserPersonalizationProfile profile,
            Product product,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories)
        {
            int score = 0;
            string category = Normalize(product.Category);
            string searchable = Normalize(product.Name + " " + product.Description + " " + product.Brand);

            if (profile.PreferredCategories.Select(Normalize).Contains(category))
                score += 50;

            foreach (string priority in profile.Priorities.Select(Normalize))
            {
                if (MatchesPriority(priority, searchable))
                    score += 25;
            }

            if (PriceFitsBudget(product.Price, profile.BudgetRange))
                score += 20;

            if ((wishlistCategories ?? new List<string>()).Select(Normalize).Contains(category))
                score += 15;

            if ((purchasedCategories ?? new List<string>()).Select(Normalize).Contains(category))
                score += 20;

            if (SetupGoalMatches(profile.SetupGoal, category, searchable))
                score += 10;

            return score;
        }

        private static string BuildReason(UserPersonalizationProfile profile, Product product)
        {
            if (profile.PreferredCategories.Select(Normalize).Contains(Normalize(product.Category)))
                return "Matched to your selected gear focus";

            if (SetupGoalMatches(profile.SetupGoal, Normalize(product.Category), Normalize(product.Name + " " + product.Description)))
                return "Aligned with your setup goal";

            return "Recommended from your ONYX setup profile";
        }

        private static bool MatchesPriority(string priority, string searchable)
        {
            switch (priority)
            {
                case "speed":
                    return ContainsAny(searchable, "speed", "fast", "latency", "response", "optical");
                case "comfort":
                    return ContainsAny(searchable, "comfort", "ergonomic", "lightweight", "soft", "long session");
                case "wireless":
                    return ContainsAny(searchable, "wireless", "bluetooth", "low-latency");
                case "budget":
                    return true;
                case "rgb":
                    return ContainsAny(searchable, "rgb", "lighting", "chroma");
                case "premium build":
                case "premium-build":
                    return ContainsAny(searchable, "premium", "aluminum", "durable", "reinforced", "flagship");
                default:
                    return false;
            }
        }

        private static bool PriceFitsBudget(decimal price, string budgetRange)
        {
            switch (Normalize(budgetRange))
            {
                case "entry":
                    return price <= 150m;
                case "mid-range":
                    return price > 150m && price <= 400m;
                case "premium":
                    return price > 400m;
                default:
                    return true;
            }
        }

        private static bool SetupGoalMatches(string setupGoal, string category, string searchable)
        {
            switch (Normalize(setupGoal))
            {
                case "competitive":
                    return ContainsAny(searchable, "speed", "latency", "precision", "optical") || category == "mouse" || category == "keyboard";
                case "streaming":
                    return category == "headset" || ContainsAny(searchable, "audio", "mic", "voice", "lighting");
                case "work and gaming":
                    return category == "keyboard" || ContainsAny(searchable, "comfort", "wireless", "quiet");
                case "everyday gaming":
                    return true;
                default:
                    return false;
            }
        }

        private static bool ContainsAny(string text, params string[] values)
        {
            return values.Any(value => text.IndexOf(value, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        private static UserPersonalizationProfile NormalizeProfile(UserPersonalizationProfile profile)
        {
            profile.GamingStyle = NormalizeChoice(profile.GamingStyle);
            profile.PreferredCategories = NormalizeList(profile.PreferredCategories);
            profile.Priorities = NormalizeList(profile.Priorities);
            profile.BudgetRange = NormalizeChoice(profile.BudgetRange);
            profile.SetupGoal = NormalizeChoice(profile.SetupGoal);
            return profile;
        }

        private static void ValidateProfile(UserPersonalizationProfile profile)
        {
            if (profile == null || profile.UserId <= 0)
                throw new ArgumentException("A signed-in customer is required.");

            if (string.IsNullOrWhiteSpace(profile.GamingStyle))
                throw new ArgumentException("Choose your main gaming style.");

            if (profile.PreferredCategories == null || profile.PreferredCategories.Count == 0)
                throw new ArgumentException("Choose at least one gear interest.");

            if (profile.Priorities == null || profile.Priorities.Count == 0)
                throw new ArgumentException("Choose at least one purchase priority.");

            if (string.IsNullOrWhiteSpace(profile.BudgetRange))
                throw new ArgumentException("Choose your budget range.");

            if (string.IsNullOrWhiteSpace(profile.SetupGoal))
                throw new ArgumentException("Choose your setup goal.");
        }

        private static IList<string> NormalizeList(IList<string> values)
        {
            return (values ?? new List<string>())
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Select(NormalizeChoice)
                .Distinct()
                .ToList();
        }

        private static string NormalizeChoice(string value)
        {
            return (value ?? string.Empty).Trim();
        }

        private static string Normalize(string value)
        {
            return (value ?? string.Empty).Trim().ToLowerInvariant();
        }
    }
}
```

- [ ] **Step 5: Include files in project**

Modify `ONYX_DDAC.csproj`:

```xml
<Compile Include="DAL\PersonalizationRepository.cs" />
<Compile Include="Services\PersonalizationService.cs" />
```

- [ ] **Step 6: Run test and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Expected: source contract passes; build succeeds with `0 Error(s)`.

- [ ] **Step 7: Commit**

```powershell
git add DAL/PersonalizationRepository.cs Services/PersonalizationService.cs ONYX_DDAC.csproj tests/PersonalizationFlow.Tests.ps1
git commit -m "Add personalization scoring service"
```

---

### Task 3: Shared Post-Auth Personalization Routing

**Files:**
- Create: `Helpers/PostAuthRedirectHelper.cs`
- Modify: `Services/AuthService.cs`
- Modify: `auth_page/onyx_login.aspx.cs`
- Modify: `auth_page/onyx_register.aspx.cs`
- Modify: `auth_page/google_callback.aspx.cs`
- Modify: `auth_page/oauth_callback.aspx.cs`
- Modify: `ONYX_DDAC.csproj`
- Modify: `tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Consumes: `PersonalizationService.UserRequiresPersonalization(User user)`.
- Produces: `PostAuthRedirectHelper.GetTarget(Page page, User user, string requestedCustomerTarget) : string`.
- Produces: `PostAuthRedirectHelper.Redirect(Page page, User user, string requestedCustomerTarget = null) : void`.
- Produces: `AuthService.RegisterCustomer(...) : User`.

- [ ] **Step 1: Extend source-contract test for routing**

Append to `tests/PersonalizationFlow.Tests.ps1`:

```powershell
$redirectHelperPath = "$root\Helpers\PostAuthRedirectHelper.cs"
$redirectHelperText = if (Test-Path $redirectHelperPath) { Get-Content $redirectHelperPath -Raw } else { '' }
$authServiceText = Get-Content "$root\Services\AuthService.cs" -Raw
$loginText = Get-Content "$root\auth_page\onyx_login.aspx.cs" -Raw
$registerText = Get-Content "$root\auth_page\onyx_register.aspx.cs" -Raw
$googleCallbackText = Get-Content "$root\auth_page\google_callback.aspx.cs" -Raw
$oauthCallbackText = Get-Content "$root\auth_page\oauth_callback.aspx.cs" -Raw

$checks['Post-auth redirect helper routes incomplete customers to personalization'] =
    $redirectHelperText -match 'class PostAuthRedirectHelper' -and
    $redirectHelperText -match 'onyx_personalization.aspx' -and
    $redirectHelperText -match 'UserRequiresPersonalization' -and
    $redirectHelperText -match 'CompleteRequest'

$checks['Manual registration returns created user for auto-login'] =
    $authServiceText -match 'User\s+RegisterCustomer\s*\(' -and
    $authServiceText -match 'GetUserByEmail\s*\('

$checks['Auth pages use shared post-auth redirect'] =
    $loginText -match 'PostAuthRedirectHelper.Redirect' -and
    $registerText -match 'PostAuthRedirectHelper.Redirect' -and
    $googleCallbackText -match 'PostAuthRedirectHelper.Redirect' -and
    $oauthCallbackText -match 'PostAuthRedirectHelper.Redirect'
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Expected: FAIL with routing requirements.

- [ ] **Step 3: Add redirect helper**

Create `Helpers/PostAuthRedirectHelper.cs`:

```csharp
using System;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.Helpers
{
    public static class PostAuthRedirectHelper
    {
        public static string GetTarget(Page page, User user, string requestedCustomerTarget)
        {
            if (user == null)
                return "~/auth_page/onyx_login.aspx";

            if (string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
                return "~/admin_page/onyx_admin_dashboard.aspx";

            if (new PersonalizationService().UserRequiresPersonalization(user))
                return "~/customer_page/onyx_personalization.aspx";

            if (!string.IsNullOrWhiteSpace(requestedCustomerTarget))
                return requestedCustomerTarget;

            return "~/customer_page/onyx_home.aspx";
        }

        public static void Redirect(Page page, User user, string requestedCustomerTarget = null)
        {
            page.Response.Redirect(GetTarget(page, user, requestedCustomerTarget), false);
            page.Context.ApplicationInstance.CompleteRequest();
        }
    }
}
```

- [ ] **Step 4: Add registration method returning user**

Modify `Services/AuthService.cs` by adding:

```csharp
public User RegisterCustomer(
    string fullName,
    string username,
    string email,
    string rawPassword,
    DateTime dob,
    string address,
    string phoneNumber)
{
    string error = Register(fullName, username, email, rawPassword, dob, address, phoneNumber);
    if (error != null)
        throw new InvalidOperationException(error);

    User createdUser = _userRepository.GetUserByEmail(email);
    if (createdUser == null)
        throw new InvalidOperationException("Registration succeeded, but the customer account could not be loaded.");

    return createdUser;
}
```

- [ ] **Step 5: Replace login redirect**

In `auth_page/onyx_login.aspx.cs`, replace the customer/admin redirect block after `AuthHelper.EstablishAuthenticatedSession(this, user);` with:

```csharp
string destination = Request.QueryString["profile"] == "true"
    ? "~/customer_page/onyx_profile.aspx"
    : null;

PostAuthRedirectHelper.Redirect(this, user, destination);
return;
```

- [ ] **Step 6: Auto-login manual registration**

In `auth_page/onyx_register.aspx.cs`, replace the register success block:

```csharp
string error = _authService.Register(fullName, username, email, password, dob, address, phoneNumber);

if (error == null)
{
    Response.Redirect("onyx_login.aspx?registered=true");
}
else
{
    ShowMessage(error, false);
}
```

with:

```csharp
try
{
    var user = _authService.RegisterCustomer(fullName, username, email, password, dob, address, phoneNumber);
    AuthHelper.EstablishAuthenticatedSession(this, user);
    PostAuthRedirectHelper.Redirect(this, user);
}
catch (InvalidOperationException exception)
{
    ShowMessage(exception.Message, false);
}
```

- [ ] **Step 7: Replace OAuth role redirects**

In `auth_page/google_callback.aspx.cs`, replace:

```csharp
AuthHelper.EstablishAuthenticatedSession(this, user);
RedirectForRole(user.Role);
```

with:

```csharp
AuthHelper.EstablishAuthenticatedSession(this, user);
PostAuthRedirectHelper.Redirect(this, user);
```

In `auth_page/oauth_callback.aspx.cs`, make the same replacement.

Leave the old private `RedirectForRole` methods in place only if compilation still references them. Remove them if they become unused and the file stays clear.

- [ ] **Step 8: Include helper in project**

Modify `ONYX_DDAC.csproj`:

```xml
<Compile Include="Helpers\PostAuthRedirectHelper.cs" />
```

- [ ] **Step 9: Run tests and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Expected: source contract passes; build succeeds with `0 Error(s)`.

- [ ] **Step 10: Commit**

```powershell
git add Helpers/PostAuthRedirectHelper.cs Services/AuthService.cs auth_page/onyx_login.aspx.cs auth_page/onyx_register.aspx.cs auth_page/google_callback.aspx.cs auth_page/oauth_callback.aspx.cs ONYX_DDAC.csproj tests/PersonalizationFlow.Tests.ps1
git commit -m "Route new customers to personalization"
```

---

### Task 4: Mandatory ONYX Personalization Page

**Files:**
- Create: `customer_page/onyx_personalization.aspx`
- Create: `customer_page/onyx_personalization.aspx.cs`
- Create: `customer_page/onyx_personalization.aspx.designer.cs`
- Create: `Content/onyx-personalization.css`
- Modify: `ONYX_DDAC.csproj`
- Modify: `tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Consumes: `PersonalizationService.SaveProfile(UserPersonalizationProfile profile)`.
- Produces: a mandatory customer page at `/customer_page/onyx_personalization.aspx`.

- [ ] **Step 1: Extend source-contract test for onboarding page**

Append to `tests/PersonalizationFlow.Tests.ps1`:

```powershell
$personalizationPage = "$root\customer_page\onyx_personalization.aspx"
$personalizationCode = "$root\customer_page\onyx_personalization.aspx.cs"
$personalizationCss = "$root\Content\onyx-personalization.css"
$pageText = if (Test-Path $personalizationPage) { Get-Content $personalizationPage -Raw } else { '' }
$codeText = if (Test-Path $personalizationCode) { Get-Content $personalizationCode -Raw } else { '' }
$cssText = if (Test-Path $personalizationCss) { Get-Content $personalizationCss -Raw } else { '' }

$checks['Personalization page defines required questions and submit action'] =
    $pageText -match 'Build Your ONYX Setup' -and
    $pageText -match 'gaming_style' -and
    $pageText -match 'preferred_categories' -and
    $pageText -match 'priorities' -and
    $pageText -match 'budget_range' -and
    $pageText -match 'setup_goal' -and
    $pageText -match 'Build My Setup'

$checks['Personalization code requires login and saves profile'] =
    $codeText -match 'AuthHelper.RequireLogin' -and
    $codeText -match 'PersonalizationService' -and
    $codeText -match 'SaveProfile' -and
    $codeText -match 'onyx_home.aspx'

$checks['Personalization CSS is monochrome ONYX theme'] =
    $cssText -match '#000' -and
    $cssText -match '#0b0b0c' -and
    $cssText -match '#d8dde3' -and
    $cssText -notmatch '#0b1220|#0f172a|navy|blue'

$checks['Project includes personalization page files'] =
    $project -match 'customer_page\\onyx_personalization.aspx' -and
    $project -match 'customer_page\\onyx_personalization.aspx.cs' -and
    $project -match 'customer_page\\onyx_personalization.aspx.designer.cs' -and
    $project -match 'Content\\onyx-personalization.css'
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Expected: FAIL with personalization page requirements.

- [ ] **Step 3: Create page markup**

Create `customer_page/onyx_personalization.aspx` using the customer master page, link `Content/onyx-personalization.css`, and define hidden fields:

```aspx
<asp:HiddenField ID="GamingStyleField" runat="server" />
<asp:HiddenField ID="PreferredCategoriesField" runat="server" />
<asp:HiddenField ID="PrioritiesField" runat="server" />
<asp:HiddenField ID="BudgetRangeField" runat="server" />
<asp:HiddenField ID="SetupGoalField" runat="server" />
```

Use option button groups with `data-target` and `data-value` attributes:

```html
<button type="button" class="onyx-choice" data-target="gaming_style" data-value="FPS">FPS</button>
<button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mouse">Mouse</button>
<button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Speed">Speed</button>
<button type="button" class="onyx-choice" data-target="budget_range" data-value="Mid-range">Mid-range</button>
<button type="button" class="onyx-choice" data-target="setup_goal" data-value="Competitive">Competitive</button>
```

Final server button:

```aspx
<asp:Button ID="BuildSetupButton" runat="server" Text="Build My Setup" CssClass="onyx-personalization-submit" OnClick="BuildSetupButton_Click" />
<asp:Label ID="FeedbackLabel" runat="server" CssClass="onyx-personalization-feedback" Visible="false" />
```

Add a small script that maps choice state into hidden fields:

```javascript
(function () {
    var fields = {
        gaming_style: '<%= GamingStyleField.ClientID %>',
        preferred_categories: '<%= PreferredCategoriesField.ClientID %>',
        priorities: '<%= PrioritiesField.ClientID %>',
        budget_range: '<%= BudgetRangeField.ClientID %>',
        setup_goal: '<%= SetupGoalField.ClientID %>'
    };

    function sync(target) {
        var selected = Array.prototype.slice.call(document.querySelectorAll('[data-target="' + target + '"].is-selected'))
            .map(function (button) { return button.getAttribute('data-value'); });
        document.getElementById(fields[target]).value = selected.join(',');
    }

    document.querySelectorAll('.onyx-choice').forEach(function (button) {
        button.addEventListener('click', function () {
            var target = button.getAttribute('data-target');
            var multi = button.getAttribute('data-multi') === 'true';
            if (!multi) {
                document.querySelectorAll('[data-target="' + target + '"]').forEach(function (peer) {
                    peer.classList.remove('is-selected');
                });
            }
            button.classList.toggle('is-selected');
            sync(target);
        });
    });
})();
```

- [ ] **Step 4: Create code-behind**

Create `customer_page/onyx_personalization.aspx.cs`:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_personalization : Page
    {
        private readonly PersonalizationService personalizationService = new PersonalizationService();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireLogin(this);

            if (!IsPostBack && TryGetUserId(out long userId) && personalizationService.HasCompletedProfile(userId))
            {
                Response.Redirect("~/customer_page/onyx_home.aspx", true);
            }
        }

        protected void BuildSetupButton_Click(object sender, EventArgs e)
        {
            if (!TryGetUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx", true);
                return;
            }

            try
            {
                personalizationService.SaveProfile(new UserPersonalizationProfile
                {
                    UserId = userId,
                    GamingStyle = GamingStyleField.Value,
                    PreferredCategories = SplitValues(PreferredCategoriesField.Value),
                    Priorities = SplitValues(PrioritiesField.Value),
                    BudgetRange = BudgetRangeField.Value,
                    SetupGoal = SetupGoalField.Value
                });

                Response.Redirect("~/customer_page/onyx_home.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception exception)
            {
                FeedbackLabel.Text = Server.HtmlEncode(exception.Message);
                FeedbackLabel.Visible = true;
            }
        }

        private static IList<string> SplitValues(string value)
        {
            return (value ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => item.Length > 0)
                .ToList();
        }

        private bool TryGetUserId(out long userId)
        {
            userId = 0;
            object value = Session["UserId"];
            return value != null && long.TryParse(value.ToString(), out userId);
        }
    }
}
```

- [ ] **Step 5: Create designer**

Create `customer_page/onyx_personalization.aspx.designer.cs` with declarations for:

```csharp
protected global::System.Web.UI.WebControls.HiddenField GamingStyleField;
protected global::System.Web.UI.WebControls.HiddenField PreferredCategoriesField;
protected global::System.Web.UI.WebControls.HiddenField PrioritiesField;
protected global::System.Web.UI.WebControls.HiddenField BudgetRangeField;
protected global::System.Web.UI.WebControls.HiddenField SetupGoalField;
protected global::System.Web.UI.WebControls.Button BuildSetupButton;
protected global::System.Web.UI.WebControls.Label FeedbackLabel;
```

- [ ] **Step 6: Create monochrome UI CSS**

Create `Content/onyx-personalization.css` with these tokens:

```css
:root {
    --onyx-black: #000;
    --onyx-panel: #0b0b0c;
    --onyx-graphite: #141414;
    --onyx-line: #333;
    --onyx-muted: #8f8f8f;
    --onyx-text: #f5f5f5;
    --onyx-silver: #d8dde3;
}
```

Use underline or hairline choice controls. Do not use blue/navy colors. Choice hover state should invert to soft silver background with black text.

- [ ] **Step 7: Include files in project**

Modify `ONYX_DDAC.csproj` with content and compile entries for the page and CSS.

- [ ] **Step 8: Run test and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Expected: source contract passes; build succeeds with `0 Error(s)`.

- [ ] **Step 9: Commit**

```powershell
git add customer_page/onyx_personalization.aspx customer_page/onyx_personalization.aspx.cs customer_page/onyx_personalization.aspx.designer.cs Content/onyx-personalization.css ONYX_DDAC.csproj tests/PersonalizationFlow.Tests.ps1
git commit -m "Add customer personalization onboarding"
```

---

### Task 5: Personalized Home And Catalog Recommendations

**Files:**
- Modify: `Models/CatalogQuery.cs`
- Modify: `Services/ProductService.cs`
- Modify: `customer_page/onyx_home.aspx`
- Modify: `customer_page/onyx_home.aspx.cs`
- Modify: `customer_page/onyx_home.aspx.designer.cs`
- Modify: `customer_page/onyx_catalog.aspx`
- Modify: `customer_page/onyx_catalog.aspx.cs`
- Modify: `tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Consumes: `PersonalizationService.GetRecommendedProducts(long userId, int count)`.
- Produces: home personalized product strip.
- Produces: catalog `recommended` sort for signed-in completed users.

- [ ] **Step 1: Extend source-contract test for home/catalog personalization**

Append to `tests/PersonalizationFlow.Tests.ps1`:

```powershell
$homeMarkup = Get-Content "$root\customer_page\onyx_home.aspx" -Raw
$homeCode = Get-Content "$root\customer_page\onyx_home.aspx.cs" -Raw
$catalogMarkup = Get-Content "$root\customer_page\onyx_catalog.aspx" -Raw
$catalogCode = Get-Content "$root\customer_page\onyx_catalog.aspx.cs" -Raw
$productServiceText = Get-Content "$root\Services\ProductService.cs" -Raw
$catalogQueryText = Get-Content "$root\Models\CatalogQuery.cs" -Raw

$checks['Home page binds personalized recommendation strip'] =
    $homeMarkup -match 'PersonalizedProductsRepeater' -and
    $homeMarkup -match 'For your setup' -and
    $homeCode -match 'GetRecommendedProducts' -and
    $homeCode -match 'PersonalizedProductsPanel'

$checks['Catalog exposes recommended sort'] =
    $catalogMarkup -match 'value="recommended"' -and
    $catalogCode -match 'recommended' -and
    $catalogQueryText -match 'long\?\s+UserId'

$checks['Product service handles recommended sort through personalization'] =
    $productServiceText -match 'recommended' -and
    $productServiceText -match 'PersonalizationService'
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Expected: FAIL with home/catalog requirements.

- [ ] **Step 3: Extend catalog query**

Modify `Models/CatalogQuery.cs`:

```csharp
public long? UserId { get; set; }
```

- [ ] **Step 4: Update product service recommended sort**

Modify `Services/ProductService.cs`:

```csharp
case "recommended":
    return "recommended";
```

In `GetCatalogProducts`, after normalization and before returning repository results:

```csharp
if (string.Equals(normalizedQuery.Sort, "recommended", System.StringComparison.OrdinalIgnoreCase) &&
    normalizedQuery.UserId.HasValue)
{
    IList<PersonalizedProduct> recommended =
        new PersonalizationService().GetRecommendedProducts(normalizedQuery.UserId.Value, 48);

    IList<Product> filtered = recommended
        .Select(item => item.Product)
        .Where(product => string.IsNullOrWhiteSpace(normalizedQuery.Category) ||
            string.Equals(product.Category, normalizedQuery.Category, System.StringComparison.OrdinalIgnoreCase))
        .Where(product => string.IsNullOrWhiteSpace(normalizedQuery.SearchTerm) ||
            (product.Name ?? string.Empty).IndexOf(normalizedQuery.SearchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0 ||
            (product.Description ?? string.Empty).IndexOf(normalizedQuery.SearchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0)
        .ToList();

    int totalCount = filtered.Count;
    int skip = (normalizedQuery.Page - 1) * normalizedQuery.PageSize;

    return new PagedResult<Product>
    {
        Items = filtered.Skip(skip).Take(normalizedQuery.PageSize).ToList(),
        Page = normalizedQuery.Page,
        PageSize = normalizedQuery.PageSize,
        TotalCount = totalCount
    };
}
```

Add `using System.Linq;` and ensure `PagedResult<T>` property names match the existing model before compiling.

- [ ] **Step 5: Bind user ID in catalog**

In `customer_page/onyx_catalog.aspx.cs`, pass user ID into the query:

```csharp
long userId;
long? recommendationUserId = TryGetCurrentUserId(out userId) ? (long?)userId : null;

PagedResult<Product> result = productService.GetCatalogProducts(new CatalogQuery
{
    Category = SelectedCategory,
    SearchTerm = SearchTerm,
    Sort = SelectedSort,
    Page = CurrentPage,
    PageSize = 8,
    UserId = recommendationUserId
});
```

Allow `recommended` in `NormalizeSort`.

- [ ] **Step 6: Add catalog sort option**

In `customer_page/onyx_catalog.aspx`, add this as first option:

```aspx
<option value="recommended"<%= GetSelectedSortAttribute("recommended") %>>Recommended</option>
```

- [ ] **Step 7: Add home personalized strip**

In `customer_page/onyx_home.aspx`, add a panel before featured products:

```aspx
<asp:Panel ID="PersonalizedProductsPanel" runat="server" Visible="false" CssClass="onyx-personalized-strip">
    <div class="max-w-7xl mx-auto">
        <p class="text-accent uppercase tracking-widest text-sm font-bold mb-4">For your setup</p>
        <h2 class="text-4xl md:text-6xl font-syne font-bold tracking-tighter leading-tight">Recommended from your ONYX profile.</h2>
        <asp:Repeater ID="PersonalizedProductsRepeater" runat="server">
            <ItemTemplate>
                <article class="onyx-ddac-product-card reveal-item">
                    <div class="onyx-ddac-product-media">
                        <img src='<%# GetFeaturedProductImageUrl(Eval("Product.Category"), Container.ItemIndex) %>' alt='<%# Server.HtmlEncode(Eval("Product.Name").ToString()) %>' class="onyx-ddac-product-image" loading="lazy" />
                    </div>
                    <div class="onyx-ddac-product-body">
                        <p><%# Eval("Reason") %></p>
                        <h3><%# Eval("Product.Name") %></h3>
                        <div class="onyx-ddac-product-meta">
                            <strong><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Product.Price")) %></strong>
                            <a href='<%# "onyx_product_details.aspx?id=" + Eval("Product.Id") %>'>View</a>
                        </div>
                    </div>
                </article>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
```

If nested `Eval("Product.Name")` does not bind in Web Forms, replace with protected helpers in code-behind that cast `Container.DataItem` to `PersonalizedProduct`.

- [ ] **Step 8: Bind home recommendations**

In `customer_page/onyx_home.aspx.cs`, add:

```csharp
private readonly PersonalizationService personalizationService = new PersonalizationService();
```

Inside `Page_Load` after featured products:

```csharp
BindPersonalizedProducts();
```

Add:

```csharp
private void BindPersonalizedProducts()
{
    if (!TryGetCurrentUserId(out long userId) || !personalizationService.HasCompletedProfile(userId))
    {
        PersonalizedProductsPanel.Visible = false;
        return;
    }

    var recommendations = personalizationService.GetRecommendedProducts(userId, 4);
    PersonalizedProductsPanel.Visible = recommendations.Count > 0;
    PersonalizedProductsRepeater.DataSource = recommendations;
    PersonalizedProductsRepeater.DataBind();
}

private bool TryGetCurrentUserId(out long userId)
{
    userId = 0;
    object value = Session["UserId"];
    return value != null && long.TryParse(value.ToString(), out userId);
}
```

- [ ] **Step 9: Update designer**

Add home designer declarations:

```csharp
protected global::System.Web.UI.WebControls.Panel PersonalizedProductsPanel;
protected global::System.Web.UI.WebControls.Repeater PersonalizedProductsRepeater;
```

- [ ] **Step 10: Run test and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Expected: source contract passes; build succeeds with `0 Error(s)`.

- [ ] **Step 11: Commit**

```powershell
git add Models/CatalogQuery.cs Services/ProductService.cs customer_page/onyx_home.aspx customer_page/onyx_home.aspx.cs customer_page/onyx_home.aspx.designer.cs customer_page/onyx_catalog.aspx customer_page/onyx_catalog.aspx.cs tests/PersonalizationFlow.Tests.ps1
git commit -m "Show personalized product recommendations"
```

---

### Task 6: Final Verification And PR Update

**Files:**
- Modify only files needed to fix verification failures found in this task.

**Interfaces:**
- Consumes: all previous tasks.
- Produces: a branch ready for PR review.

- [ ] **Step 1: Run full test suite**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\AuthAsyncPostback.Tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\OAuthCallbackPkce.Tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\ForgotPasswordFlow.Tests.ps1
powershell -ExecutionPolicy Bypass -File .\tests\PersonalizationFlow.Tests.ps1
```

Expected: all scripts print their pass message and exit with code `0`.

- [ ] **Step 2: Run full build**

Run:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' .\ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /m
```

Expected: `Build succeeded. 0 Warning(s). 0 Error(s).`

- [ ] **Step 3: Apply database migration locally**

Run the SQL in `App_Data/20260705_user_personalization_profiles.sql` against the ONYX PostgreSQL database using DBeaver or the team's normal migration path.

Expected: table `user_personalization_profiles` exists.

- [ ] **Step 4: Manual browser verification**

Run the app in Visual Studio/IIS Express and verify:

```text
Manual registration -> personalization page -> complete setup -> home
OAuth signup -> personalization page -> complete setup -> home
Existing completed user login -> home
Admin login -> admin dashboard
Catalog sort Recommended -> products remain visible
Personalization UI -> black/graphite/silver only, no blue/navy fields
```

- [ ] **Step 5: Commit verification fixes**

If fixes were needed:

```powershell
git add App_Data Models DAL Services Helpers auth_page customer_page Content ONYX_DDAC.csproj tests
git commit -m "Fix personalization verification issues"
```

If no fixes were needed, do not create an empty commit.

- [ ] **Step 6: Push branch**

Run:

```powershell
git push
```

Expected: branch `feature/Jovan-OAuth-on-main` updates the existing PR.
