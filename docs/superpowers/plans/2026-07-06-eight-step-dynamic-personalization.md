# Eight-Step Dynamic Personalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand ONYX personalization to eight saved questionnaire answers and make recommendations update dynamically from profile, orders, wishlist, and search behavior.

**Architecture:** Keep `PersonalizationService` as the single ranking pipeline for home and catalog. Store stable questionnaire answers as first-class columns in `user_personalization_profiles`, while dynamic behavior remains in order, wishlist, catalog search event, and session/cookie signals.

**Tech Stack:** ASP.NET Web Forms, C# .NET Framework 4.8, PostgreSQL through Npgsql, PowerShell source-contract tests, Visual Studio MSBuild.

## Global Constraints

- Preserve the existing monochrome, one-question-per-page personalization UI.
- Expand the questionnaire from five to eight steps.
- Store every questionnaire answer in the database.
- Entry/Budget intent tie-breaks personalized matches by lower price.
- Premium/Premium Build intent tie-breaks personalized matches by higher price.
- Search behavior must boost recommendations immediately and over time.
- Missing optional behavior tables must not break catalog or home pages.
- Explicit catalog sort choices must override recommended personalization order.

---

### Task 1: Add Failing Source Contract For Eight-Step Dynamic Personalization

**Files:**
- Modify: `Tests/PersonalizationFlow.Tests.ps1`
- Mirror if present: `tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Consumes: existing source-contract test style in `Tests/PersonalizationFlow.Tests.ps1`.
- Produces: failing checks for schema/model/repository/page/ranking/search behavior used by later tasks.

- [ ] **Step 1: Add failing checks to `Tests/PersonalizationFlow.Tests.ps1`**

Add these checks inside the `$checks = [ordered]@{ ... }` block:

```powershell
'Personalization schema stores expanded questionnaire answers' =
    ((Get-Content $schemaPath -Raw) -match 'comfort_preferences') -and
    ((Get-Content $schemaPath -Raw) -match 'performance_preferences') -and
    ((Get-Content $schemaPath -Raw) -match 'setup_constraints')

'User personalization profile model stores expanded answer lists' =
    $profileModelText -match 'IList<string>\s+ComfortPreferences' -and
    $profileModelText -match 'IList<string>\s+PerformancePreferences' -and
    $profileModelText -match 'IList<string>\s+SetupConstraints'

'Personalization page expands to eight saved steps' =
    $pageText -match 'data-step-count="8"' -and
    $pageText -match 'STEP 1 OF 8' -and
    $pageText -match 'comfort_preferences' -and
    $pageText -match 'performance_preferences' -and
    $pageText -match 'setup_constraints' -and
    $pageText -match 'What matters most for your comfort\?' -and
    $pageText -match 'What performance feature do you care about the most\?' -and
    $pageText -match 'What setup constraint should ONYX respect\?'

'Personalization save maps expanded questionnaire answers' =
    $codeText -match 'ComfortPreferencesField\.Value' -and
    $codeText -match 'PerformancePreferencesField\.Value' -and
    $codeText -match 'SetupConstraintsField\.Value' -and
    $codeText -match 'ComfortPreferences\s*=\s*SplitValues' -and
    $codeText -match 'PerformancePreferences\s*=\s*SplitValues' -and
    $codeText -match 'SetupConstraints\s*=\s*SplitValues'

'Recommendation ranking supports expanded answer scoring and price intent' =
    $serviceText -match 'MatchedComfortPreferences' -and
    $serviceText -match 'MatchedPerformancePreferences' -and
    $serviceText -match 'MatchedSetupConstraints' -and
    $serviceText -match 'GetPriceIntent' -and
    $serviceText -match 'ThenByPriceIntent'

'Search personalization records immediate dynamic signals' =
    $repositoryText -match 'InferSearchCategories' -and
    $repositoryText -match 'mic' -and
    $repositoryText -match 'mousepad' -and
    $catalogCode -match 'StoreRecentSearchSignal' -and
    $catalogCode -match 'GetRecentSearchSignals' -and
    $catalogCode -match 'CurrentSearchSignals'
