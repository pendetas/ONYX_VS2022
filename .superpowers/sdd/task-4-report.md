## Task 4 Report: Score Expanded Answers And Price Intent

### Scope
- Implemented Task 4 in `Services/PersonalizationService.cs` only.
- Left unrelated dirty files untouched.

### Requirements Completed
1. Added normalization for:
   - `ComfortPreferences`
   - `PerformancePreferences`
   - `SetupConstraints`

2. Added validation for the three expanded answer lists with the exact required messages:
   - `Choose at least one comfort preference.`
   - `Choose at least one performance preference.`
   - `Choose at least one setup constraint.`

3. Expanded `RecommendationSignals` with:
   - `MatchedComfortPreferences`
   - `MatchedPerformancePreferences`
   - `MatchedSetupConstraints`

4. Added matcher helpers:
   - `ComfortPreferenceMatches(...)`
   - `PerformancePreferenceMatches(...)`
   - `SetupConstraintMatches(...)`

5. Wired the new match lists into `GetRecommendationSignals(...)`.

6. Added the required score weights in `CalculateScore(...)`:
   - comfort matches: `* 14`
   - performance matches: `* 16`
   - setup constraint matches: `* 14`

7. Replaced the ranking order block to use:
   - `ThenByPriceIntent(...)`
   - `ThenBy(item => item.Product.Name, StringComparer.Ordinal)`
   - `ThenBy(item => item.Product.Id)`

8. Added price intent helpers:
   - `GetPriceIntent(UserPersonalizationProfile profile)`
   - `ThenByPriceIntent(IEnumerable<PersonalizedProduct> items, UserPersonalizationProfile profile)`

### Test Execution
Command run:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Observed result:
- Task 4 ranking and price-intent schema checks no longer fail.
- The script still fails on `Search personalization records immediate dynamic signals`, which matches the brief's expected state when Task 5 is not complete.

### Notes
- I preserved the existing dirty worktree and committed only `Services/PersonalizationService.cs`.
- The owned file already contained earlier Task 1-3 personalization changes; I worked with those in place and did not revert them.

## Fix review follow-up

Applied the Task 4 review fixes inline after the subagent fixer hit the usage limit:

- Normalized the profile before validation/save so whitespace-only new answer lists cannot pass server validation.
- Restored purchased-category scoring to the pre-Task-4 flat `+20` behavior.
- Removed Task 4 searched-category score boost; Task 5 owns search boost behavior.
- Updated price intent so both `premium build` and `premium-build` count as premium intent.

## Verification

Ran:

```powershell
powershell -ExecutionPolicy Bypass -File Tests\PersonalizationFlow.Tests.ps1
```

Result: failed only on `Search personalization records immediate dynamic signals`, which is the expected Task 5 requirement.