```

If `tests/PersonalizationFlow.Tests.ps1` is a duplicate mirror, apply the same check block there.

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Expected: FAIL with missing requirements for expanded questionnaire, price intent, and search dynamic signals.

- [ ] **Step 3: Commit the failing test**

```powershell
git add Tests\PersonalizationFlow.Tests.ps1 tests\PersonalizationFlow.Tests.ps1
git commit -m "test: cover dynamic personalization upgrade"
```

Expected: commit succeeds. If the lowercase `tests` file does not exist or is not tracked separately, stage only `Tests\PersonalizationFlow.Tests.ps1`.

---

### Task 2: Extend Profile Schema, Model, and Repository

**Files:**
- Modify: `App_Data/20260705_user_personalization_profiles.sql`
- Modify: `Models/UserPersonalizationProfile.cs`
- Modify: `DAL/PersonalizationRepository.cs`
- Modify if needed: `ONYX_DDAC.csproj`

**Interfaces:**
- Produces model properties:
  - `IList<string> ComfortPreferences { get; set; }`
  - `IList<string> PerformancePreferences { get; set; }`
  - `IList<string> SetupConstraints { get; set; }`
- Produces repository persistence for those properties through `SaveProfile(UserPersonalizationProfile profile)` and `GetProfile(long userId)`.

- [ ] **Step 1: Update schema with additive columns**

Append this SQL to `App_Data/20260705_user_personalization_profiles.sql` after the existing table/index statements:

```sql
ALTER TABLE user_personalization_profiles
    ADD COLUMN IF NOT EXISTS comfort_preferences TEXT NOT NULL DEFAULT '';

ALTER TABLE user_personalization_profiles
    ADD COLUMN IF NOT EXISTS performance_preferences TEXT NOT NULL DEFAULT '';

ALTER TABLE user_personalization_profiles
    ADD COLUMN IF NOT EXISTS setup_constraints TEXT NOT NULL DEFAULT '';
```

- [ ] **Step 2: Update model properties**

Add these properties to `Models/UserPersonalizationProfile.cs` after `Priorities`:

```csharp
public IList<string> ComfortPreferences { get; set; } = new List<string>();
public IList<string> PerformancePreferences { get; set; } = new List<string>();
public IList<string> SetupConstraints { get; set; } = new List<string>();
```

- [ ] **Step 3: Update repository select and mapper**

In `DAL/PersonalizationRepository.cs`, update the profile SELECT to include the new fields:

```csharp
cmd.CommandText = @"
    SELECT user_id, gaming_style, preferred_categories, priorities,
           budget_range, setup_goal, completed_at, updated_at,
           comfort_preferences, performance_preferences, setup_constraints
    FROM user_personalization_profiles
    WHERE user_id = @UserId";
```

Update `MapProfile`:

```csharp
ComfortPreferences = reader.FieldCount > 8 && !reader.IsDBNull(8) ? SplitValues(reader.GetString(8)) : new List<string>(),
PerformancePreferences = reader.FieldCount > 9 && !reader.IsDBNull(9) ? SplitValues(reader.GetString(9)) : new List<string>(),
SetupConstraints = reader.FieldCount > 10 && !reader.IsDBNull(10) ? SplitValues(reader.GetString(10)) : new List<string>()
```

- [ ] **Step 4: Update repository upsert**

Change the INSERT columns and values:

```sql
(user_id, gaming_style, preferred_categories, priorities,
 budget_range, setup_goal, comfort_preferences, performance_preferences,
 setup_constraints, completed_at, updated_at)
VALUES
(@UserId, @GamingStyle, @PreferredCategories, @Priorities,
 @BudgetRange, @SetupGoal, @ComfortPreferences, @PerformancePreferences,
 @SetupConstraints, NOW(), NOW())
```

Add update assignments:

```sql
comfort_preferences = EXCLUDED.comfort_preferences,
performance_preferences = EXCLUDED.performance_preferences,
setup_constraints = EXCLUDED.setup_constraints,
```

Add parameters:

```csharp
AddParameter(cmd, "@ComfortPreferences", JoinValues(profile.ComfortPreferences));
AddParameter(cmd, "@PerformancePreferences", JoinValues(profile.PerformancePreferences));
AddParameter(cmd, "@SetupConstraints", JoinValues(profile.SetupConstraints));
```

- [ ] **Step 5: Run the focused test**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Expected: schema/model/repository checks pass; page, ranking, and search checks still fail.

- [ ] **Step 6: Commit**

```powershell
git add App_Data\20260705_user_personalization_profiles.sql Models\UserPersonalizationProfile.cs DAL\PersonalizationRepository.cs ONYX_DDAC.csproj
git commit -m "feat: store expanded personalization answers"
```

---

### Task 3: Expand Personalization Page To Eight Steps

**Files:**
- Modify: `customer_page/onyx_personalization.aspx`
- Modify: `customer_page/onyx_personalization.aspx.cs`
- Modify: `customer_page/onyx_personalization.aspx.designer.cs`
- Modify if needed: `Content/onyx-personalization.css`

**Interfaces:**
- Consumes model fields from Task 2.
- Produces hidden fields:
  - `ComfortPreferencesField`
  - `PerformancePreferencesField`
  - `SetupConstraintsField`

- [ ] **Step 1: Add hidden fields and JS field map**

In `customer_page/onyx_personalization.aspx`, add:

```aspx
<asp:HiddenField ID="ComfortPreferencesField" runat="server" />
<asp:HiddenField ID="PerformancePreferencesField" runat="server" />
<asp:HiddenField ID="SetupConstraintsField" runat="server" />
```

Update the JS `fields` object:

```javascript
comfort_preferences: '<%= ComfortPreferencesField.ClientID %>',
performance_preferences: '<%= PerformancePreferencesField.ClientID %>',
setup_constraints: '<%= SetupConstraintsField.ClientID %>'
```

- [ ] **Step 2: Change progress count to eight**

Change:

```aspx
<span id="onyxPersonalizationStepLabel">STEP 1 OF 8</span>
<strong id="onyxPersonalizationPercent">13%</strong>
<div class="onyx-personalization-stage" data-step-count="8">
```

- [ ] **Step 3: Add category choices to gear focus**

Add these buttons in the preferred categories step:

```aspx
<button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Monitor" aria-pressed="false"><span>Monitor</span><i aria-hidden="true"></i></button>
<button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mic" aria-pressed="false"><span>Mic</span><i aria-hidden="true"></i></button>
<button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mousepad" aria-pressed="false"><span>Mousepad</span><i aria-hidden="true"></i></button>
<button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Cable" aria-pressed="false"><span>Cable</span><i aria-hidden="true"></i></button>
<button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Monitor Extension" aria-pressed="false"><span>Monitor Extension</span><i aria-hidden="true"></i></button>
```

- [ ] **Step 4: Add step 6 comfort preference**

Insert after setup goal or before budget if preferred visually; keep `data-step-index` sequential:

```aspx
<article class="onyx-personalization-step" data-step-index="5" data-target="comfort_preferences" aria-labelledby="comfort-preferences-title" hidden>
    <p class="onyx-personalization-kicker">06 / Comfort</p>
    <h1 id="comfort-preferences-title">What matters most for your comfort?</h1>
    <p class="onyx-personalization-prompt">Pick every comfort signal ONYX should respect in your recommendations.</p>
    <div class="onyx-personalization-choices">
        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Lightweight gear" aria-pressed="false"><span>Lightweight gear</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Ergonomic shape" aria-pressed="false"><span>Ergonomic shape</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Soft ear cushions" aria-pressed="false"><span>Soft ear cushions</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Wrist support" aria-pressed="false"><span>Wrist support</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Adjustable size" aria-pressed="false"><span>Adjustable size</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Low noise" aria-pressed="false"><span>Low noise</span><i aria-hidden="true"></i></button>
    </div>
</article>
```

- [ ] **Step 5: Add step 7 performance preference**

```aspx
<article class="onyx-personalization-step" data-step-index="6" data-target="performance_preferences" aria-labelledby="performance-preferences-title" hidden>
    <p class="onyx-personalization-kicker">07 / Performance</p>
    <h1 id="performance-preferences-title">What performance feature do you care about the most?</h1>
    <p class="onyx-personalization-prompt">Pick the performance signals ONYX should score higher.</p>
    <div class="onyx-personalization-choices">
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Low latency" aria-pressed="false"><span>Low latency</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="High DPI" aria-pressed="false"><span>High DPI</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Mechanical switches" aria-pressed="false"><span>Mechanical switches</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Noise cancellation" aria-pressed="false"><span>Noise cancellation</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="High refresh rate" aria-pressed="false"><span>High refresh rate</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Long battery life" aria-pressed="false"><span>Long battery life</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Accurate tracking" aria-pressed="false"><span>Accurate tracking</span><i aria-hidden="true"></i></button>
    </div>
</article>
```

- [ ] **Step 6: Add step 8 setup constraint**

```aspx
<article class="onyx-personalization-step" data-step-index="7" data-target="setup_constraints" aria-labelledby="setup-constraints-title" hidden>
    <p class="onyx-personalization-kicker">08 / Setup constraint</p>
    <h1 id="setup-constraints-title">What setup constraint should ONYX respect?</h1>
    <p class="onyx-personalization-prompt">These details help ONYX avoid awkward recommendations.</p>
    <div class="onyx-personalization-choices">
        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Small hands" aria-pressed="false"><span>Small hands</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Compact desk" aria-pressed="false"><span>Compact desk</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Long sessions" aria-pressed="false"><span>Long sessions</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Shared room" aria-pressed="false"><span>Shared room</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Streaming setup" aria-pressed="false"><span>Streaming setup</span><i aria-hidden="true"></i></button>
        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Minimal desk" aria-pressed="false"><span>Minimal desk</span><i aria-hidden="true"></i></button>
    </div>
</article>
```

- [ ] **Step 7: Save new fields in code-behind**

In `BuildSetupButton_Click`, add:

```csharp
ComfortPreferences = SplitValues(ComfortPreferencesField.Value),
PerformancePreferences = SplitValues(PerformancePreferencesField.Value),
SetupConstraints = SplitValues(SetupConstraintsField.Value)
```

In `IsKnownValidationMessage`, add:

```csharp
string.Equals(message, "Choose at least one comfort preference.", StringComparison.Ordinal) ||
string.Equals(message, "Choose at least one performance preference.", StringComparison.Ordinal) ||
string.Equals(message, "Choose at least one setup constraint.", StringComparison.Ordinal) ||
```

- [ ] **Step 8: Update designer controls**

Add to `customer_page/onyx_personalization.aspx.designer.cs`:

```csharp
protected global::System.Web.UI.WebControls.HiddenField ComfortPreferencesField;
protected global::System.Web.UI.WebControls.HiddenField PerformancePreferencesField;
protected global::System.Web.UI.WebControls.HiddenField SetupConstraintsField;
```

- [ ] **Step 9: Run focused test**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Expected: page and save mapping checks pass; ranking/search checks still fail.

- [ ] **Step 10: Commit**

```powershell
git add customer_page\onyx_personalization.aspx customer_page\onyx_personalization.aspx.cs customer_page\onyx_personalization.aspx.designer.cs Content\onyx-personalization.css
git commit -m "feat: expand personalization questionnaire"
```

---

### Task 4: Score Expanded Answers And Price Intent

**Files:**
- Modify: `Services/PersonalizationService.cs`

**Interfaces:**
- Consumes new profile fields from Task 2.
- Produces helpers:
  - `private static string GetPriceIntent(UserPersonalizationProfile profile)`
  - `private static IOrderedEnumerable<PersonalizedProduct> ThenByPriceIntent(IEnumerable<PersonalizedProduct> items, UserPersonalizationProfile profile)`
  - `MatchedComfortPreferences`, `MatchedPerformancePreferences`, `MatchedSetupConstraints` signal lists.

- [ ] **Step 1: Normalize new profile lists**

In `NormalizeProfile`, add:

```csharp
profile.ComfortPreferences = NormalizeList(profile.ComfortPreferences);
profile.PerformancePreferences = NormalizeList(profile.PerformancePreferences);
profile.SetupConstraints = NormalizeList(profile.SetupConstraints);
```

- [ ] **Step 2: Validate new answers**

In `ValidateProfile`, add:

```csharp
if (profile.ComfortPreferences == null || profile.ComfortPreferences.Count == 0)
{
    throw new ArgumentException("Choose at least one comfort preference.");
}

if (profile.PerformancePreferences == null || profile.PerformancePreferences.Count == 0)
{
    throw new ArgumentException("Choose at least one performance preference.");
}

if (profile.SetupConstraints == null || profile.SetupConstraints.Count == 0)
{
    throw new ArgumentException("Choose at least one setup constraint.");
}
```

- [ ] **Step 3: Add signal properties**

Add to `RecommendationSignals`:

```csharp
public IList<string> MatchedComfortPreferences { get; set; }
public IList<string> MatchedPerformancePreferences { get; set; }
public IList<string> MatchedSetupConstraints { get; set; }
```

- [ ] **Step 4: Add matchers**

Add these helpers:

```csharp
private static IEnumerable<string> ComfortPreferenceMatches(IList<string> preferences, string category, string searchable)
{
    return (preferences ?? new List<string>())
        .Select(Normalize)
        .Where(preference => ComfortPreferenceMatches(preference, category, searchable));
}

private static bool ComfortPreferenceMatches(string preference, string category, string searchable)
{
    switch (preference)
    {
        case "lightweight gear":
            return ContainsAny(searchable, "lightweight", "light", "compact") || category == "mouse";
        case "ergonomic shape":
            return ContainsAny(searchable, "ergonomic", "comfort", "shape") || category == "mouse" || category == "chair";
        case "soft ear cushions":
            return category == "headset" || ContainsAny(searchable, "cushion", "soft", "ear");
        case "wrist support":
            return category == "keyboard" || ContainsAny(searchable, "wrist", "palm", "support");
        case "adjustable size":
            return ContainsAny(searchable, "adjustable", "fit", "height", "extend");
        case "low noise":
            return ContainsAny(searchable, "quiet", "silent", "low noise", "dampened");
        default:
            return false;
    }
}

private static IEnumerable<string> PerformancePreferenceMatches(IList<string> preferences, string category, string searchable)
{
    return (preferences ?? new List<string>())
        .Select(Normalize)
        .Where(preference => PerformancePreferenceMatches(preference, category, searchable));
}

private static bool PerformancePreferenceMatches(string preference, string category, string searchable)
{
    switch (preference)
    {
        case "low latency":
            return ContainsAny(searchable, "low latency", "latency", "response", "fast");
        case "high dpi":
            return category == "mouse" || ContainsAny(searchable, "dpi", "sensor");
        case "mechanical switches":
            return category == "keyboard" || ContainsAny(searchable, "mechanical", "switch");
        case "noise cancellation":
            return category == "headset" || ContainsAny(searchable, "noise cancellation", "noise-cancelling", "mic");
        case "high refresh rate":
            return category == "monitor" || ContainsAny(searchable, "refresh", "hz", "high refresh");
        case "long battery life":
            return ContainsAny(searchable, "battery", "wireless", "long life");
        case "accurate tracking":
            return category == "mouse" || ContainsAny(searchable, "tracking", "precision", "sensor");
        default:
            return false;
    }
}

private static IEnumerable<string> SetupConstraintMatches(IList<string> constraints, string category, string searchable)
{
    return (constraints ?? new List<string>())
        .Select(Normalize)
        .Where(constraint => SetupConstraintMatches(constraint, category, searchable));
}

private static bool SetupConstraintMatches(string constraint, string category, string searchable)
{
    switch (constraint)
    {
        case "small hands":
            return category == "mouse" || ContainsAny(searchable, "mini", "small", "compact");
        case "compact desk":
            return ContainsAny(searchable, "compact", "tenkeyless", "tkl", "60%", "small");
        case "long sessions":
            return ContainsAny(searchable, "comfort", "ergonomic", "cushion", "battery");
        case "shared room":
            return ContainsAny(searchable, "quiet", "silent", "low noise", "noise cancellation");
        case "streaming setup":
            return category == "headset" || category == "mic" || ContainsAny(searchable, "stream", "voice", "mic");
        case "minimal desk":
            return category == "mousepad" || category == "cable" || ContainsAny(searchable, "minimal", "clean", "wireless");
        default:
            return false;
    }
}
```

- [ ] **Step 5: Wire signal calculation and score**

Inside `GetRecommendationSignals`, calculate:

```csharp
IList<string> matchedComfortPreferences = ComfortPreferenceMatches(profile.ComfortPreferences, category, searchable).ToList();
IList<string> matchedPerformancePreferences = PerformancePreferenceMatches(profile.PerformancePreferences, category, searchable).ToList();
IList<string> matchedSetupConstraints = SetupConstraintMatches(profile.SetupConstraints, category, searchable).ToList();
```

Set them in the returned object. In `CalculateScore`, add:

```csharp
if (signals.MatchedComfortPreferences != null)
{
    score += signals.MatchedComfortPreferences.Count * 14;
}

if (signals.MatchedPerformancePreferences != null)
{
    score += signals.MatchedPerformancePreferences.Count * 16;
}

if (signals.MatchedSetupConstraints != null)
{
    score += signals.MatchedSetupConstraints.Count * 14;
}
```

- [ ] **Step 6: Add price intent ordering**

Replace the existing ranking order block with:

```csharp
IEnumerable<PersonalizedProduct> scored = products
    .Select(product => BuildRecommendation(profile, product, wishlistCategories, purchasedCategories, searchedCategories));

return ThenByPriceIntent(scored, profile)
    .ThenBy(item => item.Product.Name, StringComparer.Ordinal)
    .ThenBy(item => item.Product.Id)
    .Take(count < 1 ? 4 : count)
    .ToList();
```

Add helpers:

```csharp
private static IOrderedEnumerable<PersonalizedProduct> ThenByPriceIntent(
    IEnumerable<PersonalizedProduct> items,
    UserPersonalizationProfile profile)
{
    string intent = GetPriceIntent(profile);
    IOrderedEnumerable<PersonalizedProduct> ordered = items.OrderByDescending(item => item.Score);

    if (string.Equals(intent, "premium", StringComparison.OrdinalIgnoreCase))
    {
        return ordered.ThenByDescending(item => item.Product.Price);
    }

    return ordered.ThenBy(item => item.Product.Price);
}

private static string GetPriceIntent(UserPersonalizationProfile profile)
{
    if (profile == null)
    {
        return "budget";
    }

    if (string.Equals(Normalize(profile.BudgetRange), "premium", StringComparison.OrdinalIgnoreCase) ||
        profile.Priorities.Select(Normalize).Contains("premium build"))
    {
        return "premium";
    }

    return "budget";
}
```

- [ ] **Step 7: Run focused test**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Expected: ranking and price intent checks pass; search checks still fail if Task 5 is not done.

- [ ] **Step 8: Commit**

```powershell
git add Services\PersonalizationService.cs
git commit -m "feat: rank by expanded personalization signals"
```

---

### Task 5: Fix Dynamic Search Boost

**Files:**
- Modify: `DAL/PersonalizationRepository.cs`
- Modify: `Services/PersonalizationService.cs`
- Modify: `customer_page/onyx_catalog.aspx.cs`

**Interfaces:**
- Produces repository method:
  - `IList<string> InferSearchCategories(string searchTerm)`
- Produces catalog session methods:
  - `private void StoreRecentSearchSignal(string searchTerm)`
  - `private IList<string> GetRecentSearchSignals()`
- Produces ranking input:
  - `CurrentSearchSignals` through `CatalogQuery` only if needed, or direct service overload if simpler.

- [ ] **Step 1: Expand search category inference**

In `DAL/PersonalizationRepository.cs`, replace `InferSearchCategory` with:

```csharp
public IList<string> InferSearchCategories(string searchTerm)
{
    string value = (searchTerm ?? string.Empty).Trim().ToLowerInvariant();
    var categories = new List<string>();

    AddIfMatches(categories, value, "Keyboard", "keyboard", "keycap", "switch", "mechanical");
    AddIfMatches(categories, value, "Mouse", "mouse", "mice", "dpi", "tracking", "sensor");
    AddIfMatches(categories, value, "Headset", "headset", "headphone", "audio", "ear cushion", "noise cancellation");
    AddIfMatches(categories, value, "Mic", "mic", "microphone", "voice");
    AddIfMatches(categories, value, "Monitor", "monitor", "display", "screen", "refresh", "hz");
    AddIfMatches(categories, value, "Mousepad", "mousepad", "mouse pad", "pad");
    AddIfMatches(categories, value, "Cable", "cable", "wire", "charging");
    AddIfMatches(categories, value, "Chair", "chair", "seat", "ergonomic");
    AddIfMatches(categories, value, "Monitor Extension", "monitor extension", "monitor arm", "arm", "mount");
    AddIfMatches(categories, value, "Accessory", "accessory", "accessories", "desk", "minimal");

    return categories.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
}

private static void AddIfMatches(IList<string> categories, string value, string category, params string[] terms)
{
    if (terms.Any(term => value.Contains(term)))
    {
        categories.Add(category);
    }
}
```

- [ ] **Step 2: Record all inferred categories**

In `RecordCatalogSearch`, use:

```csharp
IList<string> inferredCategories = InferSearchCategories(normalizedTerm);
if (inferredCategories.Count == 0)
{
    inferredCategories.Add(null);
}

foreach (string inferredCategory in inferredCategories)
{
    using (DbCommand cmd = conn.CreateCommand())
    {
        cmd.CommandText = @"
            INSERT INTO catalog_search_events
                (user_id, search_term, inferred_category, searched_at)
            VALUES
                (@UserId, @SearchTerm, @InferredCategory, NOW())";
        AddParameter(cmd, "@UserId", userId);
        AddParameter(cmd, "@SearchTerm", normalizedTerm);
        AddParameter(cmd, "@InferredCategory", inferredCategory);
        cmd.ExecuteNonQuery();
    }
}
```

- [ ] **Step 3: Add session/cookie recent search methods**

In `customer_page/onyx_catalog.aspx.cs`, add:

```csharp
private const string RecentSearchSessionKey = "OnyxRecentSearchSignals";

private void StoreRecentSearchSignal(string searchTerm)
{
    IList<string> signals = GetRecentSearchSignals();
    signals.Insert(0, searchTerm.Trim());
    Session[RecentSearchSessionKey] = signals
        .Where(value => !string.IsNullOrWhiteSpace(value))
        .Take(10)
        .ToList();

    Response.Cookies["onyx_recent_search"].Value = string.Join("|", signals.Take(10));
    Response.Cookies["onyx_recent_search"].Expires = DateTime.UtcNow.AddDays(14);
}

private IList<string> GetRecentSearchSignals()
{
    var values = Session[RecentSearchSessionKey] as IList<string>;
    if (values != null)
    {
        return values.ToList();
    }

    string cookieValue = Request.Cookies["onyx_recent_search"] == null
        ? string.Empty
        : Request.Cookies["onyx_recent_search"].Value;

    return (cookieValue ?? string.Empty)
        .Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries)
        .Select(value => value.Trim())
        .Where(value => value.Length > 0)
        .Take(10)
        .ToList();
}
```

- [ ] **Step 4: Store current search immediately**

In `BindCatalog`, after `SearchTerm` is known and before product query:

```csharp
if (!string.IsNullOrWhiteSpace(SearchTerm))
{
    StoreRecentSearchSignal(SearchTerm);
}
```

Keep DB recording for logged-in users.

- [ ] **Step 5: Feed recent search signals into ranking**

Use the least invasive implementation:

1. Add `IList<string> CurrentSearchSignals { get; set; }` to `Models/CatalogQuery.cs`.
2. In `BindCatalog`, pass `CurrentSearchSignals = GetRecentSearchSignals()`.
3. In `ProductService.GetCatalogProducts`, when recommended sort calls personalization, pass current search signals through a new overload.
4. In `PersonalizationService`, add overload:

```csharp
public IList<PersonalizedProduct> GetRecommendedProducts(
    long userId,
    IList<Product> products,
    IList<string> currentSearchSignals,
    int count)
{
    UserPersonalizationProfile profile = _personalizationRepository.GetProfile(userId);
    if (profile == null || !profile.CompletedAt.HasValue)
    {
        return new List<PersonalizedProduct>();
    }

    IList<string> wishlistCategories = _personalizationRepository.GetWishlistCategories(userId);
    IList<string> purchasedCategories = _personalizationRepository.GetPurchasedCategories(userId);
    IList<string> searchedCategories = _personalizationRepository.GetSearchedCategories(userId)
        .Concat(ConvertSearchSignalsToCategories(currentSearchSignals))
        .ToList();

    return RankProductsForProfile(profile, products, wishlistCategories, purchasedCategories, searchedCategories, count);
}
```

Add:

```csharp
private IList<string> ConvertSearchSignalsToCategories(IList<string> searchSignals)
{
    var categories = new List<string>();
    foreach (string signal in searchSignals ?? new List<string>())
    {
        categories.AddRange(_personalizationRepository.InferSearchCategories(signal));
    }
    return categories;
}
```

- [ ] **Step 6: Run focused test**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Expected: all personalization source-contract checks pass.

- [ ] **Step 7: Commit**

```powershell
git add DAL\PersonalizationRepository.cs Services\PersonalizationService.cs customer_page\onyx_catalog.aspx.cs Models\CatalogQuery.cs
git commit -m "fix: boost catalog recommendations from searches"
```

---

### Task 6: Full Verification

**Files:**
- No intended source modifications unless verification exposes a compile/test issue.

**Interfaces:**
- Consumes all prior tasks.
- Produces verified working build.

- [ ] **Step 1: Run all PowerShell contract tests**

Run:

```powershell
Get-ChildItem -Path Tests,tests -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Running $($_.FullName)"
    powershell -ExecutionPolicy Bypass -File $_.FullName
}
```

Expected: every script exits successfully and prints its pass message.

- [ ] **Step 2: Build solution**

Run:

```powershell
$msbuild = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | Select-Object -First 1
if (-not $msbuild) { $msbuild = 'msbuild' }
& $msbuild ONYX_DDAC.sln /p:Configuration=Debug /p:Platform="Any CPU" /v:minimal
```

Expected: `ONYX_DDAC -> ...\bin\ONYX_DDAC.dll` and exit code 0.

- [ ] **Step 3: Check diff hygiene**

Run:

```powershell
git diff --check
git status --short
```

Expected: no whitespace errors. Existing unrelated dirty files may remain; do not revert them.

- [ ] **Step 4: Commit verification fixes only if needed**

If verification required code changes, run `git status --short`, stage only the files changed by the verification fix, and commit them. For example, if the build fix touched only `Services/PersonalizationService.cs`:

```powershell
git add Services\PersonalizationService.cs
git commit -m "fix: stabilize dynamic personalization verification"
```

Expected: no commit is needed if prior tasks already pass.
